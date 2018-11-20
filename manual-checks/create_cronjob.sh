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

if [ -z $1 ]; then
    echo "Need to specify a config file to create a cron job for."
    exit 1
fi

config_file=$1

if [ ! -f "${config_file}" ]; then
    echo "${config_file} not found! Exiting..."
    exit 1
fi

#
# Extracts the cron schedule from the config
#

#
# If crontab is not empty, save the content
#
cron_output=`crontab -u nagios -l`
rc=$?
if [ "${rc}" -eq "0" ]; then
    echo "${cron_output}" >> nagios_cron.tmp
fi

nagios_interval=`grep -i "cron_schedule" ${config_file} | sed "s|cron_schedule=\(.*\)|\1|g" | sed "s|'||g"`
echo "${nagios_interval} /opt/nagios/nrds-client/alces-monitoring-client.sh -c ${config_file} > /dev/null 2>&1" >> nagios_cron.tmp

#
# Add cron job
#

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
