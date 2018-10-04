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
# Make sure I am running as root
#

if [ `id -u` -ne 0 ]; then
    echo "Error! ${0} must be run as root."
    exit 1
fi

#
# run me in 
#

yum -y install tripwire
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Error! Unable to: yum -y install tripwire"
fi

#
# Copy files to /etc/tripwire
#

tripwire_directory="/etc/tripwire"

if [ ! -d ${tripwire_directory} ]; then
    echo "Error! ${tripwire_directory} not found!"
    exit 1
fi

cp twpol
