#include <iostream>
#include <unistd.h>
#include <sys/stat.h>
#include <libgen.h>
#include <string>
#include <cstring>
#include <expected>
#include <system_error>
#include <unistd.h>
#include <fcntl.h>

bool check_args(int argc, char* argv[]) {

  if(argc != 3) {

    std::cerr << "Error en el numero de argmumentos" << std::endl;
    return false;

  }

  struct stat info_archivos_1;
  struct stat info_archivos_2;

  if(stat(argv[1], &info_archivos_1) != 0) {

    std::cerr << "Error al obtener la informacion del archivo 1" << std::endl;
    return false;

  }

  if(stat(argv[2], &info_archivos_2) != 0) {

    std::cerr << "Error al obtener la informacion del archivo 2" << std::endl;
    return false;

  }

  if((info_archivos_1.st_ino == info_archivos_2.st_ino) && (info_archivos_1.st_dev == info_archivos_2.st_dev)) {

    std::cout << "Los dos archivos son el mismo" << std::endl;
    return true;

  }

}

bool is_directory(const std::string& path) {

  struct stat info_archivo;

  if(stat(path, &info_archivo) != 0) {

    std::cerr << "Error al obtener la informacion del archivo";
    return false;

  }

  return S_ISDIR(info_archivo.st_mode);

}

std::string get_filename(const std::string& path) {

  char* copy_path = new char[path.size() + 1];
  strcpy(copy_path, path.c_str());

  char* bname = basename(copy_path);

  std::string resultado(bname);
  delete[] copy_path;
  return resultado;

}

std::expected<void, std::system_error>
copy_file(const std::string& src, const std::string& dst) {

  int src_fd = open(src, O_RDONLY);
  if(src_fd == -1) {

    return std::unexpected(std::system_error(errno, std::system_category(), "Error al abrir al archivo de origenn");
    close(src_fd);
  }

  int dst_fs = open(dst, O_CREAT | O_TRUNC | O_APPEND, 0644);
  if(dst_fd == -1) {

    return std::unexpected(std::system_error(errno, std::system_category(), "Error al abrir el archivo de destino"));
    close(src_fd);
    close(dst_fd);

  }

  char buf[65536];

  while(true) {

    ssize_t bytes_read = read(src_fd, buf.data() , buf.size())
    if(bytes_read == -1) {

      close(src_fd):
      close(dst_fd);
      return std::unexpected(std::system_error(errno, std::system_category(), "Error al leer el archivo"));

    }

    if(bytes_read == 0) break;

    ssize_t bytes_written = 0;
    while(bytes_written < bytes_read) {
      ssize_t result = write(dst_fd, buf.data() + bytes_written, bytes_read - bytes_written);
      
      if(result == -1) {

        close(src_fd);
        close(dst_fd);
        return std::unexpected(std::system_error(errno, std::system_category(), "Error al escribir en el archivo"));

      }
      bytes_written += result;
      
    }

  }

  close(dst_fd);
  close(src_fd);
  return {};

}

int main(int argc, char* argv[]) [

  check_args(argc, argv);

]