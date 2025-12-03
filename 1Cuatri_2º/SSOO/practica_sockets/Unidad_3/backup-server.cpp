// backup-server.cpp
// Este archivo implementa el servidor de backups.
// El servidor se queda esperando peticiones a través de una FIFO y señales SIGUSR1.
// Cada vez que llega una señal, lee del FIFO la ruta del archivo a copiar
// y hace el backup dentro de un directorio que le pasamos por parámetro.

#include "common.hpp"

#include <iostream>
#include <signal.h>
#include <string>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

// Variable global que indica si el servidor debe cerrarse.
// Se modifica desde los manejadores de señales de terminación.
std::atomic<bool> quit_requested{false};

int main(int argc, char* argv[]) {

    // =============================
    // 1. Parsear argumentos
    // =============================
    auto arguments_result = parse_arguments(argc, argv);
    if (!arguments_result.has_value()) {
        switch (arguments_result.error()) {
            case ParseArgsErrors::unknown_option:
                std::cerr << "backup-server: error: opción desconocida\n";
                break;
            case ParseArgsErrors::multiple_compression_options:
                std::cerr << "backup-server: error: solo se admite una opción de compresión\n";
                break;
            case ParseArgsErrors::too_many_arguments:
                std::cerr << "backup-server: error: demasiados argumentos\n";
                break;
        }
        std::cerr << "uso: backup-server [-z | -j | -x] [DIRECTORIO_DESTINO]\n";
        return 1;
    }

    ServerOptions options = arguments_result.value();

    // =============================
    // 2. Determinar directorio de backups
    // =============================
    std::string backup_dir;
    if (!options.backup_dir.empty()) {
        backup_dir = options.backup_dir;
    } else {
        char cwd[PATH_MAX];
        if (!getcwd(cwd, PATH_MAX)) {
            std::cerr << "backup-server: error obteniendo directorio actual: " << strerror(errno) << "\n";
            return 1;
        }
        backup_dir = std::string(cwd);
    }

    // =============================
    // 3. Validar BACKUP_WORK_DIR
    // =============================
    std::string work_dir = get_work_dir_path();
    if (work_dir.empty()) {
        std::cerr << "backup-server: error: BACKUP_WORK_DIR no está definida\n";
        return 1;
    }

    if (!is_directory(work_dir)) {
        std::cerr << "backup-server: error: el directorio de trabajo no existe o no es accesible\n";
        return 1;
    }

    // =============================
    // 4. Validar directorio de backups
    // =============================
    if (!is_directory(backup_dir)) {
        std::cerr << "backup-server: error: el directorio destino no existe o no es accesible: " << backup_dir << "\n";
        return 1;
    }

    // =============================
    // 5. Verificar comando de compresión si aplica
    // =============================
    if (options.compression != CompressionType::NONE) {
        std::string cmd = get_compression_command(options.compression);
        if (!is_command_available(cmd)) {
            std::cerr << "backup-server: error: " << cmd << " no está instalado\n";
            return 1;
        }
        std::cout << "backup-server: compresión: " << cmd << "\n";
    }

    // =============================
    // 6. Comprobar si ya hay otro servidor corriendo
    // =============================
    std::string pid_path = get_pid_file_path();
    if (file_exists(pid_path)) {
        auto maybe_pid = read_server_pid_from_file(pid_path);
        if (maybe_pid.has_value()) {
            pid_t pid = maybe_pid.value();
            if (is_server_running(pid)) {
                std::cerr << "backup-server: error: ya hay un servidor ejecutándose (PID "
                          << pid << ")\n";
                return 1;
            } else {
                std::cerr << "backup-server: aviso: existe pid-file pero el proceso no está vivo\n";
            }
        } else {
            std::cerr << "backup-server: aviso: no se pudo leer PID previo: "
                      << maybe_pid.error().what() << "\n";
        }
    }

    // =============================
    // 7. Crear FIFO y PID file
    // =============================
    std::string fifo_path = get_fifo_path();

    auto res_fifo = create_fifo(fifo_path);
    if (!res_fifo.has_value()) {
        std::cerr << "backup-server: error creando FIFO: "
                  << res_fifo.error().what() << "\n";
        return 1;
    }

    auto res_pid = write_pid_file(pid_path);
    if (!res_pid.has_value()) {
        std::cerr << "backup-server: error escribiendo PID: "
                  << res_pid.error().what() << "\n";
        unlink(fifo_path.c_str());
        return 1;
    }

    // =============================
    // 8. Instalar manejadores de terminación
    // =============================
    install_termination_handlers();

    // =============================
    // 9. Bloquear SIGUSR1
    // =============================
    sigset_t sigset;
    sigemptyset(&sigset);
    sigaddset(&sigset, SIGUSR1);
    if (sigprocmask(SIG_BLOCK, &sigset, nullptr) == -1) {
        std::cerr << "backup-server: error bloqueando SIGUSR1: " << strerror(errno) << "\n";
        unlink(fifo_path.c_str());
        unlink(pid_path.c_str());
        return 1;
    }

    // =============================
    // 10. Abrir FIFO para lectura
    // =============================
    int fifo_fd = open(fifo_path.c_str(), O_RDONLY);
    if (fifo_fd == -1) {
        std::cerr << "backup-server: error abriendo FIFO para lectura: "
                  << strerror(errno) << "\n";
        unlink(fifo_path.c_str());
        unlink(pid_path.c_str());
        return 1;
    }

    std::cout << "backup-server: esperando solicitudes de backup en " << backup_dir << "\n";

    // =============================
    // 11. Bucle principal
    // =============================
    while (!quit_requested) {
        siginfo_t info;
        int signo = sigwaitinfo(&sigset, &info);

        if (signo == -1) {
            if (errno == EINTR) continue;
            std::cerr << "backup-server: sigwaitinfo error: " << strerror(errno) << "\n";
            break;
        }

        if (signo == SIGUSR1) {
            auto maybe_path = read_path_from_fifo(fifo_fd);
            if (!maybe_path.has_value()) {
                std::cerr << "backup-server: error leyendo ruta desde FIFO: "
                          << maybe_path.error().what() << "\n";
                continue;
            }

            std::string origen = maybe_path.value();
            if (origen.empty()) {
                std::cerr << "backup-server: ruta leída vacía\n";
                continue;
            }

            std::string nombre;
            size_t pos = origen.find_last_of('/');
            if (pos == std::string::npos) nombre = origen;
            else nombre = origen.substr(pos + 1);

            std::string destino = backup_dir;
            if (destino.back() != '/') destino += '/';
            destino += nombre;

            // Aplicar extensión si hay compresión
            std::expected<void, std::variant<std::system_error, CopyFileCompressedError>> res;
            if (options.compression == CompressionType::NONE) {
                res = copy_file(origen, destino);
            } else {
                std::string ext = get_compression_extension(options.compression);
                destino += ext;
                std::string cmd = get_compression_command(options.compression);
                auto res_comp = copy_file_compressed(origen, destino, cmd);
                if (res_comp.has_value()) {
                    res = {}; // éxito
                } else {
                    // Convertimos al tipo común de error
                    res = std::unexpected(
                        std::variant<std::system_error, CopyFileCompressedError>(
                            res_comp.error()
                        )
                    );
                }
            }

            // Enviar señal al cliente
            pid_t cliente_pid = info.si_pid;
            if (res.has_value()) {
                std::cout << "backup-server: backup completado: "
                          << origen << " -> " << destino << "\n";
                kill(cliente_pid, SIGUSR1);
            } else {
                std::string msg;
                if (std::holds_alternative<CopyFileCompressedError>(res.error())) {
                    auto err = std::get<CopyFileCompressedError>(res.error());
                    switch (err) {
                        case CopyFileCompressedError::command_not_found:
                            msg = "comando de compresión no encontrado";
                            break;
                        case CopyFileCompressedError::command_access_denied:
                            msg = "acceso denegado al comando de compresión";
                            break;
                        case CopyFileCompressedError::output_access_denied:
                            msg = "no se puede crear el archivo de destino";
                            break;
                        case CopyFileCompressedError::command_execution_failed:
                            msg = "el compresor falló durante la ejecución";
                            break;
                        default:
                            msg = "error desconocido en compresión";
                    }
                } else {
                    msg = std::get<std::system_error>(res.error()).what();
                }
                std::cerr << "backup-server: error copiando " << origen << ": " << msg << "\n";
                kill(cliente_pid, SIGUSR2);
            }
        }
    }

    // =============================
    // 12. Limpieza
    // =============================
    close(fifo_fd);
    unlink(fifo_path.c_str());
    unlink(pid_path.c_str());

    return 0;
}

//g++ -std=c++23 -O2 backup-server.cpp -o backup-server
//export BACKUP_WORK_DIR=~/UNI/1Cuatri_2º/SSOO/practica_sockets/segunda_entrega/work-backup/
//./backup-server ~/UNI/1Cuatri_2º/SSOO/practica_sockets/segunda_entrega/backups/
//./backup-server -z ~/backups
