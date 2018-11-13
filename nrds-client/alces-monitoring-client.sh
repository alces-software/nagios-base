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
# This script reads a config file, consisting of meta-data and lines that define system checks.
# Each token in the line is delimited by colons. 
# Each token is passed as argument to either a check or a script - send_nrdp.sh.
# The output and return code of each check is also passed as arguments to the send_nrdp.sh script
#



#
# We accept different config files, check if we are requested to run any
#

if [ "${1}" == "-d" ]; then

    #
    # OK, let's use the config file specified in the subsequent argument.
    #

    config_file=${2}

    #
    # If we get something empty, just proceed with the default.
    #
    
    if [ -z "${config_file}" ]; then
	    # if we find an empty string, just use the default
	    config_file="/opt/nagios/nrds-client/nagios-check.cfg"
    fi

    if [ ! -f "${config_file}" ]; then
	    echo "Error! ${config_file} not found!"
	    exit 1
    fi
fi

exit 0 


#
# Open config file
#
source ${config_file}

#
# Arguments to ./send_nrdp.sh
#

check_to_run=""
output=""
state=""

# String to use for the service_description of a host
host_not_service="__HOST__"

#
# Arguments to cut
# Note that service_desc a.k.a : service_description should be equal to the service_description value in the object definition on the nagios server.
# target_host:service_desc:check_path
#

target_host="1"
service_desc="2"
check_path="3"

nrdp_data=""

for check in "${checks[@]}"
do
    echo "${check}"
    
    host_checked=`echo ${check} | cut -d: -f ${target_host}`
    nrdp_data="${nrdp_data}${host_checked}"

    service_description=`echo ${check} | cut -d: -f ${service_desc}`

    #
    # service_description only required on service checks.
    #
    if [ "${service_description}" != "${host_not_service}" ]; then
            nrdp_data="${nrdp_data}\t${service_description}"
    fi

    check_to_run=`echo ${check} | cut -d: -f ${check_path}`
    output=$(${check_to_run})
    state=$?

    nrdp_data="${nrdp_data}\t${state}"
    nrdp_data="${nrdp_data}\t${output}\n"
done 

echo -e "${nrdp_data}" | /opt/nagios/nrds-client/send_nrdp.sh -u "${url}" -t "${token}"

exit 0
