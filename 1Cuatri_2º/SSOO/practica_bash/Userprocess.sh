#!/usr/bin/env bash
#sin opciones mostrara una lista de usuarios que existen en el sistema con el numero de procesis que tiene ejecutado ese usuario ordenado por el user
#-u) Seguida de uno o varios nombres de usuario, se mostrara la informacion solo para los usuarios indicados
#-m tiempo) Se contabilizaran solo los procesos que tengan mas de ese tiempo de cpu consumido, siguiendo el mismo listado que en el apartado 1.
#-n) Se ordenará por el numero de procesos que esta ejecutando cada usuario.

#Preparacion para la prueba de bash

sin_opciones(){

  ps -eo user= | sort | uniq -c | awk '{print $2, $1}' | sort

}

filtrar_por_usuarios() {
  if [ $# -eq 0 ]; then 
    usage
    exit 1
  else
    for u in "$@"; do
      count=$(ps -u "$u" --no-headers 2>/dev/null | wc -l)
      echo "$u $count"
    done
  fi
}

filtrar_por_tiempo() {
  tiempo="$1"
  echo "Procesos con más de $tiempo de CPU:"
  ps -eo user,etime,comm --sort=user | awk -v t="$tiempo" '$2 > t {print $1, $2, $3}'
}

ordenar_por_numero() {
  sin_opciones | sort -k2 -nr
}

usage() {
  echo "Uso: $0 [-u usuario1 ...] [-m tiempo] [-n]"
}


#main

if [ $# -eq 0 ]; then
    sin_opciones
    exit 0
fi

while [ $# -gt 0 ]; do
  case "$1" in
    -u)
      shift
      filtrar_por_usuarios "$@"
      exit 0
      ;;
    -m)
      shift
      filtrar_por_tiempo "$1"
      exit 0
      ;;
    -n)
      ordenar_por_numero
      exit 0
      ;;
    *)
      usage
      exit 1
      ;;
    esac
    shift
done

