#!/usr/bin/env bash

#Nombre: Kin Daniel Fortuno Pontillas
#alu0101679112

	#Apartado 1a

error_exit() {

	echo "Error: $1" >&2
	exit 1

}

	#Apartado 1b

comprobacion_comando() {

	if ! command -v lsof 2>/dev/null; then 
		error_exit "Comando lsof no instalado"
	else 
		echo "Comando lsof instalado"
		echo
	fi
}

show_help() {

	echo "Uso: $0 [-h | --help] [-f filtro] [-e] [-r] [-u user1 user2...] "
	exit 0
}

Usuarios=$(cat /etc/passwd | tr ":" " " | awk '{print $1}') #TODOS los users

Programa_principal() {


	#Muestra la ayuda

	if [ "$HELP" == true ]; then
		show_help
	fi

	#Apartado 1c

	if [ $default == true ]; then
		for u in $Usuarios; do
			local count=$(lsof -u $u 2>/dev/null | awk 'NR > 1' | wc -l) 
			echo "$u $count" | awk '$2 > 0 {print $1, $2}'
		done | sort -k2n
	fi
	
	if [[ $Opcion_r == true ]]; then
		for u in $Usuarios; do
			local count=$(lsof -u $u 2>/dev/null | awk 'NR > 1' | wc -l) 
			echo "$u $count" | awk '$2 > 0 {print $1, $2}'
		done | sort -k2r
	fi

	if [ $Opcion_filtro == true ]; then
		for u in $Usuarios; do 
		local count=$(lsof -u $u 2>/dev/null | awk 'NR > 1' | awk '{print $9}' | grep -E "$filtro" | wc -l)
		echo "$u $count" | awk '$2 > 0 {print $1, $2}'
		done | sort -k2n
	fi

	if [ $Opcion_e == true ]; then
		if [ -z $OPEN_FILES_REG ]; then
			error_exit "OPEN_FILES_REG está vacía"
		fi
		for u in $Usuarios; do 
		local count=$(lsof -u $u 2>/dev/null | awk 'NR > 1' | awk '{print $9}' | grep -E "$filtro" | wc -l)
		echo "$u $count" | awk '$2 > 0 {print $1, $2}'
		done | sort -k2n
	fi
}

HELP=false
default=true
Opcion_filtro=false
filtro=""
Opcion_r=false
Opcion_e=false
OPEN_FILES_REG=""

while [ $# -gt 0 ]; do
	case $1 in
		-h | --help)
			default=false
			HELP=true
			shift
			;;
		-r)
			default=false
			help=false
			Opcion_r=true
			shift
			;;
		-e)
			default=false
			help=false
			Opcion_e=true
			filtro=$OPEN_FILES_REG
			;;
		-f)
			default=false
			Opcion_filtro=true
			if [[ $2 != "" ]] && [[ $2 != "-"* ]]; then
				filtro=$2
			else
				error_exit "No has introducido un filtro valido"
			fi
			shift	2 
			;;
		*)
			HELP=true
			default=false
			error_exit "Opcion reconocida: $1"
			shift
	esac
done


comprobacion_comando
Programa_principal