#!/bin/bash

if [[ "$#" -lt 1 ]] || [[ "$#" -ge 2 ]]; then
	echo "Sintaxis erronea: ./cambiarGrupo.sh <usuario>"
else
	usermod -G tecnicos -a $1
fi

exit 0
