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

users=$(who | awk '{print $1}' | sort | uniq)
uid=$(id -u "$users")
pid=$(ps -u "$users" --sort=start_time -o pid= | head -n 1)

#NO se especifica opcion



list_users(){

  echo "$TEXT_BOLD Usuarios conectados y numero de ficheros abiertos $TEXT_RESET"

  for u in $users; do
  count=$(lsof -u "$u" | awk '$4 ~ /[0-9]/ && $5 == "REG" ' | wc -l)

  echo "Usuario: $u $count ficheros regulares abiertos"
  echo "Usuario: $u, UID: $uid, PID: $pid"
  done
}

show_help() {
  echo "Uso: $0 [-h] [-help] [-f regexp] [-o] [--offline] [-u user1 user2 ...] [-s] [-sort]"
  echo ""
  echo "-h) y -help) : Muestra ayuda"
  echo 
    
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
      *) 
        echo "Opcion no soportada"
        exit 1
    esac    
fi

#list_users