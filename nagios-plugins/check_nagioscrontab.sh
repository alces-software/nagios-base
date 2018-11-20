#!/bin/bash

config_file_dir="/opt/nagios/nrds-client"

#
# Is it because the user has been removed ?
#
id -u nagios > /dev/null 2>&1
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Nagios User not present..."
    exit 1
fi


#
# See if the Nagios user even has a crontab 
#
nagios_crontab=`crontab -u nagios -l`
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "No crontab for nagios user!"
    echo ""
    echo "Restoring all nagios user's crontabs..."
    echo ""

    for config_file in `ls -1 ${config_file_dir} | grep -i "nagios-check"`; do
	echo "Adding crontab for: ${config_file}"
        source "/opt/nagios/manual-checks/create_cronjob.sh" ${config_file}
        rc=$?
        if [ ${rc} -ne 0 ]; then
            echo "Error restoring nagios user\'s crontab !"
            exit 1
        fi
    done
fi


echo "Nagios User's crontab OK" > /dev/null 2>&1

exit 0
