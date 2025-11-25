// common.hpp
// Archivo de utilidades comunes para backup-server y backup.
// Aquí ponemos funciones que usan ambos programas (rutas, copy_file, lectura del PID, etc.)

#ifndef COMMON_HPP
#define COMMON_HPP

#include <string>
#include <vector>
#include <expected>      // Para usar std::expected, que nos obliga a gestionar errores bien
#include <system_error>  // Para std::system_error
#include <cerrno>
#include <cstring>
#include <unistd.h>
#include <limits.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/types.h>
#include <cstdio>
#include <atomic>

// Tamaño del buffer usado para copiar archivos (64KiB).
constexpr size_t COPY_BUFFER_SIZE = 64 * 1024;


// Devuelve la ruta del directorio de trabajo leído desde la variable de entorno BACKUP_WORK_DIR.
// Si no existe la variable, devolvemos string vacío.
inline std::string get_work_dir_path() {
    char* v = getenv("BACKUP_WORK_DIR");
    if (!v) return std::string();
    return std::string(v);
}


// Devuelve la ruta al archivo FIFO dentro del directorio de trabajo
inline std::string get_fifo_path() {
    std::string wd = get_work_dir_path();
    if (wd.empty()) return std::string();
    if (wd.back() == '/') wd.pop_back();   // quitamos / final si existe
    return wd + "/backup.fifo";
}


// Devuelve la ruta al fichero donde guardamos el PID del servidor
inline std::string get_pid_file_path() {
    std::string wd = get_work_dir_path();
    if (wd.empty()) return std::string();
    if (wd.back() == '/') wd.pop_back();
    return wd + "/backup-server.pid";
}


// Comprueba si un archivo existe usando access()
inline bool file_exists(const std::string& path) {
    return (access(path.c_str(), F_OK) == 0);
}


// Comprueba si un fichero es regular (no directorio, no FIFO, no socket…)
inline bool is_regular_file(const std::string& path) {
    struct stat st;
    if (stat(path.c_str(), &st) == -1) return false;
    return S_ISREG(st.st_mode);
}


// Comprueba si es un directorio
inline bool is_directory(const std::string& path) {
    struct stat st;
    if (stat(path.c_str(), &st) == -1) return false;
    return S_ISDIR(st.st_mode);
}


// Convierte path relativo → absoluto usando realpath()
// Aquí usamos std::expected para tratar el error bien.
inline std::expected<std::string, std::system_error> get_absolute_path(const std::string& path) {
    char* rp = realpath(path.c_str(), nullptr);
    if (!rp) {
        return std::unexpected(std::system_error(errno, std::system_category(), "realpath error"));
    }
    std::string res(rp);
    free(rp); // liberamos memoria que realpath reserva internamente
    return res;
}


// =============================
// copy_file()
// =============================
// Copia un archivo usando únicamente open/read/write/close tal y como pide la práctica.
// Si hay cualquier error devuelve std::unexpected con system_error.
inline std::expected<void, std::system_error> copy_file(const std::string& src_path, const std::string& dest_path) {
    std::vector<char> buffer(COPY_BUFFER_SIZE);

    // Abrimos origen solo lectura
    int src_fd = open(src_path.c_str(), O_RDONLY);
    if (src_fd == -1) {
        return std::unexpected(std::system_error(errno, std::system_category(), "error al abrir origen"));
    }

    // Abrimos destino en modo crear/truncar
    int dest_fd = open(dest_path.c_str(), O_WRONLY | O_CREAT | O_TRUNC, 0666);
    if (dest_fd == -1) {
        close(src_fd);
        return std::unexpected(std::system_error(errno, std::system_category(), "error al abrir destino"));
    }

    // Bucle clásico de lectura-escritura
    while (true) {
        ssize_t br = read(src_fd, buffer.data(), buffer.size());
        if (br == -1) {
            if (errno == EINTR) continue; // si señal interrumpe read, repetimos
            close(src_fd);
            close(dest_fd);
            return std::unexpected(std::system_error(errno, std::system_category(), "error lectura origen"));
        }
        if (br == 0) break; // EOF

        // Escribimos teniendo en cuenta que write puede escribir menos bytes
        ssize_t written = 0;
        while (written < br) {
            ssize_t bw = write(dest_fd, buffer.data() + written, br - written);
            if (bw == -1) {
                if (errno == EINTR) continue;
                close(src_fd);
                close(dest_fd);
                return std::unexpected(std::system_error(errno, std::system_category(), "error escritura destino"));
            }
            written += bw;
        }
    }

    // Cerramos descriptores
    if (close(src_fd) == -1) {
        close(dest_fd);
        return std::unexpected(std::system_error(errno, std::system_category(), "error cerrando origen"));
    }
    if (close(dest_fd) == -1) {
        return std::unexpected(std::system_error(errno, std::system_category(), "error cerrando destino"));
    }

    return {};
}


