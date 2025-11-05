#!/usr/bin/env bash
#sin opciones mostrara una lista de usuarios que existen en el sistema con el numero de procesis que tiene ejecutado ese usuario ordenado por el user
#-u) Seguida de uno o varios nombres de usuario, se mostrara la informacion solo para los usuarios indicados
#-m tiempo) Se contabilizaran solo los procesos que tengan mas de ese tiempo de cpu consumido, siguiendo el mismo listado que en el apartado 1.
#-n) Se ordenará por el numero de procesos que esta ejecutando cada usuario.

#Preparacion para la prueba de bash

process_users() {
  if [ "$sin_opciones" == true ]; then
    ps -eo user= | sort | uniq -c | awk '{print $2, $1}' | sort
  elif [ "$sin_opciones" == true ] && [ "$ordenar_por_numero" == true ]; then
    ps -eo user= | sort | uniq -c | awk '{print $2, $1}' | sort -k2 -nr
  fi

  if [ "$filtrar_por_usuarios" == true ]; then
    if [ $# -eq 0 ]; then 
      usage
      exit 1
    fi
  else
    for u in "$@"; do
      count=$(ps -u "$u" --no-headers 2>/dev/null | wc -l)
      echo "$u $count"
    done
  fi

  if [ "$filtrar_por_tiempo" == true ]; then
    tiempo="$1"
    echo "Procesos con más de $tiempo de CPU:"
    ps -eo user,etime,comm --sort=user | awk -v t="$tiempo" '$2 > t {print $1, $2, $3}'  
  fi
}

usage() {
  echo "Uso: $0 [-u usuario1 ...] [-m tiempo] [-n]"
}

# ❗ Corregido: SIN espacios en las asignaciones
sin_opciones=true
filtrar_por_usuarios=false
filtrar_por_tiempo=false
ordenar_por_numero=false

# Variables para guardar argumentos
USUARIOS=()
TIEMPO_CPU=""

#main

while [ $# -gt 0 ]; do
  case "$1" in
    -u)
      filtrar_por_usuarios=true
      sin_opciones=false
      shift
      while [ $# -gt 0 ] && [ "$1" != "-"* ]; do
        USUARIOS+=("$1")
        shift
      done
      ;;
    -m)
      if [ -z "$2" ] || [ "$2" = "-"* ]; then
        echo "Error: -m requiere un valor de tiempo" >&2
        exit 1
      fi
      filtrar_por_tiempo=true
      sin_opciones=false
      TIEMPO_CPU="$2"
      shift 2
      ;;
    -n)
      ordenar_por_numero=true
      shift
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

# Llamar a process_users con los datos recogidos
if [ "$filtrar_por_usuarios" == true ]; then
  process_users "${USUARIOS[@]}"
elif [ "$filtrar_por_tiempo" == true ]; then
  process_users "$TIEMPO_CPU"
else
  process_users
fi