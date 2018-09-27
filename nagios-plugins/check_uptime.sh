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


#
# If system uptime is less than number of  minutes specified as an argument, generate a critical alert.
# n.b: The check_uptime plugin bundled with the Nagios plugins is designed to check for uptimes that EXCEED a given 
# threshold, in contrast to this script.
#

critical_threshold=$1

if [ -z ${critical_threshold} ] || [ "${critical_threshold}" -gt "59" ]; then
    echo "Error! Usage: ${0} <threshold in mins>, (59 is maximum)"
    exit 3
fi

full_uptime=`uptime`
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Error! Unable to run uptime command!"
    exit 3
fi

units=`echo ${full_uptime} | cut -d' ' -f 4 | tr -d ,`
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Error! Unable to parse uptime command output!"
    exit 3
fi

if [ "${units}" != "min" ]; then
    uptime_now=`uptime -p`
    echo "OK! Uptime is: ${uptime_now}"
    exit 0
else
    minutes_up=`echo ${full_uptime} | cut -d' ' -f 3 | tr -d ,`
    if [ "${minutes_up}" -lt "${critical_threshold}" ]; then
        echo "Critical! Uptime is : ${minutes_up} minutes!"
        exit 2
    else
        echo "OK! Uptime is : ${minutes_up} minutes!"
        exit 0
    fi
fi
