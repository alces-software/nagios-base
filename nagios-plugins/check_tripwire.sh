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

tripwire_report_dir="/var/lib/tripwire/report"
tripwire_status_file="${tripwire_report_dir}/.twstatus.txt"

if [ ! -f ${tripwire_status_file} ]; then
    echo "Error! Tripwire status file not found!"
    exit 3
fi

tw_status=`cat ${tripwire_status_file}`

#
# If there is no change to the FS, then OK
# Else
#     we've sent out an alert, clear the status flag and sent out an alert.
#
# Note that this script CLEARS the flag after it has reported a detected a change.
# The alces-tripwire-check.sh script conversely, writes to the status file when it detects the change. 
#

if [ ${tw_status} -eq 0 ]; then
    echo "No Changes to Monitored Filesystems under Tripwire."
    exit 0
else
    echo "Changes to the Filesystems Monitored by Tripwire have been detected."
    echo "0" > "${tripwire_status_file}"
    exit 1
fi

exit 0
