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
# Run Tripwire, generate a report
#

tripwire --check

#
# Generate a plaintext version of the tripwire report
#
tripwire_report_dir="/var/lib/tripwire/report"
latest_report=`ls -1tr ${tripwire_report_dir} | tail -n 1`

echo ${latest_report} | grep "$(date +"%Y%m%d")"
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Error! No Tripwire report for today!"
    exit 3 
fi

todays_report="${tripwire_report_dir}/${latest_report}"
todays_report_plaintext="${tripwire_report_dir}/twreport_today.txt"

twprint --print-report --twrfile ${todays_report} > ${todays_report_plaintext}

#
# See if any changes have been reported.
#
grep "Added Objects:\|Modified Objects:\|Removed Objects:" ${todays_report_plaintext} > /dev/null 2>&1
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "No Change To Sections of the Filesystem monitored by Tripwire."
    echo "0" > "${tripwire_report_dir}/.twstatus.txt"
    exit 0
else
   echo "Tripwire has detected changes to the file system!"

   #
   # Update the Tripwire Database, to reflect the latest file system.
   #
   tripwire --update --twrfile ${todays_report} --accept-all
   echo "1" > "${tripwire_report_dir}/.twstatus.txt"
   exit 0
fi

echo "Error! Problem Grepping the plain text Tripwire Report file."

exit 3
