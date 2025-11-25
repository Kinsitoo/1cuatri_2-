// backup-server.cpp
#include "common.hpp"

#include <iostream>
#include <signal.h>
#include <string>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

std::atomic<bool> quit_requested{false};

int main(int argc, char* argv[]) {
    // directorio de backups (opcional en argv[1])
    std::string backup_dir;
    if (argc >= 2) backup_dir = argv[1];
    else {
        char cwd[PATH_MAX];
        if (!getcwd(cwd, PATH_MAX)) {
            std::cerr << "backup-server: error obteniendo directorio actual: " << strerror(errno) << "\n";
            return 1;
        }
        backup_dir = std::string(cwd);
    }

    // comprobar BACKUP_WORK_DIR
    std::string work_dir = get_work_dir_path();
    if (work_dir.empty()) {
        std::cerr << "backup-server: error: BACKUP_WORK_DIR no está definida\n";
        return 1;
    }
    if (!is_directory(work_dir)) {
        std::cerr << "backup-server: error: directorio de trabajo no existe o no es accesible\n";
        return 1;
    }

    // comprobar que directorio destino existe
    if (!is_directory(backup_dir)) {
        std::cerr << "backup-server: error: directorio destino no existe o no es accesible: " << backup_dir << "\n";
        return 1;
    }

    // comprobar PID previo
    std::string pid_path = get_pid_file_path();
    if (file_exists(pid_path)) {
        auto maybe_pid = read_server_pid_from_file(pid_path);
        if (maybe_pid.has_value()) {
            pid_t pid = maybe_pid.value();
            if (is_server_running(pid)) {
                std::cerr << "backup-server: error: ya hay un servidor ejecutándose (PID " << pid << ")\n";
                return 1;
            } else {
                std::cerr << "backup-server: advertencia: archivo PID de servidor previo existe pero proceso no está vivo\n";
                // continuar (se sobreescribirá el pid file)
            }
        } else {
            std::cerr << "backup-server: advertencia: no se pudo leer PID previo: " << maybe_pid.error().what() << "\n";
        }
    }

    // crear FIFO y escribir PID
    std::string fifo_path = get_fifo_path();
    auto res_fifo = create_fifo(fifo_path);
    if (!res_fifo.has_value()) {
        std::cerr << "backup-server: error creando FIFO: " << res_fifo.error().what() << "\n";
        return 1;
    }

    auto res_pid = write_pid_file(pid_path);
    if (!res_pid.has_value()) {
        std::cerr << "backup-server: error escribiendo PID: " << res_pid.error().what() << "\n";
        unlink(fifo_path.c_str());
        return 1;
    }

    // instalar manejadores de terminación (usando write() dentro)
    install_termination_handlers();

    // preparar bloqueo de SIGUSR1 y usar sigwaitinfo
    sigset_t sigset;
    sigemptyset(&sigset);
    sigaddset(&sigset, SIGUSR1);
    if (sigprocmask(SIG_BLOCK, &sigset, nullptr) == -1) {
        std::cerr << "backup-server: error bloqueando SIGUSR1: " << strerror(errno) << "\n";
        unlink(fifo_path.c_str());
        unlink(pid_path.c_str());
        return 1;
    }

    // abrir FIFO para lectura (bloqueará hasta que algún cliente abra escritura)
    int fifo_fd = open(fifo_path.c_str(), O_RDONLY);
    if (fifo_fd == -1) {
        std::cerr << "backup-server: error abriendo FIFO para lectura: " << strerror(errno) << "\n";
        unlink(fifo_path.c_str());
        unlink(pid_path.c_str());
        return 1;
    }

    std::cout << "backup-server: esperando solicitudes de backup en " << backup_dir << "\n";

    // bucle principal
    while (!quit_requested) {
        siginfo_t info;
        int signo = sigwaitinfo(&sigset, &info);
        if (signo == -1) {
            if (errno == EINTR) continue;
            std::cerr << "backup-server: sigwaitinfo error: " << strerror(errno) << "\n";
            break;
        }

        if (signo == SIGUSR1) {
            // leer ruta desde FIFO
            auto maybe_path = read_path_from_fifo(fifo_fd);
            if (!maybe_path.has_value()) {
                std::cerr << "backup-server: error al leer ruta desde FIFO: " << maybe_path.error().what() << "\n";
                continue; // seguir aceptando solicitudes
            }
            std::string origen = maybe_path.value();
            if (origen.empty()) {
                std::cerr << "backup-server: ruta leída vacía\n";
                continue;
            }

            // obtener nombre y destino
            std::string nombre;
            size_t last_slash = origen.find_last_of('/');
            if (last_slash == std::string::npos) nombre = origen;
            else nombre = origen.substr(last_slash + 1);
            std::string destino = backup_dir;
            if (destino.back() != '/') destino += '/';
            destino += nombre;

            // llamar a copy_file (usa open/read/write)
            auto res = copy_file(origen, destino);
            if (!res.has_value()) {
                std::cerr << "backup-server: error al hacer backup de " << origen << ": " << res.error().what() << "\n";
            } else {
                std::cout << "backup-server: backup completado: " << origen << " -> " << destino << "\n";
            }
        }
    }

    // limpieza
    close(fifo_fd);
    unlink(fifo_path.c_str());
    unlink(pid_path.c_str());

    return 0;
}
