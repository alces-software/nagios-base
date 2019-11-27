#!/bin/bash

service=$1

#
# return a 1 (warning) if service is not active
#

return_string=$(systemctl is-active ${service})
service_active=$?

if [ ${service_active} -eq 0 ]; then
    echo "Service: ${service} is active."
    exit 0
elif [ ${service_active} -ne 0 ]; then
    echo "Service: ${service} is not active!"
    exit 1
#
# Undefined (from the purview of this script) 
#
else
    exit 3
fi