// Lee una línea desde el FIFO, carácter a carácter, hasta '\n'
// Como no usamos std::getline (que es C++ alto nivel), lo hacemos a mano con read()
inline std::expected<std::string, std::system_error> read_path_from_fifo(int fifo_fd) {
    std::string s;
    char c;
    size_t cnt = 0;

    while (cnt < PATH_MAX) {          // no permitimos caminos demasiado largos
        ssize_t r = read(fifo_fd, &c, 1);
        if (r == -1) {
            if (errno == EINTR) continue;
            return std::unexpected(std::system_error(errno, std::system_category(), "error leyendo FIFO"));
        }
        if (r == 0) { // EOF
            if (s.empty()) { // si no hemos leído nada → error
                return std::unexpected(std::system_error(EIO, std::system_category(), "EOF en FIFO"));
            }
            break;
        }
        if (c == '\n') break;
        s.push_back(c);
        cnt++;
    }

    if (cnt >= PATH_MAX) {
        return std::unexpected(std::system_error(ENAMETOOLONG, std::system_category(), "ruta demasiado larga"));
    }
    return s;
}


// Lee el PID del servidor usando únicamente open/read/close (prohibido fstream)
// Lo devolvemos como std::expected<pid_t>
inline std::expected<pid_t, std::system_error> read_server_pid_from_file(const std::string& pid_file_path) {
    int fd = open(pid_file_path.c_str(), O_RDONLY);
    if (fd == -1) {
        return std::unexpected(std::system_error(errno, std::system_category(), "error al abrir pid file"));
    }

    char buf[64] = {0};
    ssize_t r = read(fd, buf, sizeof(buf) - 1);
    if (r == -1) {
        close(fd);
        return std::unexpected(std::system_error(errno, std::system_category(), "error leyendo pid file"));
    }
    close(fd);

    // Convertimos buf a número (strtol)
    char* endptr = nullptr;
    long val = strtol(buf, &endptr, 10);
    if (endptr == buf || val <= 0) {
        return std::unexpected(std::system_error(EINVAL, std::system_category(), "PID inválido"));
    }
    return static_cast<pid_t>(val);
}


// Comprueba si un proceso está vivo: kill(pid,0) no mata nada, solo prueba existencia del proceso
inline bool is_server_running(pid_t pid) {
    if (kill(pid, 0) == -1) {
        if (errno == ESRCH) return false;  // no existe
        return true;                        // EPERM → existe pero no tenemos permisos
    }
    return true;
}


// Crea FIFO (si ya existe lo borramos)
inline std::expected<void, std::system_error> create_fifo(const std::string& fifo_path) {
    if (file_exists(fifo_path)) {
        if (unlink(fifo_path.c_str()) == -1) {
            return std::unexpected(std::system_error(errno, std::system_category(), "error unlink FIFO"));
        }
    }
    if (mkfifo(fifo_path.c_str(), 0666) == -1) {
        return std::unexpected(std::system_error(errno, std::system_category(), "error mkfifo"));
    }
    return {};
}


// Escribe el PID del servidor en un archivo usando open/write/close
inline std::expected<void, std::system_error> write_pid_file(const std::string& pid_file_path) {
    int fd = open(pid_file_path.c_str(), O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd == -1) return std::unexpected(std::system_error(errno, std::system_category(), "error abriendo pid file"));

    char buf[32];
    int n = snprintf(buf, sizeof(buf), "%d\n", (int)getpid());
    size_t written = 0;

    while (written < (size_t)n) {
        ssize_t w = write(fd, buf + written, n - written);
        if (w == -1) {
            if (errno == EINTR) continue;
            close(fd);
            return std::unexpected(std::system_error(errno, std::system_category(), "error escribiendo pid file"));
        }
        written += w;
    }

    if (close(fd) == -1) {
        return std::unexpected(std::system_error(errno, std::system_category(), "error cerrando pid file"));
    }
    return {};
}


// Variable global para avisar al servidor de que debe terminar
extern std::atomic<bool> quit_requested;


// Instalamos manejadores de señales simples que solo hacen un write() y ponen quit_requested=true
inline void install_termination_handlers() {
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));

    sa.sa_handler = [](int signum) {
        const char msg[] = "backup-server: señal de terminación recibida, cerrando...\n";
        write(STDOUT_FILENO, msg, sizeof(msg) - 1); // write() permitido en handlers
        quit_requested = true;
    };

    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0; // sin SA_RESTART para que ciertas syscalls se interrumpan

    sigaction(SIGTERM, &sa, nullptr);
    sigaction(SIGINT,  &sa, nullptr);
    sigaction(SIGHUP,  &sa, nullptr);
    sigaction(SIGQUIT, &sa, nullptr);
}

#endif // COMMON_HPP
