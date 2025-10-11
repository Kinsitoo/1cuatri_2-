#!/usr/bin/env bash

# sysinfo - Un script que informa del estado del sistema

#Autor: Kin Daniel Fortuno Pontillas
#alu0101679112

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
  echo
  echo "${TEXT_BOLD}Versión del sistema${TEXT_RESET}"
  echo
  uname -a
}


show_uptime()
{
  echo
  echo "${TEXT_BOLD}Tiempo de encendido del sistema$TEXT_RESET"
  echo
  uptime
  echo
}


drive_space()
{
  echo "${TEXT_BOLD}Espacio ocupado en las particiones$TEXT_RESET"
  echo
  df
  echo
}


home_space()
{
  echo
  echo "${TEXT_BOLD}Muestra espacio ocupado dependiendo si eres root o no$TEXT_RESET"
  if [ $USER != root ]; then
    echo "${TEXT_GREEN}No eres root${TEXT_RESET}"
    du -sh /home/$USER;
  elif [ $USER == root ]; then 
    echo "${TEXT_BOLD}Eres root${TEXT_RESET}"
    du -sh /home/*/ | sort -hr; 
  fi
}

#Modificación

contar_root_procesos()
{
  echo
  echo "${TEXT_BOLD}Numero de procesos que está ejecutando root actualmente$TEXT_RESET"

  # Contar procesos cuyo propietario es root
  echo "El usuario 'root' está ejecutando: "

  ps -u 'root' | wc -l

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
contar_root_procesos




