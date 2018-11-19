#!/bin/bash

#
# Check nagios user exists on the system.
#

id -u nagios > /dev/null 2>&1
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Nagios User not present..."
    exit 1
fi

#
# Check if the nagios user has a crontab.
# The nagios user will not have a crontab, when it is installed for the first time.
# Each config file, (which defines the set of checks to run), corresponds with a check frequency.
# As part of the config file name is a tag, which represents the schedule that these checks will be run by cron.
# This script, will convert this tag to cron-format, as cron-format is not compatible with filenames.
# All files in the /opt/nagios/nrds-client directory named nagios_check_* will each correspond to a cronjob.
#

nagios_crontab=`crontab -u nagios -l`
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "No crontab for nagios user!"
    echo ""
    echo "Restoring nagios user's crontab's..."
    echo ""

    #
    # For each .cfg file present in the client directory, create a crontab entry.
    #
    for amc_config_file in `ls -1 /opt/nagios/nrds-client | grep "nagios_check_"`; do
        source /opt/nagios/manual-checks/create_cronjob.sh "${amc_config_file}"
    done
fi

echo "Nagios User's crontab OK" > /dev/null 2>&1

exit 0
