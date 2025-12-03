// backup.cpp
#include "common.hpp"

#include <iostream>
#include <signal.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <cstring>

// =============================
// MODI: variable global para recibir señal
// =============================
volatile sig_atomic_t backup_result = 0; // 1 = éxito (SIGUSR1), 2 = error (SIGUSR2)

void handler_backup_result(int signum) {
    if (signum == SIGUSR1) backup_result = 1;
    else if (signum == SIGUSR2) backup_result = 2;
}

int main(int argc, char* argv[]) {

    // =============================
    // 1. Comprobar argumentos
    // =============================

    if (argc != 2) {
        std::cerr << "backup: uso correcto: backup ARCHIVO\n";
        return 1;
    }

    std::string archivo = argv[1];

    // =============================
    // 2. Validar BACKUP_WORK_DIR
    // =============================

    std::string work_dir = get_work_dir_path();
    if (work_dir.empty()) {
        std::cerr << "backup: error: BACKUP_WORK_DIR no está definida\n";
        return 1;
    }

    // =============================
    // 3. Comprobar que el archivo a copiar existe y es regular
    // =============================

    if (!file_exists(archivo)) {
        std::cerr << "backup: error: el archivo " << archivo << " no existe\n";
        return 1;
    }

    if (!is_regular_file(archivo)) {
        std::cerr << "backup: error: " << archivo << " no es un archivo regular\n";
        return 1;
    }

    // =============================
    // 4. Leer PID del servidor desde pid-file
    // =============================

    std::string pid_path = get_pid_file_path();
    auto maybe_pid = read_server_pid_from_file(pid_path);

    if (!maybe_pid.has_value()) {
        std::cerr << "backup: error leyendo PID del servidor: "
                  << maybe_pid.error().what() << "\n";
        return 1;
    }

    pid_t server_pid = maybe_pid.value();

    if (!is_server_running(server_pid)) {
        std::cerr << "backup: error: el servidor no está ejecutándose\n";
        return 1;
    }

    // =============================
    // MODI: instalar manejadores para recibir resultado
    // =============================
    struct sigaction sa{};
    sa.sa_handler = handler_backup_result;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    sigaction(SIGUSR1, &sa, nullptr);
    sigaction(SIGUSR2, &sa, nullptr);

    // =============================
    // 5. Bloquear SIGPIPE para FIFO rota
    // =============================
    sigset_t s;
    sigemptyset(&s);
    sigaddset(&s, SIGPIPE);
    if (sigprocmask(SIG_BLOCK, &s, nullptr) == -1) {
        std::cerr << "backup: error bloqueando SIGPIPE: " << strerror(errno) << "\n";
        return 1;
    }

    // =============================
    // 6. Abrir FIFO para escritura
    // =============================

    std::string fifo_path = get_fifo_path();

    int fifo_fd = open(fifo_path.c_str(), O_WRONLY);
    if (fifo_fd == -1) {
        std::cerr << "backup: error abriendo FIFO para escritura: "
                  << strerror(errno) << "\n";
        return 1;
    }

    // =============================
    // 7. Convertir ruta a absoluta
    // =============================

    auto abs_res = get_absolute_path(archivo);
    if (!abs_res.has_value()) {
        std::cerr << "backup: error convirtiendo ruta a absoluta: "
                  << abs_res.error().what() << "\n";
        close(fifo_fd);
        return 1;
    }

    std::string path_abs = abs_res.value();
    std::string to_write = path_abs + "\n";

    // =============================
    // 8. Escribir ruta en FIFO
    // =============================

    const char* buf = to_write.c_str();
    size_t total = to_write.size();
    size_t written = 0;
    while (written < total) {
        ssize_t w = write(fifo_fd, buf + written, total - written);
        if (w == -1) {
            if (errno == EINTR) continue;
            std::cerr << "backup: error escribiendo en FIFO: " << strerror(errno) << "\n";
            close(fifo_fd);
            return 1;
        }
        written += w;
    }

    // =============================
    // 9. Enviar señal SIGUSR1 al servidor
    // =============================
    if (kill(server_pid, SIGUSR1) == -1) {
        std::cerr << "backup: error enviando señal al servidor: "
                  << strerror(errno) << "\n";
        close(fifo_fd);
        return 1;
    }

    // =============================
    // MODI: esperar resultado del servidor
    // =============================
    off_t file_size = lseek(open(archivo.c_str(), O_RDONLY), 0, SEEK_END);
    close(open(archivo.c_str(), O_RDONLY));
    if (file_size < 0) file_size = 1; // evitar 0
    unsigned int wait_time = static_cast<unsigned int>(file_size / 1024 + 1); // segundos aproximados
    unsigned int slept = 0;
    while (slept < wait_time && backup_result == 0) {
        sleep(1);
        slept++;
    }

    close(fifo_fd);

    if (backup_result == 1) {
        std::cout << "backup: archivo " << path_abs << " respaldado correctamente\n";
    } else if (backup_result == 2) {
        std::cout << "backup: error al respaldar " << path_abs << "\n";
    } else {
        std::cout << "backup: tiempo de espera excedido sin respuesta del servidor\n";
    }

    return 0;
}

//g++ -std=c++23 -O2 backup.cpp -o backup
//export BACKUP_WORK_DIR=~/UNI/1Cuatri_2º/SSOO/practica_sockets/segunda_entrega/work-backup/
//./backup prueba.txt
