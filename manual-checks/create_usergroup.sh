#!/bin/bash

#
# Creates the Nagios user and Group
#

if [ -z ${1} ] || [ -z ${2} ]; then
    echo "Error! UID and GID must be specified"
    exit 1
fi

expected_uid=$1
expected_gid=$2

#
# First add the Nagios Group
#
groupadd -g ${expected_gid} nagios
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Error! Unable to add group: \"nagios\" with gid: ${expected_gid}"
    exit 1
fi

useradd -u ${expected_uid} -g ${expected_gid} nagios
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Error! Unable to add user: \"nagios\" as uid: ${expected_uid} to group with gid: ${expected_gid}"
    exit 1
fi

echo "User nagios is now added and a member of the nagios group"

exit 0
