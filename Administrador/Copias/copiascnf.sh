#!/bin/bash

if [[ "$#" -lt 3 ]] || [[ "$#" -ge 4 ]]; then
    echo "Sintaxis erronea: ./copiascnf.sh <puerto> <usuario> <IP>"
else
    ssh-copy-id -i ~/.ssh/id_rsa.pub -p $1 $2@$3
fi

exit 0
