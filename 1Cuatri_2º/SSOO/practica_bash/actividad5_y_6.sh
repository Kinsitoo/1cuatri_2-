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

interactive() {
    # Preguntar si mostrar en pantalla
    dialog --title "Mostrar" --yesno "¿Quieres que se muestre el informe en pantalla?" 6 40
    respuesta1=$?

    if [ $respuesta1 -eq 0 ]; then
        # Mostrar en pantalla
        clear
        system_info
        show_uptime
        drive_space
        home_space
        exit 0

    elif [ $respuesta1 -eq 1 ]; then
        # Guardar en archivo
        local tmpfile=$(mktemp)
        dialog --title "Guardar" --inputbox "Introduzca el nombre del archivo [~/sysinfo.txt]:" 6 40 2> "$tmpfile"
        local filename=$(cat "$tmpfile")
        rm -f "$tmpfile"

        # Si el usuario no escribió nada, usar valor por defecto
        if [ -z "$filename" ]; then
            filename="$HOME/sysinfo.txt"
        fi

        # Comprobar si existe
        if [ -f "$filename" ]; then
            dialog --title "Sobreescribir" --yesno "El archivo existe, ¿desea sobreescribir?" 6 70
            local respuesta2=$?
            if [ $respuesta2 -ne 0 ]; then
                clear
                exit 0  # No sobrescribir → salir
            fi
          clear
        fi

        # Guardar (sobrescribir)
        {
            system_info
            show_uptime
            drive_space
            home_space
        } > "$filename"

        dialog --msgbox "Informe guardado en:\n$filename" 6 40
        clear
        exit 0
    fi
}



#Modificación Semana 4

contar_root_procesos()
{
  echo
  echo "${TEXT_BOLD}Numero de procesos que está ejecutando root actualmente$TEXT_RESET"

  # Contar procesos cuyo propietario es root
  echo "El usuario 'root' está ejecutando: "

  ps -u 'root' | wc -l

}

#Modificacion Semana 5

contar_procesos_usuario() {
  usuario="$1"

  # Comprobar si se ha pasado un usuario
  if [[ -z "$usuario" ]]; then
    echo "Error: Debes especificar un nombre de usuario tras la opción -fu" >&2
    exit 1
  fi

  # Comprobar si el usuario existe en el sistema
  if ! id "$usuario" &>/dev/null; then
    echo "Error: El usuario '$usuario' no existe en el sistema." >&2
    exit 1
  fi

  echo

  # Contar procesos del usuario
  num_proc=$(ps -u "$usuario" --no-headers | wc -l)

  # Proceso con más uso de CPU
  top_proc=$(ps -u "$usuario" --sort=-%cpu -o comm= | head -n 1)

  echo "Número total de procesos: $num_proc"
  if [[ -n "$top_proc" ]]; then
    echo "Proceso que más CPU consume: $top_proc"
  else
    echo "El usuario no tiene procesos en ejecución."
  fi
  echo
}

#Opciones por defecto.
  interactive=0
  filename=~/sysinfo.txt

##### Programa principal

usage() {
  echo "usage: sysinfo [-f filename] [-i] [-h] [-fu usuario]"
}

error_exit() {

  

}

write_page() {

cat << _EOF_
$TEXT_BOLD$TITLE$TEXT_RESET

$(system_info)
$(show_uptime)
$(drive_space)
$(home_space)

$TEXT_GREEN$TIME_STAMP$TEXT_RESET
_EOF_
}

#system_info
#show_uptime
#drive_space
#home_space
#contar_root_procesos

#Procesar linea de comandos del script para leer las opciones 

#!/bin/bash

# Inicializar variables
interactive=0
filename="$HOME/sysinfo.txt"   # valor por defecto para -f

while [ "$1" != "" ]; do
    case $1 in
        -f | --file )
            shift
            if [ "$1" = "" ]; then
                echo "Error: -$1 requiere un nombre de archivo" >&2
                exit 1
            fi
            filename="$1"
            ;;
        -i | --interactive )
            interactive=1
            ;;
        -h | --help )
            usage
            exit 0
            ;;
        -fu ) #Modi Semana 5
            shift 
              if [ -z "$1" ]; then
                echo "Error: La opción -fu requiere un nombre de usuario" >&2
                exit 1
              fi
            contar_procesos_usuario "$1"
            exit 0
            ;;    
        -* )
            echo "Opción no válida: $1" >&2
            usage
            exit 1
            ;;      
        * )
            # Cualquier argumento no reconocido es un error
            echo "Argumento no válido: $1" >&2
            usage
            exit 1
            ;;
    esac
    shift
done

if [ "$interactive" -eq 1 ]; then
    interactive  
else
    # Modo NO interactivo: Generar el informe del sistema y guardarlo en el archivo indicado en $filename
    echo "Se ha guardado el informe del sistema en "$filename" "
    write_page > $filename
    exit 0
fi

