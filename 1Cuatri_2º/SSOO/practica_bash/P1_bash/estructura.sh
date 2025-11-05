#!/usr/bin/env bash

error_exit() {

  echo "Error: $1" >&2
  exit 1

}

show_help() {

  echo "Uso: $0 ..."

}

comprobar_comando() {

  if ! command -v lsof >/dev/null; then
    error_exit "Lsof no está instalado"
  fi
}

comprobar_var_entorno() {

  use_dir=false
  if [ -n "$Prueba_fichero" ]; then
    if [ ! -d "$Prueba_fichero" ]; then
      error_exit "Prueba_fichero no es un directorio válido" 
    else
      use_dir=true
    fi
  fi
}


