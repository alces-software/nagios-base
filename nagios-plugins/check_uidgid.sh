#!/bin/bash
#
# On each machine:
#     Ensure Nagios user and group is present with the correct UID and GID respectively.
# 
# This script is rsynced accross, then is run each time an rsync occurs

expected_nagios_user="nagios"
expected_nagios_uid="$1"
expected_nagios_gid="$2"

if [ -z ${expected_nagios_uid} ] || [ -z ${expected_nagios_gid} ]; then
	echo "Must supply both a UID for the Nagios User and a GID for the Nagios Group"
	exit 1
fi

# check nagios user exists

this_nagios_user=`id -u ${nagios_user}`
this_nagios_user=${nagios_uid}
this_nagios_group=`id -g ${nagios_group}`
this_nagios_group=${nagios_gid}

#
# If the UID or GID is incorrect, then remove the user
# and create it fresh, otherwise skip
#

echo ""
echo "Checking user and group ID..."
echo ""

if [ "${this_nagios_user}" != "${expected_nagios_uid}" ] || [ "${this_nagios_group}" != "${expected_nagios_gid}" ]; then
    echo ""
    echo "Nagios UID and GID not suitable, remediating..."
    echo ""

    #
    # userdel will remove the user's home directory if it exists
    # thecronjob will not be deleted
    #
    userdel ${this_nagios_user}
    rc=$?
    if [ ${rc} -ne 0 ]; then
        echo "Error removing user: ${this_nagios_user}!"
        exit ${rc}
    fi

    useradd ${expected_nagios_user} --uid ${expected_nagios_uid} --gid ${expected_nagios_gid}
    rc=$?
    if [ ${rc} -ne 0 ]; then
        echo "Error adding user ${expected_nagios_user} with uid: ${expected_nagios_uid} and gid: ${expected_nagios_gid}"
        exit ${rc}
    fi

    echo ""
    echo "Nagios UID and GID remediation complete."
    echo ""
fi

echo ""
echo "User and group ID fine..."
echo ""

exit 0
