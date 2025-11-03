#!/bin/env bash

#User_files muestra por usuario conectado, el numero de archvos REG abiertos

show_help() {

  echo "Uso: $0 [-h | --help] [-u user1 user2...] [-d] [-s] [-o]"

}

error_exit() {

  echo "Error: $1" >&2
  exit 1

}

User_files(){

  use_dir=false
  if [ -n "$USER_FILES_DIR" ]; then
    if [ ! -d "$USER_FILES_DIR" ]; then
      error_exit "USER_FILES_DIR='$USER_FILES_DIR' no es un directorio valido"
    fi
    use_dir=true
  fi

  local connected_users=$(who | awk '{print $1}' | sort -u)

  if [[ $default == true ]]; then
    echo "Usuarios Conectados: "
    for u in $connected_users; do 
      if [[ "$use_dir" == false ]]; then
      count=$(lsof -u $u 2>/dev/null | awk '$5 == "REG"' | wc -l)
      uid=$(id -u $u 2>/dev/null || echo "N/A")
      else
      count=$(lsof -a -u "$u" +D "$USER_FILES_DIR" 2>/dev/null | awk '$5 == "REG"' | wc -l)
      fi
      pid=$(ps -u $u pid= --sort=start_time 2>/dev/null | head -n1 | tr -d ' ')
      pid=${pid:-NA}  

      echo "User: $u Ficheros: $count UID: $uid PID: $pid"
    done
  fi

  if [[ $D == true ]]; then
    lsof -a -u "$connected_users" 2>/dev/null | awk '$5 == "REG" {print $9}'
  fi

  if [[ $OFFLINE == true ]]; then
    echo "Usuarios NO conectados: "
    users_disconected=$(cat /etc/passwd | tr ":" " " | awk '{print $1}')
    valid_users=$(comm -3 <(echo "$connected_users" | sort ) <(echo "$users_disconected" | sort) | tr -d '\t')
    for u in $valid_users; do
      uid=$(id -u $u 2>/dev/null || echo "N/A")
      count=$(lsof -u $u 2>/dev/null | awk '$5 == "REG"' | wc -l)
      pid=$(ps -u $u pid= --sort=start_time 2>/dev/null | head -n1 | tr -d ' ')
      pid=${pid:-NA}
      echo "Usuario: $u Ficheros: $count UID: $uid PID: $pid"
    done
  fi

  if [[ $ORDENAR == true ]]; then
    for u in $valid_users; do 
      uid=$(id -u $u 2>/dev/null || echo "N/A")
      if [[ "$use_dir" == false ]]; then
      count=$(lsof -u $u 2>/dev/null | awk '$5 == "REG"' | wc -l)
      else
      count=$(lsof -a -u "$u" +D "$USER_FILES_DIR" | awk '$5 == "REG"' | wc -l)
      fi
      pid=$(ps -u $u pid= --sort=start_time 2>/dev/null | head -n1 | tr -d ' ')
      pid=${pid:-NA}  

      echo "User: $u Ficheros: $count UID: $uid PID: $pid" | sort -r
    done
  fi

  if [[ $USAR_USUARIOS == true ]]; then
    Listar_usuarios_especificados="$USUARIOS_IN"
  else
    Listar_usuarios_especificados=$($connected_users)
  fi
  
  for u in $LISTA_USUARIOS; do
  # Validar que el usuario existe (opcional)
    if ! id "$u" &>/dev/null; then
      echo "Advertencia: usuario '$u' no existe. Se omite." >&2
      continue
    fi

  # Contar archivos REG abiertos
    if [ $use_dir == true ]; then
      count=$(lsof -a -u "$u" +D "$OPEN_FILES_FOLDER" 2>/dev/null | awk '$5 == "REG"' | wc -l)
    else
      count=$(lsof -u "$u" 2>/dev/null | awk '$5 == "REG"' | wc -l)
    fi

  # Obtener UID y PID más antiguo
    uid=$(id -u "$u" 2>/dev/null)
    pid=$(ps -u "$u" -o pid= --sort=start_time 2>/dev/null | head -n1 | tr -d ' ')
    pid=${pid:-NA}

    echo "Usuario: $u, Ficheros: $count, UID: $uid, PID: $pid"
    done

}



default=true
D=false
OFFLINE=false
ORDENAR=false
USAR_USUARIOS=false
USUARIOS_IN=""

while [[ $# -gt 0 ]]; do
  case $1 in 
    -h | --help)
      HELP=true
      shift
      ;;
    -d)
      default=false
      D=true
      shift
      ;;
    -o | --offline)
      default=false
      OFFLINE=true
      shift
      ;;
    -u)
      default=false
      USAR_USUARIOS=true
      shift
      while [ $# -gt 0 ] && [ "$1" != "-"* ]; do
        if [ -z "$USUARIOS_IN" ]; then
          "$USUARIOS_IN"="$1"                       
        else
          "$USUARIOS_IN" = "$USUARIOS_IN $1"
        fi
        shift
      done
      ;;
    -s)
      default=false
      ORDENAR=true
      shift
      ;;
    *)
      error_exit "Opcion no soportado: $1"
      HELP=true
      ;;
  esac
done

if [ "$HELP" == true ]; then

  show_help
  exit 0

fi

User_files