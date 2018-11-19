#!/bin/bash

################################################################################
# (c) Copyright 2018 Stephen F Norledge & Alces Software Ltd.                  #
#                                                                              #
# HPC Cluster Toolkit                                                          #
#                                                                              #
# This file/package is part of the HPC Cluster Toolkit                         #
#                                                                              #
# This is free software: you can redistribute it and/or modify it under        #
# the terms of the GNU Affero General Public License as published by the Free  #
# Software Foundation, either version 3 of the License, or (at your option)    #
# any later version.                                                           #
#                                                                              #
# This file is distributed in the hope that it will be useful, but WITHOUT     #
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or        #
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License #
# for more details.                                                            #
#                                                                              #
# You should have received a copy of the GNU Affero General Public License     #
# along with this product.  If not, see <http://www.gnu.org/licenses/>.        #
#                                                                              #
# For more information on Alces Software, please visit:                        #
# http://www.alces-software.org/                                               #
#                                                                              #
################################################################################

if [ -z ${1} ]; then
    echo "Please specify the config file for Nagios checks."
    echo "Usage: ${0} -d config_file"
    exit 1
fi

#
# If no config file is specified as an argument,
# just set the nagios_checks_config_file variable to
# an empty string and use the default config.
#

if [ -z ${1} ]; then
   amc_config_file=""
fi
amc_config_file=$2

#
# Save current crontab
#

current_crontab=`crontab -u nagios -l`
rc=$?
if [ ${rc} -eq 0 ]; then
    echo "${current_crontab}" >> nagios_cron.tmp
fi

#
# current_crontab not needed now.
#
unset current_crontab


#
# create the cron schedule from the tag on the file name:
#

#
# Parse the cron scheduling info in the file name
#
# e.g. nagios_config_A_E3_A_A_A.cfg
#      A corresponds to * in cron syntax
#      E corresponds to */ in cron syntax
#      So in this example, A_E3_A_A_A is converted to it's cron-counterpart: * */3 * * * meaning every 3 minutes (default).
#

#
# Extract the schedule from the filename
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
# Append this entry to the nagios_cron.tmp file
#

echo "${nagios_cron_schedule} /opt/nagios/nrds-client/alces-monitoring-client.sh -c ${amc_config_file} > /dev/null 2>&1" >> nagios_cron.tmp


#
# go ahead and add the crontab from the file.
#

crontab -u nagios nagios_cron.tmp
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Error! Unable to install new crontab!"
    exit ${rc}
fi


# 
# Remove the tmp file 
#

rm -f nagios_cron.tmp
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Warning! Could not remove nagios_cron.tmp"
fi

exit 0
