#!/usr/bin/env bash

#Programa open_files
#Autor: Kin Daniel Fortuno Pontillas
#alu0101679112


#----------------Constantes--------------------

TITLE="Programa open_files"

#----------------Estilos-----------------------

TEXT_BOLD=$'\x1b[1m'
TEXT_GREEN=$'\x1b[32m'
TEXT_RESET=$'\x1b[0m'

#------------------Variables-------------------

users=$(who | awk '{print $1}' | sort | uniq) #Listar usuarios sin duplicados y ordenados.
uid=$(id -u "$users")
pid=$(ps -u "$users" --sort=start_time -o pid= | head -n 1)
filtro="$2"

#NO se especifica opcion



list_users(){

  echo "$TEXT_BOLD Usuarios conectados y numero de ficheros abiertos $TEXT_RESET"

  if [ -n "$OPEN_FILES_FOLDER" ]; then
    echo "Variable OPEN_FILES_FOLDER definida: $OPEN_FILES_FOLDER"

    if [ ! -d "$OPEN_FILES_FOLDER" ]; then 
      echo "Error: Ruta no existe o no es un directorio" >&2
      exit 1
    
    fi

    echo
    echo "Solo se contaran los ficheros dentro de ese directorio."
    echo
    use_dir=true
    
  else

    echo "Variable OPEN_FILES_FOLDER no definida. Se contarán todos los ficheros abiertos."
    echo
    use_dir=false

  fi

  for u in $users; do
    if [ "$use_dir" = true ]; then
      count=$(lsof -a -u "$u" +D "$OPEN_FILES_FOLDER" 2>/dev/null | awk '$5 == "REG"' | wc -l)
    else
      count=$(lsof -u "$u" 2>/dev/null | awk '$5 == "REG"' | wc -l)
    fi
  
  echo "Usuario: $u $count ficheros regulares abiertos"
  echo "Usuario: $u, UID: $uid, PID: $pid"
  done
}

show_help() {

  echo "Uso: $0 [-h] [-help] [-f regexp] [-o] [--offline] [-u user1 user2 ...] [-s] [-sort]"
  echo ""
  echo "-h) y -help) : Muestra ayuda"
  echo "-f) Filtra la salida de lsof en base a la ultima columna."
  echo
    
}

filter(){

  if [[ -z "$filtro" ]]; then
    echo "No has introducido ninguna palabra a filtrar" >&2
    exit 1
  else
    echo "Se va a filtrar la salida en base a la ultima columna (usando el filtro: $filtro)"
    lsof 2>/dev/null | awk '{print $NF}' | grep -E "$filtro"
    exit 0
  fi
}


cat << _EOF_
$TEXT_BOLD$TITLE$TEXT_RESET
_EOF_

if [[ -z "$1" ]]; then
  list_users
  else
    case "$1" in
      -h) 
        show_help
        ;;
      -help)
        show_help
        ;;
      -f)
        filter
        ;;
      *) 
        echo "Opcion no soportada" >&2
        exit 1
    esac    
fi

#list_users