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
    echo "Please specify the schedule, for Nagios checks."
    echo "Usage: ${0} <schedule> [-d config_file]"
    exit 1
fi

#
# If no config file is specified as an argument,
# just set the nagios_checks_config_file variable to
# an empty string and use the default config.
#

if [ -z ${2} ]; then
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

nagios_cron_schedule=$1
this_host=`hostname -f | sed -e s/.alces.network$//g`

echo "Adding cronjob to ${this_host} minutes."

echo "${nagios_cron_schedule} /opt/nagios/nrds-client/alces-monitoring-client.sh -c ${amc_config_file} > /dev/null 2>&1" >> nagios_cron.tmp

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
