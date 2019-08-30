#!/bin/bash

nr_cifs_mounts=$(mount -v | grep -c "cifs")

if [ ${nr_cifs_mounts} ==  0 ]; then
    echo "CIFS Filesystems are no longer mounted !"
    exit 2
elif [ ${nr_cifs_mounts} -gt 0 ]; then
    echo "${nr_cifs_mounts} CIFS Filesystems are mounted."
    exit 0
fi

exit 3

