#!/bin/bash

warning=$1
critical=$2

if [ -z ${warning} ] && [ -z ${critical} ]; then
    echo "$0 : Thresholds not set."
    exit 3
fi

if [ ${warning} -ge ${critical} ]; then
    echo "$0 : Warning threshold is greater than or equal to the Critical."
    exit 3
fi

filename="/proc/sys/fs/file-nr"

allocated_file_handles=$(cat ${filename} | cut -f1)

#
# No separate for a critical at this point ? Or should _this_ return a critical alert ?
#

if [ ${allocated_file_handles} -gt ${critical} ]; then
    echo "Critical: Number of allocated file handles is : ${allocated_file_handles}"
    exit 2
elif [ ${allocated_file_handles} -gt ${warning} ]; then
    echo "Warning: Number of allocated file handles is : ${allocated_file_handles}"
    exit 1
else
    echo "OK: Number of allocated file handles is : ${allocated_file_handles}"
    exit 0
fi

exit 3
