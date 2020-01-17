#!/bin/bash

slurmctld_active=0
slurmdbd_active=0

if [ -z ${1} ] || [ -z ${2} ]; then
    echo ""
    echo "Error! Arguments not provided."
    echo ""
    echo "Usage: $0 slurmctld=[0|1] slurmdbd[0|1]"
    echo ""
    echo "Where, 1 indicates a service is intentionally active and 0 indicates the service is intentionally inactive."
    echo ""
    exit 3
fi

return_string_slurmctld=$(/opt/nagios/nagios-plugins/check_service.sh "slurmctld")
slurmctld_active=$?

return_string_slurmdbd=$(/opt/nagios/nagios-plugins/check_service.sh "slurmdbd")
slurmdbd_active=$?

#
# Some clusters may have certain daemons disabled intentionally.
# Use these flags, to prevent the check from failing on the condition where
# the relevant daemon is supposed to not be running.
#



#
# Switches passed as command line arguments
#

declare -A valid_arguments

valid_arguments[0]="slurmctld=[0-1]"
echo $1 | grep -w "${valid_arguments[0]}" > /dev/null 2>&1
rc=$?

if [ ${rc} -ne 0 ]; then
    echo "Argument invalid."
    exit 3
fi

slurmctld_flag=$(echo $1 | grep -o ".$")

if [ ${slurmctld_flag} -ne 0 ] && [ ${slurmctld_flag} -ne 1 ]; then
    echo "slurmctld flag is invalid. value is: ${slurmctld_flag}"
    exit 3
fi

valid_arguments[1]="slurmdbd=[0-1]"
echo $2 | grep -w "${valid_arguments[1]}"  > /dev/null 2>&1
rc=$?

if [ ${rc} -ne 0 ]; then
    echo "Argument invalid."
    exit 3
fi

slurmdbd_flag=$(echo $2 | grep -o ".$")

if [ ${slurmdbd_flag} -ne 0 ] && [ ${slurmdbd_flag} -ne 1 ]; then
    echo "slurmdbd flag is invalid. value is: ${slurmdbd_flag}"
    exit 3
fi

if [ ${slurmctld_active} -eq 0 ] && [ ${slurmdbd_active} -eq 0 ]; then
    echo "${return_string_slurmctld} ${return_string_slurmdbd}"
    exit 0
elif [ ${slurmctld_active} -eq 0 ] && [ ${slurmdbd_active} -ne 0 ]; then
    # slurmctld is active, slurmdbd is inactive
    if [ ${slurmdbd_flag} -eq 0 ]; then
        # slurmdbd is supposed to be off
        echo "${return_string_slurmctld} ${return_string_slurmdbd} (on purpose)"
	exit 0
    else
	# slurmdbd is supposed to be on
        echo "${return_string_slurmctld} ${return_string_slurmdbd}"
        exit 1
    fi
elif [ ${slurmctld_active} -ne 0 ] && [ ${slurmdbd_active} -eq 0 ]; then
    # slurmctld is inactive, slurmdbd is active
    if [ ${slurmctld_flag} -eq 0]; then
        # slurmctld is supposed to be off.
        echo "${return_string_slurmctld} (on purpose) ${return_string_slurmdbd}"
        exit 0
    else
        # slurmctld is supposed to be on.
        echo "${return_string_slurmctld} ${return_string_slurmdbd}"
        exit 1
    fi
elif [ ${slurmctld_active} -ne 0 ] && [ ${slurmdbd_active} -ne 0 ]; then
    echo "${return_string_slurmctld} ${return_string_slurmdbd}"
    exit 2
else
    echo "Unknown error"
    exit 3
fi
