#!/bin/bash


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
    echo "Restoring nagios user's crontab..."
    echo ""
    source "/usr/local/nagios-base/manual-checks/create_cronjob.sh" 3
    rc=$?
    if [ ${rc} -ne 0 ]; then
        echo "Error restoring nagios user's crontab !"
        exit 1
    fi
fi


echo "Nagios User's crontab OK" > /dev/null 2>&1

exit 0
