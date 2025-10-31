#!/usr/bin/env bash


usuario=$(who | awk '{print $1}' | sort -u)
uid=$(id -u $usuario)
pid=$(ps -u "$usuario" -o pid,etimes --no-headers | sort -k2,2nr | head -n1 | awk '{print $1}')
filtro=$"$1"

usage() {
  echo "Uso: $0 [-h] [--help] [-f regexp] [-o] [-u user1 user2...] [-s] [--sort]"

}

Sin_opcion(){

  for user in $usuario; do
    count=$(lsof -u $user -F t | grep -c '^tREG$')
    echo "Usuario: $user UID: $uid PID: $pid Count:$count"
  done
}

error_exit() {
  echo "Opcion no reconocida" >&2
  usage
  exit 1
}

filtro() {
  if [ $1 -eq 0 ]; then
    usage
    exit 1
  else
    lsof -u $usuario -F t | grep -c "$filtro"
  fi
}

if [ $# -eq 0 ]; then
  Sin_opcion
else
  while [ $1 -gt 0 ]; do
    case $1 in
      -h | --help)
        usage
        exit 0
        ;;
      -f)
        shift
        filtro
        exit 0
        ;;
      *)
        error_exit
        exit 1
        ;;
    esac
    shift
  done    
fi        