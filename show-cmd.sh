#!/bin/bash
if [ "$#" -ne 3 ]; then
    echo "	USAGE: $0 <host> <username> <file>"
    ls -1 semp/show*.xml | sed 's/^/		/'
    exit 0
fi
vmr=$1
user=$2
file=$3

curl -X POST -k -u $user https://$vmr:943/SEMP -d @$file
