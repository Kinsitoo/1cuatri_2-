#!/usr/bin/env bash

# Programa open_files
# Autor: Kin Daniel Fortuno Pontillas
# alu0101679112

# ---------------- Constantes --------------------
TITLE="Programa open_files"

# ---------------- Estilos -----------------------
TEXT_BOLD=$'\x1b[1m'
TEXT_GREEN=$'\x1b[32m'
TEXT_RESET=$'\x1b[0m'

# ---------------- Funciones --------------------

show_help() {
  cat << _EOF_
Uso: $0 [-h] [-help] [-f regexp] [-o] [--offline] [-u user1 user2 ...] [-s] [-sort]

  -h, -help     : Muestra esta ayuda
  -f regexp     : Filtra la salida de lsof por la última columna (ruta del archivo)
  -o, --offline : Muestra archivos abiertos SOLO por usuarios NO conectados
  -u user1 ...  : (No implementado aún) Filtrar por usuarios específicos
  -s            : (No implementado aún) Listar usuarios de forma ordenada por el número de archivos abiertos

Sin opciones: muestra usuarios conectados y número de ficheros abiertos.
_EOF_
}

list_users() {
  echo "${TEXT_BOLD}Usuarios conectados y número de ficheros abiertos${TEXT_RESET}"

  local use_dir=false
  if [ -n "${OPEN_FILES_FOLDER}" ]; then
    echo "Variable OPEN_FILES_FOLDER definida: $OPEN_FILES_FOLDER"
    if [ ! -d "$OPEN_FILES_FOLDER" ]; then 
      echo "Error: Ruta no existe o no es un directorio" >&2
      exit 1
    fi
    echo
    echo "Solo se contarán los ficheros dentro de ese directorio."
    echo
    use_dir=true
  else
    echo "Variable OPEN_FILES_FOLDER no definida. Se contarán todos los ficheros abiertos."
    echo
  fi

  local connected_users
  connected_users=$(who | awk '{print $1}' | sort -u)

  for u in $connected_users; do
    if [ "$use_dir" = true ]; then
      count=$(lsof -a -u "$u" +D "$OPEN_FILES_FOLDER" 2>/dev/null | awk '$5 == "REG"' | wc -l)
    else
      count=$(lsof -u "$u" 2>/dev/null | awk '$5 == "REG"' | wc -l)
    fi

    # Obtener UID y PID del proceso más antiguo del usuario
    uid=$(id -u "$u" 2>/dev/null || echo "N/A")
    pid=$(ps -u "$u" -o pid= --sort=start_time 2>/dev/null | head -n 1 | tr -d ' ')
    pid=${pid:-N/A}

    echo "Usuario: $u, Ficheros: $count, UID: $uid, PID: $pid"
  done
}

filter_mode() {
  local filtro="$1"
  if [[ -z "$filtro" ]]; then
    echo "No has introducido ninguna palabra a filtrar" >&2
    exit 1
  fi
  echo "Se va a filtrar la salida en base a la última columna (filtro: $filtro)"
  lsof 2>/dev/null | awk '{print $NF}' | grep -E "$filtro"
}

offline_mode() {
  local filtro="$1"
  echo "${TEXT_BOLD}Usuarios NO conectados y sus archivos abiertos${TEXT_RESET}"

  # Usuarios conectados
  local connected
  connected=$(who | awk '{print $1}' | sort -u)

  # Todos los usuarios que tienen archivos abiertos (solo nombres de usuario)
  local all_users_with_files
  all_users_with_files=$(lsof 2>/dev/null | awk 'NR > 1 && $3 != "" {print $3}' | sort -u)

  local found=false
  for user in $all_users_with_files; do
    # ¿Está conectado?
    if ! echo "$connected" | grep -q "^$user$"; then
      found=true
      if [[ -n "$filtro" ]]; then
        # Filtrar archivos por expresión regular en la ruta
        files=$(lsof -u "$user" 2>/dev/null | awk -v f="$filtro" 'NR > 1 && $5 == "REG" && $NF ~ f {print $NF}' | sort -u)
      else
        files=$(lsof -u "$user" 2>/dev/null | awk 'NR > 1 && $5 == "REG" {print $NF}' | sort -u)
      fi

      if [ -z "$files" ]; then
        echo "Usuario: $user → NA"
      else
        echo "Usuario: $user"
        echo "$files" | while read -r file; do
          [ -n "$file" ] && echo "  - $file"
        done
      fi
      echo
    fi
  done

  if [ "$found" = false ]; then
    echo "No se encontraron usuarios desconectados con archivos abiertos."
  fi
}

# ---------------- Main --------------------

cat << _EOF_
${TEXT_BOLD}${TITLE}${TEXT_RESET}
_EOF_

# Si no hay argumentos
if [[ $# -eq 0 ]]; then
  list_users
  exit 0
fi

# Parsear opciones
case "$1" in
  -h | -help)
    show_help
    ;;
  -f)
    if [[ -z "$2" ]]; then
      echo "Error: -f requiere un argumento" >&2
      exit 1
    fi
    filter_mode "$2"
    ;;
  -o | --offline)
    offline_mode "$2"  # permite -o -f "patrón" o solo -o
    ;;
  *)
    echo "Opción no soportada: $1" >&2
    exit 1
    ;;
esac