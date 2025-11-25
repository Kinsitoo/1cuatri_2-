#include <iostream>
#include <string>
#include <vector>
#include <cstring>
#include <expected>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>

bool is_directory(const std::string& path) {
    struct stat st;
    if (stat(path.c_str(), &st) == -1) {
        return false; // Si no existe, no es directorio
    }
    return S_ISDIR(st.st_mode);
}

std::string get_filename(const std::string& path) {
    size_t last_slash = path.find_last_of('/');
    if (last_slash == std::string::npos) {
        return path;
    }
    return path.substr(last_slash + 1);
}

bool same_file(const std::string& path1, const std::string& path2) {
    struct stat st1, st2;
    if (stat(path1.c_str(), &st1) == -1 || stat(path2.c_str(), &st2) == -1) {
        return false; // Si alguno no existe, no son el mismo
    }
    return (st1.st_dev == st2.st_dev) && (st1.st_ino == st2.st_ino);
}

bool check_args(int argc, char* argv[]) {
    if (argc != 3) {
        std::cerr << "copy: se deben indicar los archivos ORIGEN y DESTINO\n";
        return false;
    }

    const char* origen = argv[1];
    const char* destino = argv[2];

    // Comprobar que ambos archivos existen y no son el mismo
    if (same_file(origen, destino)) {
        std::cerr << "copy: el archivo ORIGEN y DESTINO no pueden ser el mismo\n";
        return false;
    }

    // Comprobar que el origen existe y es legible
    if (access(origen, R_OK) == -1) {
        std::cerr << "copy: error al acceder al archivo de origen: "
                  << std::strerror(errno) << "\n";
        return false;
    }

    return true;
}

std::expected <void, std::system_error> copy_file(
    const std::string& src_path,
    const std::string& dest_path
) {
    constexpr size_t BUFFER_SIZE = 64 * 1024; // 64 KiB
    std::vector<char> buffer(BUFFER_SIZE);

    int src_fd = open(src_path.c_str(), O_RDONLY);
    if (src_fd == -1) {
        return std::unexpected(std::system_error(
            errno, std::system_category(), "error al abrir el archivo de origen"
        ));
    }

    // Abrir destino: crear si no existe, truncar si existe
    int dest_fd = open(dest_path.c_str(), O_WRONLY | O_CREAT | O_TRUNC, 0666);
    if (dest_fd == -1) {
        close(src_fd);
        return std::unexpected(std::system_error(
            errno, std::system_category(), "error al abrir el archivo de destino"
        ));
    }

    while (true) {
        ssize_t bytes_read = read(src_fd, buffer.data(), buffer.size());
        if (bytes_read == -1) {
            close(src_fd);
            close(dest_fd);
            return std::unexpected(std::system_error(
                errno, std::system_category(), "error al leer el archivo de origen"
            ));
        }

        if (bytes_read == 0) break; // EOF

        ssize_t bytes_written = 0;
        while (bytes_written < bytes_read) {
            ssize_t result = write(dest_fd, buffer.data() + bytes_written,
                                   bytes_read - bytes_written);
            if (result == -1) {
                close(src_fd);
                close(dest_fd);
                return std::unexpected(std::system_error(
                    errno, std::system_category(), "error al escribir en el archivo de destino"
                ));
            }
            bytes_written += result;
        }
    }

    close(src_fd);
    close(dest_fd);
    return {};
}

//MODI: Antes de copiar, Informacion en pantalla del fichero a origen a copiar, Tamaño, tipo de archivo, y el nombre de archivo

void print_file_info(const std::string& path) {
    struct stat st;
    if (stat(path.c_str(), &st) == -1) {
        std::cerr << "copy: error al obtener información del archivo: "
                  << std::strerror(errno) << "\n";
        return;
    }

    std::cout << "=== Información del archivo ===\n";
    std::cout << "Nombre: " << get_filename(path) << "\n";
    std::cout << "Ruta completa: " << path << "\n";
    std::cout << "Tamaño: " << st.st_size << " bytes\n";

    std::cout << "Tipo: ";
    if (S_ISREG(st.st_mode)) std::cout << "Archivo regular\n";
    else if (S_ISDIR(st.st_mode)) std::cout << "Directorio\n";
    else if (S_ISLNK(st.st_mode)) std::cout << "Enlace simbólico\n";
    else if (S_ISCHR(st.st_mode)) std::cout << "Dispositivo de caracteres\n";
    else if (S_ISBLK(st.st_mode)) std::cout << "Dispositivo de bloques\n";
    else if (S_ISFIFO(st.st_mode)) std::cout << "FIFO/PIPE\n";
    else if (S_ISSOCK(st.st_mode)) std::cout << "Socket\n";
    else std::cout << "Tipo desconocido\n";

}



int main(int argc, char* argv[]) {
    if (!check_args(argc, argv)) {
        return 1;
    }
    

    std::string origen = argv[1];
    std::string destino = argv[2];

    print_file_info(origen);

    // Si destino es un directorio, ajustar ruta
    if (is_directory(destino)) {
        destino += "/" + get_filename(origen);
    }

    auto result = copy_file(origen, destino);
    if (!result.has_value()) {
        std::cerr << "copy: " << result.error().what() << "\n";
        return 1;
    }

    return 0;
}

//g++ -std=c++23 copy.cc -o copy