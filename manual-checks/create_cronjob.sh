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
    echo "Please specify the interval, in minutes for Nagios checks."
    echo "Usage : ${0} <interval> (in minutes)"
    exit 1
fi

nagios_interval=$1
this_host=`hostname -f | sed -e s/.alces.network$//g`

echo "Adding cronjob to ${this_host}, checks will be run every ${nagios_interval} minutes."

echo "*/${nagios_interval} * * * * /opt/nagios/nrds-client/alces-monitoring-client.sh > /dev/null 2>&1" >> nagios_cron.tmp

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
