#!/bin/bash

if [ -z ${1} ]; then
    echo "Please specify the interval, in minutes for Nagios checks."
    echo "Usage : ${0} <interval> (in minutes)"
    exit 1
fi

nagios_interval=$1
this_host=`hostname -f | sed -e s/.alces.network$//g`

echo "Adding cronjob to ${this_host}, checks will be run every ${nagios_interval} minutes."

echo "*/${nagios_interval} * * * * /opt/nagios/nrds-client/alces-monitoring-client.sh -H ${this_host} > /dev/null 2>&1" >> nagios_cron.tmp

crontab -u nagios nagios_cron.tmp
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Error! Unable to install new crontab!"
    exit ${rc}
fi

rm -f nagios_cron.tmp
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Warning! Could not remove nagios_cron.tmp"
fi

exit 0
