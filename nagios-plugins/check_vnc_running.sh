#!/bin/bash


warning_threshold_hours=$1
critical_threshold_hours=$2

#
# Ensure the arguments are two digit integers - argument are in hours
#

valid_warning_threshold_hours=$(echo ${warning_threshold_hours} | grep -wP "[[:digit:]]{2}")
rc=$?

if [ ${rc} -ne 0 ]; then
    echo "Error checking the warning threshold."
    exit 3
fi

if [ ! ${valid_warning_threshold_hours} ]; then
    echo "Invalid Warning Threshold. Warning Threshold is: ${warning_threshold_hours}"
    exit 3
fi

valid_critical_threshold_hours=$(echo ${critical_threshold_hours} | grep -wP "[[:digit:]]{2}")
rc=$?

if [ ${rc} -ne 0 ]; then
    echo "Error checking the warning threshold."
    exit 3
fi

if [ ! ${valid_critical_threshold_hours} ]; then
    echo "Invalid Warning Threshold. Warning Threshold is: ${critical_threshold_hours}"
    exit 3
fi

if [ ${valid_critical_threshold_hours} -le ${valid_warning_threshold_hours} ]; then
    echo "Critical Threshold should be greater than Warning Threshold!"
    exit 3
fi 

#
# See if vnc is running and grab its pid(s)
#

vnc_pid=$(ps aux | grep -v "grep" | grep -m1 /usr/bin/Xvnc | awk '{print $2}')

# 
# 'awk '{print $2}' actually prints the 2nd column
# so vnc_pid will actually consist of a column
#

# 
# if vnc_pid variable is undefined, /usr/bin/Xvnc won't be running.
#

# Xvnc not running
if [ -z ${vnc_pid} ];then
    echo "OK: /usr/bin/Xvnc not running."
    exit 0
# Xvnc running, but for how long ?
else
    elapsed_time=$(ps -o etimes= -p "${vnc_pid}")

    #
    # obtain our warning threshold in seconds
    #

    seconds_per_hour="3600"
    warning_threshold_seconds=$((${valid_warning_threshold_hours} * ${seconds_per_hour}))
    critical_threshold_seconds=$((${valid_critical_threshold_hours} * ${seconds_per_hour}))

    if [ ${elapsed_time} -lt ${warning_threshold_seconds} ]; then
        echo "OK: /usr/bin/Xvnc running for less than ${valid_warning_threshold_hours} hours."
        exit 0
    elif [ ${elapsed_time} -ge ${critical_threshold_seconds} ]; then
       echo "CRITICAL: /usr/bin/Xvnc running for more than ${valid_critical_threshold_hours} hours."
       exit 2
    elif [ ${elapsed_time} -ge ${warning_threshold_seconds} ] || [ ${elapsed_time} -lt ${critical_threshold_seconds} ]; then
       echo "WARNING: /usr/bin/Xvnc running for more than ${valid_warning_threshold_hours} hours."
       exit 1
    else
       exit 3
    fi
fi

exit 3

