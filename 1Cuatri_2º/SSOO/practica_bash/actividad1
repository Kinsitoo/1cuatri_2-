#!/usr/bin/env bash

# sysinfo - Un script que informa del estado del sistema


##### Constantes


TITLE="Información del sistema para $HOSTNAME"
RIGHT_NOW=$(date +"%x %r%Z")
TIME_STAMP="Actualizada el $RIGHT_NOW por $USER"

##### Estilos

TEXT_BOLD=$'\x1b[1m'
TEXT_GREEN=$'\x1b[32m'
TEXT_RESET=$'\x1b[0m'

##### Funciones

system_info()
{
  echo "${TEXT_ULINE}Versión del sistema${TEXT_RESET}"
  echo
  uname -a
}


show_uptime()
{
  echo "${TEXT_ULINE}Tiempo de encendido del sistema$TEXT_RESET"
  echo
  uptime
  echo
}


drive_space()
{
  echo "${TEXT_ULINE}Espacio ocupado en las particiones$TEXT_RESET"
  echo
  df
  echo
}


home_space()
{
  echo
  echo "${TEXT_ULINE}Muestra espacio ocupado dependiendo si eres root o no$TEXT_RESET"
  if [ $USER != root ]; then
    du -s /home/$USER;
  elif [ $USER == root ]; then 
    du -h /home/* | sort -nr; 
  fi

}

##### Programa principal

cat << _EOF_
$TEXT_BOLD$TITLE$TEXT_RESET

$TEXT_GREEN$TIME_STAMP$TEXT_RESET
_EOF_

system_info
show_uptime
drive_space
home_space

