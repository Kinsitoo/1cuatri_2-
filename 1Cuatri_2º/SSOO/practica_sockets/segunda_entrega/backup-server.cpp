// backup-server.cpp
// Este archivo implementa el servidor de backups.
// El servidor se queda esperando peticiones a través de una FIFO y señales SIGUSR1.
// Cada vez que llega una señal, lee del FIFO la ruta del archivo a copiar
// y hace el backup dentro de un directorio que le pasamos por parámetro.

// Incluimos el archivo de funciones comunes (copy_file, get_fifo_path, read_path_from_fifo…)
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
    // 1. Determinar el directorio donde guardar los backups
    // =============================

    std::string backup_dir;

    // Si el usuario pone un parámetro, lo usamos como directorio destino
    if (argc >= 2) backup_dir = argv[1];
    else {
        // Si no pasa parámetro, usamos el directorio actual
        char cwd[PATH_MAX];
        if (!getcwd(cwd, PATH_MAX)) {
            std::cerr << "backup-server: error obteniendo directorio actual: " << strerror(errno) << "\n";
            return 1;
        }
        backup_dir = std::string(cwd);
    }

    // =============================
    // 2. Validar BACKUP_WORK_DIR
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
    // 3. Comprobar que el directorio de backups existe
    // =============================
    if (!is_directory(backup_dir)) {
        std::cerr << "backup-server: error: el directorio destino no existe o no es accesible: " << backup_dir << "\n";
        return 1;
    }

    // =============================
    // 4. Comprobar si ya hay otro servidor corriendo (leyendo PID)
    // =============================

    std::string pid_path = get_pid_file_path();
    if (file_exists(pid_path)) {

        // Intentamos leer el PID del archivo
        auto maybe_pid = read_server_pid_from_file(pid_path);

        if (maybe_pid.has_value()) {
            pid_t pid = maybe_pid.value();

            // kill(pid,0) → comprueba si existe
            if (is_server_running(pid)) {
                std::cerr << "backup-server: error: ya hay un servidor ejecutándose (PID "
                          << pid << ")\n";
                return 1;
            } else {
                std::cerr << "backup-server: aviso: existe pid-file pero el proceso no está vivo\n";
            }

        } else {
            // El PID existía pero no se pudo leer
            std::cerr << "backup-server: aviso: no se pudo leer PID previo: "
                      << maybe_pid.error().what() << "\n";
        }
    }

    // =============================
    // 5. Crear FIFO y PID file
    // =============================

    std::string fifo_path = get_fifo_path();

    // Si ya existía FIFO, primero la borramos.
    auto res_fifo = create_fifo(fifo_path);
    if (!res_fifo.has_value()) {
        std::cerr << "backup-server: error creando FIFO: "
                  << res_fifo.error().what() << "\n";
        return 1;
    }

    // Escribimos nuestro PID en un fichero para que el cliente pueda encontrarnos.
    auto res_pid = write_pid_file(pid_path);
    if (!res_pid.has_value()) {
        std::cerr << "backup-server: error escribiendo PID: "
                  << res_pid.error().what() << "\n";

        // Si falla, limpiamos la FIFO también
        unlink(fifo_path.c_str());
        return 1;
    }

    // =============================
    // 6. Instalar manejadores para señales de terminación
    // =============================

    // Estos manejadores simplemente muestran un mensaje y ponen quit_requested = true.
    install_termination_handlers();

    // =============================
    // 7. Preparar sigwaitinfo para SIGUSR1
    // =============================

    sigset_t sigset;
    sigemptyset(&sigset);
    sigaddset(&sigset, SIGUSR1);

    // Bloqueamos SIGUSR1 para que no vaya a un handler, sino a sigwaitinfo()
    if (sigprocmask(SIG_BLOCK, &sigset, nullptr) == -1) {
        std::cerr << "backup-server: error bloqueando SIGUSR1: " << strerror(errno) << "\n";
        unlink(fifo_path.c_str());
        unlink(pid_path.c_str());
        return 1;
    }

    // =============================
    // 8. Abrir FIFO para lectura
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
    // 9. Bucle principal del servidor
    // =============================

    while (!quit_requested) {

        // Esperamos la señal SIGUSR1
        siginfo_t info;
        int signo = sigwaitinfo(&sigset, &info);

        if (signo == -1) {
            if (errno == EINTR) continue;  // señal de terminación u otra interrupción
            std::cerr << "backup-server: sigwaitinfo error: " << strerror(errno) << "\n";
            break;
        }

        if (signo == SIGUSR1) {

            // =============================
            // 9.1 Leer ruta enviada por el cliente desde la FIFO
            // =============================

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

            // =============================
            // 9.2 Calcular ruta destino
            // =============================

            // Extraemos solo el nombre del archivo (parte final de la ruta)
            std::string nombre;
            size_t pos = origen.find_last_of('/');
            if (pos == std::string::npos) nombre = origen;
            else nombre = origen.substr(pos + 1);

            // Construimos ruta final de destino: backup_dir/nombre
            std::string destino = backup_dir;
            if (destino.back() != '/') destino += '/';
            destino += nombre;

            // =============================
            // 9.3 Copiar archivo usando nuestra función copy_file()
            // =============================

            auto res = copy_file(origen, destino);

            if (!res.has_value()) {
                std::cerr << "backup-server: error copiando " << origen << ": "
                          << res.error().what() << "\n";
            } else {
                std::cout << "backup-server: backup completado: "
                          << origen << " -> " << destino << "\n";
            }
        }
    }

    // =============================
    // 10. Limpieza final antes de cerrar
    // =============================

    close(fifo_fd);
    unlink(fifo_path.c_str());
    unlink(pid_path.c_str());

    return 0;
}


//g++ -std=c++23 -O2 backup-server.cpp -o backup-server
//export BACKUP_WORK_DIR=~/UNI/1Cuatri_2º/SSOO/practica_sockets/segunda_entrega/work-backup/
//./backup-server ~/UNI/1Cuatri_2º/SSOO/practica_sockets/segunda_entrega/backups/
