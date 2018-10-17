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

# Check file exists

source_parent_dir="/opt/nagios/deps/sudoers"
target_parent_dir="/etc/sudoers.d"

#
# Check that nagios-monitoring sudoers file really exists first.
#
if [ ! -f "${source_parent_dir}/nagios-monitoring" ]; then
    echo "Error! ${source_parent_dir}/nagios-monitoring not found!"
    exit 1
fi

#
# If /etc/sudoers.d doesn't exist, we should probably raise an alarm bell.
#
if [ ! -d "${target_parent_dir}" ]; then
    echo "Error! ${target_parent_dir} not found!"
    exit 1
fi

#
# If the file does not exist on the system in the target location,
#     then copy it there. 
#     exit if we can't for some reason and report the error.
# Exit
#
if [ ! -f "${target_parent_dir}/nagios-monitoring" ]; then
    cp "${source_parent_dir}/nagios-monitoring" "${target_parent_dir}"
    rc=$?
    if [ ${rc} -ne 0 ]; then
        echo "Error! Unable to copy ${source_parent_dir}/nagios-monitoring to ${target_parent_dir}"
        exit ${rc}
    fi      
fi

exit 0
