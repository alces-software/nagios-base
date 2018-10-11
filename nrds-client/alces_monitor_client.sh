#!/bin/bash

#
# This script reads a config file, comprised of meta-data and lines that define system checks.
# Each token in the line is delimited by colons. 
# Each token is passed as argument to either a check or a script - send_nrdp.sh.
# The output and return code of each check is also passed as arguments to the send_nrdp.sh script
#

#
# Open config file
#
source alces_mc.cfg

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

echo -e "${nrdp_data}" | ./send_nrdp.sh -u "${url}" -t "${token}"

exit 0

