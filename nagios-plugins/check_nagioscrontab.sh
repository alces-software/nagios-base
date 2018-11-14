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
# See if the Nagios user even has a crontab. They should do.
# If not then restore the DEFAULT and manually repeair non-default entries.
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

	#
	# Parse the cron scheduling info in the file name
	#
	# e.g. nagios_config_A_E3_A_A_A.cfg
	#

        #
        # Extract the schedule
        # 
	# E3_A_A_A_A

        nagios_cron_sched=`echo "${amc_config_file}" | sed -e 's|nagios_check_\(.*\).cfg|\1|g'`
	echo ${nagios_cron_sched}
	#
	# Replace underscores with spaces
	# 
	# E3 A A A A

	nagios_cron_sched=`echo "${nagios_cron_sched}" | sed -e 's|_| |g'`
	

	#
	# Replace 'E' characters with a forward-slash '*/' character
	#
	# */3 A A A A
	nagios_cron_sched=`echo "${nagios_cron_sched}" | sed -e 's|E|\*\/|g'`

	
	#
        # Replace 'A' characters with asterisks.
        #
	# */3 * * *

        nagios_cron_sched=`echo "${nagios_cron_sched}" | sed -e 's|A|\*|g'`
	
	#
	# schedule will now be in the correct format.
	#
        
        source /opt/nagios/manual-checks/create_cronjob.sh "${nagios_cron_sched}" "${amc_config_file}"
    done
fi

echo "Nagios User's crontab OK" > /dev/null 2>&1

exit 0
