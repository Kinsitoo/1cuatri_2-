#!/usr/bin/env bash

# ------------------------------------------------------------
# open_files
# Autor: [Tu nombre]
# Descripción: Lista usuarios y número de archivos regulares abiertos,
#              con múltiples opciones de filtrado y ordenación.
# ------------------------------------------------------------

# ---------------- Constantes --------------------
TITLE="open_files"
TEXT_BOLD=$'\x1b[1m'
TEXT_RESET=$'\x1b[0m'

# ---------------- Funciones --------------------

error_exit() {
  echo "Error: $1" >&2
  exit 1
}

show_help() {
  cat << _EOF_
Uso: $0 [-h | --help] [-f regexp] [-o | --offline] [-u user1 user2 ...] [-s | --sort]

Sin opciones: muestra usuarios conectados (who) con:
  - número de ficheros REG abiertos
  - UID
  - PID del proceso más antiguo

Opciones:
  -h, --help        Muestra esta ayuda.
  -f regexp         Filtra archivos cuya ruta coincida con la expresión regular.
  -o, --offline     Muestra solo usuarios NO conectados (no en who).
  -u user1 ...      Filtra por lista arbitraria de usuarios.
  -s, --sort        Ordena por número de archivos abiertos (descendente).

Variable de entorno:
  OPEN_FILES_FOLDER: si está definida y es un directorio válido,
                     solo se cuentan archivos dentro de él (y subdirectorios).

_EOF_
}

# Verifica que lsof y ps estén disponibles
check_dependencies() {
  command -v lsof >/dev/null || error_exit "'lsof' no está instalado."
  command -v ps >/dev/null || error_exit "'ps' no está disponible."
}

# Convierte una lista de usuarios a formato usable
validate_users() {
  local -n arr=$1
  local valid=()
  for u in "${arr[@]}"; do
    if id "$u" &>/dev/null; then
      valid+=("$u")
    else
      echo "Advertencia: usuario '$u' no existe. Se omitirá." >&2
    fi
  done
  arr=("${valid[@]}")
}

# Función principal que genera la salida
process_users() {
  local offline="$1"       # true/false
  local regexp="$2"        # patrón opcional
  local sort_by_count="$3" # true/false
  local -a user_filter=("${@:4}") # lista opcional de usuarios

  local use_dir=false
  if [ -n "${OPEN_FILES_FOLDER}" ]; then
    if [ ! -d "$OPEN_FILES_FOLDER" ]; then
      error_exit "OPEN_FILES_FOLDER='$OPEN_FILES_FOLDER' no es un directorio válido."
    fi
    use_dir=true
  fi

  # Obtener usuarios conectados
  local connected_users
  mapfile -t connected_users < <(who | awk '{print $1}' | sort -u)

  # Determinar conjunto base de usuarios a procesar
  local -a candidates=()
  if [ ${#user_filter[@]} -gt 0 ]; then
    # Solo los usuarios especificados
    candidates=("${user_filter[@]}")
  else
    # Todos los usuarios con archivos abiertos
    mapfile -t all_users < <(lsof 2>/dev/null | awk 'NR > 1 && $3 != "" {print $3}' | sort -u)
    candidates=("${all_users[@]}")
  fi

  # Filtrar según modo (conectado / no conectado)
  local -a target_users=()
  for u in "${candidates[@]}"; do
    local is_connected=false
    for c in "${connected_users[@]}"; do
      if [[ "$u" == "$c" ]]; then
        is_connected=true
        break
      fi
    done

    if [[ "$offline" == true && "$is_connected" == false ]] ||
       [[ "$offline" == false && "$is_connected" == true ]]; then
      target_users+=("$u")
    fi
  done

  # Si no hay usuarios, salir limpiamente
  if [ ${#target_users[@]} -eq 0 ]; then
    if [[ "$offline" == true ]]; then
      echo "No hay usuarios desconectados con archivos abiertos."
    else
      echo "No hay usuarios conectados con archivos abiertos."
    fi
    return
  fi

  # Recopilar datos
  local output_lines=()
  for u in "${target_users[@]}"; do
    # Construir comando lsof
    local lsof_args=(-u "$u")
    if [[ "$use_dir" == true ]]; then
      lsof_args=(-a -u "$u" +D "$OPEN_FILES_FOLDER")
    fi

    # Contar archivos REG que coincidan con regexp (si aplica)
    if [[ -n "$regexp" ]]; then
      count=$(lsof "${lsof_args[@]}" 2>/dev/null | awk -v f="$regexp" '$5 == "REG" && $NF ~ f' | wc -l)
    else
      count=$(lsof "${lsof_args[@]}" 2>/dev/null | awk '$5 == "REG"' | wc -l)
    fi

    # UID
    uid=$(id -u "$u" 2>/dev/null || echo "N/A")

    # PID del proceso más antiguo
    pid=$(ps -u "$u" -o pid= --sort=start_time 2>/dev/null | head -n1 | tr -d ' ')
    pid=${pid:-NA}

    output_lines+=("$count|$u|$uid|$pid")
  done

  # Ordenar y mostrar
  if [[ "$sort_by_count" == true ]]; then
    printf '%s\n' "${output_lines[@]}" | sort -t'|' -k1,1nr -k2,2
  else
    printf '%s\n' "${output_lines[@]}" | sort -t'|' -k2,2
  fi | while IFS='|' read -r count u uid pid; do
    echo "Usuario: $u, Ficheros: $count, UID: $uid, PID: $pid"
  done
}

# ---------------- Parseo de argumentos --------------------

# Variables de control
HELP=false
OFFLINE=false
SORT_BY_COUNT=false
REGEXP=""
USERS=()

# Parsear todos los argumentos
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      HELP=true
      shift
      ;;
    -o|--offline)
      OFFLINE=true
      shift
      ;;
    -s|--sort)
      SORT_BY_COUNT=true
      shift
      ;;
    -f)
      if [[ -z "$2" || "$2" == -* ]]; then
        error_exit "-f requiere una expresión regular como argumento."
      fi
      REGEXP="$2"
      shift 2
      ;;
    -u)
      shift
      while [[ $# -gt 0 && "$1" != -* ]]; do
        USERS+=("$1")
        shift
      done
      ;;
    *)
      error_exit "Opción no soportada: $1"
      ;;
  esac
done

# ---------------- Main --------------------

echo "${TEXT_BOLD}${TITLE}${TEXT_RESET}"

# Mostrar ayuda si se pide
if [[ "$HELP" == true ]]; then
  show_help
  exit 0
fi

# Verificar dependencias
check_dependencies

# Validar usuarios si se especificaron
if [ ${#USERS[@]} -gt 0 ]; then
  validate_users USERS
  if [ ${#USERS[@]} -eq 0 ]; then
    error_exit "Ninguno de los usuarios especificados es válido."
  fi
fi

# Ejecutar lógica principal
process_users "$OFFLINE" "$REGEXP" "$SORT_BY_COUNT" "${USERS[@]}"