#!/bin/bash

# 
# Now both repos are available on us (controller).
#

#
# sync the plugins to each target.
#

installer_config_file="nagios_install.cfg"

source_plugins_dir=`grep -i "source_plugins_dir" ${installer_config_file} | sed -e 's/source_plugins_dir=//' | tr -d \"`
echo ${source_plugins_dir}

if [ ! -d ${source_plugins_dir} ]; then
    echo "Error! Plugins repo not found!"
    exit 1
fi

echo "Plugins are at: ${source_plugins_dir}"

source_clients_dir=`grep -i "source_clients_dir" ${installer_config_file} | sed -e 's/source_clients_dir=//' | tr -d \"`
echo "Clients are at : ${source_clients_dir}"

if [ ! -d ${source_clients_dir} ]; then
    echo "Error! Client directory not found!"
    exit 1
fi

source_configs_dir=`grep -i "source_configs_dir" ${installer_config_file} | sed -e 's/source_configs_dir=//' | tr -d \"`
echo ${source_configs_dir}

if [ ! -d ${source_configs_dir} ]; then
    echo "Error! Configs directory not found!"
    exit 1
fi

#
#  Where the plugins will go
#

destination_plugins_dir=`grep -i "destination_plugins_dir" ${installer_config_file} | sed -e 's/destination_plugins_dir=//' | tr -d \"`
echo ${destination_plugins_dir}

#
# Where the destination NRDS client will go
#

destination_clients_dir=`grep -i "destination_clients_dir" ${installer_config_file} | sed -e 's/destination_clients_dir=//' | tr -d \"`
echo ${destination_clients_dir}

#
# Where the configs will go
#

destination_configs_dir=`grep -i "destination_configs_dir" ${installer_config_file} | sed -e 's/destination_configs_dir=//' | tr -d \"`
echo ${destination_configs_dir}

if [ -z ${destination_plugins_dir} ] || [ -z ${destination_clients_dir} ] || [ -z ${destination_configs_dir} ]; then
    echo "Error! Destination directories must be specified in : ${installer_config_file}"
    exit 1
fi

exit 0

#
# rsync all files from the source to the destination machines
# This is where the plugins and the configs are iteratively pushed to each node in the cluster
# We can use this script for updates too.
# 1) Rsync will not overwrite a file with a duplicate copy.
#

#while read machine_profile_entry; do
    machine_profile_entry="node01:nodes"
    echo ${machine_profile_entry}
    #
    # Get destination machine.
    #
    destination_machine=`echo ${machine_profile_entry} | cut -d: -f1`

    #dev 
    destination_machine="127.0.0.1"
    echo "destination_machine: ${destination_machine}"
    
    #
    # Get profile for this machine
    #
    profile=`echo ${machine_profile_entry} | cut -d: -f2`
    echo "Monitoring Profile is: ${profile}"

    continue;

    echo ""
    echo "Syncing Nagios Plugins..."
    echo ""
    echo ""
    echo "Syncing plugins to directory: ${destination_config_file} on machine:  ${destination_machine}"
    echo ""


    # -e flag with the ssh command and identify file not needed in production version!
    sudo rsync -aCvz -e "ssh -i /root/.ssh/id_rsa" ${source_plugins_dir}/ ${destination_machine}:${destination_plugins_dir} --delete
    rc=$?
    if [ ${rc} -ne 0 ]; then
        echo "Error syncing plugins! rsync error code is: ${rc}"
        exit 1
    fi

    echo ""
    echo "Plugins now synced."
    echo ""

    #
    # Syncing NRDS Client files
    #
    
    # -e flag with the ssh command and identify file not needed in production version!
    sudo rsync -aCvz -e "ssh -i /root/.ssh/id_rsa" ${source_clients_dir}/ ${destination_machine}:${destination_clients_dir} --delete
    rc=$?
    if [ ${rc} -ne 0 ]; then
        echo "Error syncing NRDS clients! rsync error code is: ${rc}"
        exit 1
    fi

    echo ""
    echo "Plugins now synced."
    echo ""



    echo ""
    echo "Syncing configs..."
    echo ""
    echo ""
    echo "Syncing configs to: ${destination_machine}"
    echo ""

    #
    # Move the correct config to the target machine
    #

    sudo rsync -aCvz -e "ssh -i /root/.ssh/id_rsa" ${source_configs_dir}/${profile}.nrds.cfg ${destination_machine}:${destination_configs_dir} --delete
    if [ ${rc} -ne 0 ]; then
        echo "Error syncing configs! rsync error code is: ${rc}"
        exit 1
    fi

    echo ""
    echo "Configs now synced."
    echo ""

    echo ""
    echo "Checking user is correct."
    echo ""

    #
    # Check the nagios user's UID and GID is set correctly.
    #

    nagios_user_uid=`grep -i "nagios_user_uid" ${installer_config_file} | sed -e 's/nagios_user_uid=//' | tr -d \"`
    nagios_group_gid=`grep -i "nagios_group_gid" ${installer_config_file} | sed -e 's/nagios_group_gid=//' | tr -d \"`

    ssh ${destination_machine} ${destination_plugins_dir}/nagios-plugins/check_uidgid.sh ${nagios_user_uid} ${nagios_group_gid} ${destination_plugins_dir} ${destination_configs_dir}
    rc=$?
    if [ ${rc} -ne 0 ]; then
        echo "Error remotely executing: check_uidgid.sh"
        exit 1
    fi

    echo ""
    echo "User correct."
    echo ""

#done < cluster_monitoring_profile.cfg

echo "Done."

exit 0
