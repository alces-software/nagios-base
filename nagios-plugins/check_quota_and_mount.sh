#!/bin/bash                                                                                                                                                            
                                                                                                                          

################################################################################
# (c) Copyright 2018 Stephen F Norledge & Alces Software Ltd.                  #
#                                                                              #
# HPC Cluster Toolkit                                                          #
#                                                                              #
# This file/package is part of the HPC Cluster Toolkit                         #
#                                                                              #
# This is free software: you can redistribute it an_d/or modify it un_der        #
# the terms of the GNU Affero General Public License as published by the Free  #
# Software Foun_dation, either version 3 of the License, or (at your option)    #
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

# mount point which quotas are applied to
quota_mount=$1

# flag indicating whether there are supposed to be quotas set on this system
mount_expected=$2

if [ -z "$quota_mount" ] || [ -z "$mount_expected" ]; then
    echo "Error! Usage: $0 <mount pount> <quotas mount_expected (1 for true, 0 for false)>"
    echo "e.g. $0 /export/users 1"
fi

plugin_dir="/opt/nagios/nagios-plugins"

# might as well utilise the other (alces defined) mount point check
mount_check="$plugin_dir/check_ismounted $quota_mount"

# check if /export/users is mounted
$mount_check > /dev/null 2>&1
rc=$?

# if not mounted, then don't bother - it's OK
if [ "$rc" -ne "0" ]; then
    echo "OK - $quota_mount not mounted." 
    exit 0
else 
    sudo /usr/sbin/repquota $quota_mount > /dev/null 2>&1
    rc=$?
    if [ "$rc" -eq "0" ] && [ "$mount_expected" -eq "1" ]; then
        echo "OK - $quota_mount is mounted and Quotas are enabled."
        exit 0
    elif [ "$rc" -eq "1" ] && [ "$mount_expected" -eq "1" ]; then
        echo "Warning - $quota_mount is mounted, Quotas are not enabled, but expected!"
        exit 1
    elif [ "$rc" -eq "1" ] && [ "$mount_expected" -eq "0" ]; then
        echo "OK - $quota_mount is mounted and quotas are not set, but also not expected!"
        exit 0
    elif [ "$rc" -eq "0" ] && [ "$mount_expected" -eq "0" ]; then
        echo "Erm..Quotas are set, but not expected!"
    else
        echo "$0 Unknown error!"    
        exit 3
    fi
fi
