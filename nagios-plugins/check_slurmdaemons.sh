#!/bin/bash

#
# Check slurmctld
#

slurmctld_active=0
slurmdbd_active=0

return_string_slurmctld=$(/opt/nagios/nagios-plugins/check_service.sh "slurmctld")
slurmctld_active=$?

return_string_slurmdbd=$(/opt/nagios/nagios-plugins/check_service.sh "slurmdbd")
slurmdbd_active=$?


if [ ${slurmctld_active} ] && [ ${slurmdbd_active} ]; then
    echo "${return_string_slurmctld} ${return_string_slurmdbd}"
    exit 0
elif [ ${slurmctld_active} ] && [ ! ${slurmdbd_active} ]; then
    echo "${return_string_slurmctld} ${return_string_slurmdbd}"
    exit 1
elif [ ! ${slurmctld_active} ] && [ ${slurmdbd_active} ]; then
    echo "${return_string_slurmctld} ${return_string_slurmdbd}"
    exit 1
elif [ ! ${slurmctld_active} ] && [ ! ${slurmdbd_active} ]; then
    echo "${return_string_slurmctld} ${return_string_slurmdbd}"
    exit 2
else
    echo "Unknown error"
    exit 3
fi
