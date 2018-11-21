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
	absolute_path_config_file="${config_file_dir}/${config_file}"
	echo "Adding crontab for: ${absolute_path_config_file}"
        bash "/opt/nagios/manual-checks/create_cronjob.sh" ${absolute_path_config_file}
        rc=$?
        if [ ${rc} -ne 0 ]; then
            echo "Error restoring nagios user\'s crontab !"
            exit 1
        fi
    done
fi

#
# We need a way to transparently register new crontabs.
# Just dump a new config file in the nagios-configs repo with a suitable name
#    and it ends up with a cron entry.
#

# get a count of the number of config files in the config_file_dir
# get a count of the number of cron entries in the crontab
# make sure that we "append" and do not replace a cron entry.

echo "Nagios User's crontab OK" > /dev/null 2>&1

exit 0
