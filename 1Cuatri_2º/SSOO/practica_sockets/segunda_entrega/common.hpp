// common.hpp
#ifndef COMMON_HPP
#define COMMON_HPP

#include <string>
#include <vector>
#include <expected>
#include <system_error>
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

constexpr size_t COPY_BUFFER_SIZE = 64 * 1024;

inline std::string get_work_dir_path() {
    char* v = getenv("BACKUP_WORK_DIR");
    if (!v) return std::string();
    return std::string(v);
}

inline std::string get_fifo_path() {
    std::string wd = get_work_dir_path();
    if (wd.empty()) return std::string();
    if (wd.back() == '/') wd.pop_back();
    return wd + "/backup.fifo";
}

inline std::string get_pid_file_path() {
    std::string wd = get_work_dir_path();
    if (wd.empty()) return std::string();
    if (wd.back() == '/') wd.pop_back();
    return wd + "/backup-server.pid";
}

inline bool file_exists(const std::string& path) {
    return (access(path.c_str(), F_OK) == 0);
}

inline bool is_regular_file(const std::string& path) {
    struct stat st;
    if (stat(path.c_str(), &st) == -1) return false;
    return S_ISREG(st.st_mode);
}

inline bool is_directory(const std::string& path) {
    struct stat st;
    if (stat(path.c_str(), &st) == -1) return false;
    return S_ISDIR(st.st_mode);
}

inline std::expected<std::string, std::system_error> get_absolute_path(const std::string& path) {
    char* rp = realpath(path.c_str(), nullptr);
    if (!rp) {
        return std::unexpected(std::system_error(errno, std::system_category(), "realpath error"));
    }
    std::string res(rp);
    free(rp);
    return res;
}

// copy_file: usa open/read/write/close y devuelve std::expected<void, system_error>
inline std::expected<void, std::system_error> copy_file(const std::string& src_path, const std::string& dest_path) {
    std::vector<char> buffer(COPY_BUFFER_SIZE);
    int src_fd = open(src_path.c_str(), O_RDONLY);
    if (src_fd == -1) {
        return std::unexpected(std::system_error(errno, std::system_category(), "error al abrir origen"));
    }

    // modo 0666, respetando umask
    int dest_fd = open(dest_path.c_str(), O_WRONLY | O_CREAT | O_TRUNC, 0666);
    if (dest_fd == -1) {
        close(src_fd);
        return std::unexpected(std::system_error(errno, std::system_category(), "error al abrir destino"));
    }

    while (true) {
        ssize_t br = read(src_fd, buffer.data(), buffer.size());
        if (br == -1) {
            if (errno == EINTR) continue;
            close(src_fd);
            close(dest_fd);
            return std::unexpected(std::system_error(errno, std::system_category(), "error lectura origen"));
        }
        if (br == 0) break; // EOF

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

    if (close(src_fd) == -1) {
        // intentar cerrar dest_fd antes de devolver error
        close(dest_fd);
        return std::unexpected(std::system_error(errno, std::system_category(), "error cerrando origen"));
    }
    if (close(dest_fd) == -1) {
        return std::unexpected(std::system_error(errno, std::system_category(), "error cerrando destino"));
    }

    return {};
}

// lectura de línea desde fifo_fd (hasta '\n', sin incluír '\n')
inline std::expected<std::string, std::system_error> read_path_from_fifo(int fifo_fd) {
    std::string s;
    char c;
    size_t cnt = 0;
    while (cnt < PATH_MAX) {
        ssize_t r = read(fifo_fd, &c, 1);
        if (r == -1) {
            if (errno == EINTR) continue;
            return std::unexpected(std::system_error(errno, std::system_category(), "error leyendo FIFO"));
        }
        if (r == 0) {
            // EOF: si no tenemos datos, esto puede indicar cierre del otro extremo
            if (s.empty()) {
                return std::unexpected(std::system_error(EIO, std::system_category(), "EOF en FIFO"));
            } else {
                break;
            }
        }
        if (c == '\n') break;
        s.push_back(c);
        ++cnt;
    }
    if (cnt >= PATH_MAX) {
        return std::unexpected(std::system_error(ENAMETOOLONG, std::system_category(), "ruta demasiado larga"));
    }
    return s;
}

// lectura de PID usando solo open/read/close, devuelve pid_t
inline std::expected<pid_t, std::system_error> read_server_pid_from_file(const std::string& pid_file_path) {
    int fd = open(pid_file_path.c_str(), O_RDONLY);
    if (fd == -1) {
        return std::unexpected(std::system_error(errno, std::system_category(), "error abrir pid file"));
    }
    char buf[64] = {0};
    ssize_t r = read(fd, buf, sizeof(buf) - 1);
    if (r == -1) {
        close(fd);
        return std::unexpected(std::system_error(errno, std::system_category(), "error leer pid file"));
    }
    close(fd);
    // convertir a número
    char* endptr = nullptr;
    long val = strtol(buf, &endptr, 10);
    if (endptr == buf || val <= 0) {
        return std::unexpected(std::system_error(EINVAL, std::system_category(), "contenido PID inválido"));
    }
    return static_cast<pid_t>(val);
}

inline bool is_server_running(pid_t pid) {
    if (kill(pid, 0) == -1) {
        if (errno == ESRCH) return false;
        // si EPERM u otro -> existe pero no tenemos permisos -> considerar corriendo
        return true;
    }
    return true;
}

// crear fifo: si existe unlink y luego mkfifo
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

// escribir PID en archivo (open/write/close)
inline std::expected<void, std::system_error> write_pid_file(const std::string& pid_file_path) {
    int fd = open(pid_file_path.c_str(), O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd == -1) return std::unexpected(std::system_error(errno, std::system_category(), "error abrir pid file"));
    char buf[32];
    int n = snprintf(buf, sizeof(buf), "%d\n", (int)getpid());
    ssize_t written = 0;
    while (written < n) {
        ssize_t w = write(fd, buf + written, n - written);
        if (w == -1) {
            if (errno == EINTR) continue;
            close(fd);
            return std::unexpected(std::system_error(errno, std::system_category(), "error escribir pid file"));
        }
        written += w;
    }
    if (close(fd) == -1) {
        return std::unexpected(std::system_error(errno, std::system_category(), "error cerrar pid file"));
    }
    return {};
}

// manejador simple de terminación
extern std::atomic<bool> quit_requested;

inline void install_termination_handlers() {
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = [](int signum) {
        const char msg[] = "backup-server: señal de terminación recibida, cerrando...\n";
        write(STDOUT_FILENO, msg, sizeof(msg) - 1);
        quit_requested = true;
    };
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0; // no SA_RESTART: queremos que ciertas syscalls se interrumpan y permitan terminar
    sigaction(SIGTERM, &sa, nullptr);
    sigaction(SIGINT, &sa, nullptr);
    sigaction(SIGHUP, &sa, nullptr);
    sigaction(SIGQUIT, &sa, nullptr);
}

#endif // COMMON_HPP
