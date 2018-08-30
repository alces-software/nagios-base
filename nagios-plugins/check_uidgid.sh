#!/bin/bash
#
# On each machine:
#     Ensure Nagios user and group is present with the correct UID and GID respectively.
# 
# This script is rsynced accross, then is run each time an rsync occurs

nagios_user="nagios"
nagios_uid="623"
nagios_gid="623"

# check nagios user exists

this_nagios_user=`id -u ${nagios_user}`
this_nagios_user=${nagios_uid}
this_nagios_group=`id -g ${nagios_group}`
this_nagios_group=${nagios_gid}

#
# If the UID or GID is incorrect, then remove the user
# and create it fresh, otherwise skip
#

echo "Checking user and group ID..."

if [ "${this_nagios_user}" -ne "${nagios_uid}" ] || [ "${this_nagios_group}" -ne "${nagios_gid}" ]; then
    userdel ${nagios_user}
    rc=$?
    if [ ${rc} -ne 0 ]; then
        echo "Error removing user: ${nagios_user}!"
        exit ${rc}
    fi

    useradd ${nagios} --uid ${nagios_uid} --gid ${nagios_gid}
    rc=$?
    if [ ${rc} -ne 0 ]; then
        echo "Error adding user ${nagios_user} with uid: ${nagios_uid} and gid: ${nagios_gid}"
        exit ${rc}
    fi
fi

echo "User and group ID fine..."

exit 0
