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

if [ -z $1 ]; then
    echo "Error! Usage: $0 -c <config_file>"
    exit 1
fi

if [ "$1" == "-c" ]; then
	config_file=$2
	if [ -z $2 ]; then
	    echo "Error, usage: $0 -c <config_file>"
	fi
fi

if [ ! -f ${config_file} ]; then
    echo "${config_file} not found!"
fi

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

#
# Path the log file which contains the data stored in the 
# nrdp_data string.
# This string is written piped through to "send_nrdp.sh" 
# which packages it in the XML form expected by the NRDS server.
#

log_file="/opt/nagios/nrds-client/amc_client.log"

if [ ! -f $log_file ]; then
    echo "Log File: $log_file not found!"
fi

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

    eval "check_to_run=(`echo ${check} | cut -d: -f ${check_path}`)"
    output="$("${check_to_run[@]}")"
    state=$?

    nrdp_data="${nrdp_data}\t${state}"
    nrdp_data="${nrdp_data}\t${output}\n"

    echo -e "${nrdp_data}" > ${log_file}
done 

echo -e "${nrdp_data}" | /opt/nagios/nrds-client/send_nrdp.sh -u "${url}" -t "${token}"

exit 0

