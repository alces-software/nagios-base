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
# Remember, the user of this file will need the following permissions
#
# Execute on grep with arguments specified.
#

searchstring="$1"
logfile="$2"

if [ -z "$searchstring" ] || [ -z "$logfile" ]; then
    echo "Error! Usage: $0 <search string> <absolute path of log file>"
    exit 3
fi 

if [ ! -f "$logfile" ]; then
    echo "File: $logfile not found!"
    exit 3
fi


today="$(date +"%b %e")"

sudo grep "$today.*$searchstring" $logfile
rc=$?

if [ "${rc}" -eq "1" ]; then
    echo "$searchstring not found today ($today)!"
    exit 0
elif [ "${rc}" -eq "0" ]; then
    echo "$searchstring found today ($today)"
    exit 1
else
    echo "Unknown!"
    exit 3
fi

