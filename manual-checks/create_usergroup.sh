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
# Creates the Nagios user and Group
#

if [ -z ${1} ] || [ -z ${2} ]; then
    echo "Error! UID and GID must be specified"
    exit 1
fi

expected_uid=$1
expected_gid=$2

nagios_home=/opt/nagios

#
# First add the Nagios Group
#

echo "expected_gid is: ${expected_gid}"

groupadd --gid ${expected_gid} nagios
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Error! Unable to add group: \"nagios\" with gid: ${expected_gid}"
    exit 1
fi

useradd --system --uid ${expected_uid} --gid ${expected_gid} --create-home --home-dir ${nagios_home} nagios
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Error! Unable to add user: \"nagios\" as uid: ${expected_uid} to group with gid: ${expected_gid}"
    exit 1
fi

echo "User nagios is now added and a member of the nagios group"

exit 0
