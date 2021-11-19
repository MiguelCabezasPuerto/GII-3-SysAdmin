#!/bin/bash

if [[ "$#" -lt 2 ]] || [[ "$#" -ge 3 ]]; then
	echo "Sintaxis erronea: ./crearCopiaMariaDB.sh <usuariosBaseDatos> <baseDatos>"
else
	mysqldump --user=$1 -p $2 > copiaMariaDB.sql
fi

exit 0
