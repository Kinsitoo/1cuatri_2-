// backup.cpp
#include "common.hpp"

#include <iostream>
#include <signal.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <cstring>

int main(int argc, char* argv[]) {
    if (argc != 2) {
        std::cerr << "backup: uso: backup ARCHIVO\n";
        return 1;
    }
    std::string archivo = argv[1];

    std::string work_dir = get_work_dir_path();
    if (work_dir.empty()) {
        std::cerr << "backup: error: BACKUP_WORK_DIR no está definida\n";
        return 1;
    }

    // verificar que archivo existe y es regular
    if (!file_exists(archivo)) {
        std::cerr << "backup: error: el archivo " << archivo << " no existe\n";
        return 1;
    }
    if (!is_regular_file(archivo)) {
        std::cerr << "backup: error: " << archivo << " no es un archivo regular\n";
        return 1;
    }

    // leer PID del servidor
    std::string pid_path = get_pid_file_path();
    auto maybe_pid = read_server_pid_from_file(pid_path);
    if (!maybe_pid.has_value()) {
        std::cerr << "backup: error leyendo PID del servidor: " << maybe_pid.error().what() << "\n";
        return 1;
    }
    pid_t server_pid = maybe_pid.value();
    if (!is_server_running(server_pid)) {
        std::cerr << "backup: error: el servidor no está ejecutándose\n";
        return 1;
    }

    // bloquear SIGPIPE
    sigset_t s;
    sigemptyset(&s);
    sigaddset(&s, SIGPIPE);
    if (sigprocmask(SIG_BLOCK, &s, nullptr) == -1) {
        std::cerr << "backup: error bloqueando SIGPIPE: " << strerror(errno) << "\n";
        return 1;
    }

    // abrir FIFO para escritura (se bloqueará hasta que server esté leyendo)
    std::string fifo_path = get_fifo_path();
    int fifo_fd = open(fifo_path.c_str(), O_WRONLY);
    if (fifo_fd == -1) {
        std::cerr << "backup: error abriendo FIFO para escritura: " << strerror(errno) << "\n";
        return 1;
    }

    // convertir a ruta absoluta
    auto abs_res = get_absolute_path(archivo);
    if (!abs_res.has_value()) {
        std::cerr << "backup: error convirtiendo ruta a absoluta: " << abs_res.error().what() << "\n";
        close(fifo_fd);
        return 1;
    }
    std::string path_abs = abs_res.value();
    std::string to_write = path_abs + "\n";
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

    // enviar señal SIGUSR1 al servidor
    if (kill(server_pid, SIGUSR1) == -1) {
        std::cerr << "backup: error enviando señal al servidor: " << strerror(errno) << "\n";
        close(fifo_fd);
        return 1;
    }

    close(fifo_fd);
    std::cout << "backup: solicitud enviada para " << path_abs << "\n";
    return 0;
}
