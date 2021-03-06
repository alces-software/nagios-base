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

installer_config_file="nagios_install.cfg"

if [ ! -f cluster_monitoring_profile.cfg ]; then
    echo "Error! cluster_monitoring_profile.cfg not found."
    echo "Please create cluster_monitoring_profile.cfg so I know which machines and which profiles to synchronize files to"
    exit 1
fi	

source_base_dir=`grep -i "source_base_dir" ${installer_config_file} | sed -e 's/source_base_dir=//' | tr -d \"[:space:]`
echo ${source_base_dir}

if [ -z ${source_base_dir} ]; then
    echo "Error! Base repo directory is not set!"
    exit 1
fi

if [ ! -d ${source_base_dir} ]; then
    echo "Error! Base repo not found!"
    exit 1
fi

echo "Base dir is at: ${source_base_dir}"

source_configs_dir=`grep -i "source_configs_dir" ${installer_config_file} | sed -e 's/source_configs_dir=//' | tr -d \"[:space:]`
echo ${source_configs_dir}

if [ -z ${source_configs_dir} ]; then
    echo "Error! Source configs directory is not set!"
    exit 1
fi

if [ ! -d ${source_configs_dir} ]; then
    echo "Error! Configs directory not found!"
    exit 1
fi

#
#  Where the plugins will go
#

destination_base_dir=`grep -i "destination_base_dir" ${installer_config_file} | sed -e 's/destination_base_dir=//' | tr -d \"[:space:]`
echo ${destination_base_dir}

if [ -z ${destination_base_dir} ]; then
    echo "Error! Destination directory must be specified in : ${installer_config_file}"
    exit 1
fi

#
# WHere the config will go
#
destination_config_dir=`grep -i "destination_config_dir" ${installer_config_file} | sed -e 's/destination_config_dir=//' | tr -d \"[:space:]`
if [ -z ${destination_config_dir} ]; then
    echo "Error! Destination directory must be specified in : ${installer_config_file}"
    exit 1
fi

#
# rsync all files from the source to the destination machines
# This is where the plugins and the configs are iteratively pushed to each node in the cluster
# We can use this script for updates too.
# 1) Rsync will not overwrite a file with a duplicate copy.
#

while read -r machine_profile_entry; do
    echo ${machine_profile_entry}
    #
    # Get destination machine.
    #
    destination_machine=`echo ${machine_profile_entry} | cut -d: -f1`

    echo "destination_machine: ${destination_machine}"
    
    #
    # Get profile for this machine
    #
    profile=`echo ${machine_profile_entry} | cut -d: -f2`
    echo "Monitoring Profile is: ${profile}"


    echo ""
    echo "Syncing Monitoring Client and Nagios Plugins..."
    echo ""
    echo ""
    echo "Syncing Monitoring Client and Nagios plugins to directory: ${destination_base_dir} on machine:  ${destination_machine}"
    echo ""

    sudo rsync -aCvz ${source_base_dir}/ ${destination_machine}:${destination_base_dir} --delete --exclude=install --exclude=README.md --exclude="Nagios\ Architecture.png" 
    rc=$?
    if [ ${rc} -ne 0 ]; then
        echo "Error syncing Monitoring Client and Plugins! rsync error code is: ${rc}"
        exit 1
    fi

    echo ""
    echo "Monitoring Client and Nagios Plugins now synced."
    echo ""


    echo ""
    echo "Copying monitoring client config file to ${destination_base_dir}/nrds-client on ${destination_machine}."
    echo ""

    #
    # Move the config to the same directory that the nrds client is in! 
    #

    scp ${source_configs_dir}/${profile}.nagios-check*.cfg ${destination_machine}:${destination_config_dir}
    if [ ${rc} -ne 0 ]; then
        echo "Error! Could not scp ${source_configs_dir}/${profile}.nagios-check.cfg to: ${destination_machine}:${destination_config_dir}"
        exit 1
    fi

    echo ""
    echo "Monitoring client Config now copied."
    echo ""

    echo ""
    echo "Copying configuration file for plugins to ${destination_base_dir}/nrds-client on ${destination_machine}."
    echo 

    scp ${source_configs_dir}/plugin_config.cfg ${destination_machine}:${destination_config_dir}
    if [ ${rc} -ne 0 ]; then
        echo "Error! Could not scp ${source_configs_dir}/plugin_config.cfg to: ${destination_machine}:${destination_config_dir}"
        exit 1
    fi

    echo ""
    echo "Plugin Configuration File now copied."
    echo ""

    echo ""
    echo "Checking user is correct."
    echo ""

    #
    # Check the nagios user's UID and GID is set correctly.
    #

    nagios_user_uid=`grep -i "nagios_user_uid" ${installer_config_file} | sed -e 's/nagios_user_uid=//' | tr -d \"[:space:]`
    nagios_group_gid=`grep -i "nagios_group_gid" ${installer_config_file} | sed -e 's/nagios_group_gid=//' | tr -d \"[:space:]`

    ssh -n ${destination_machine} "${destination_base_dir}/nagios-plugins/check_uidgid.sh" ${nagios_user_uid} ${nagios_group_gid} ${destination_base_dir} ${destination_config_dir}
    rc=$?
    if [ ${rc} -ne 0 ]; then
        echo "Error remotely executing: check_uidgid.sh"
        exit 1
    fi

    echo ""
    echo "User correct."
    echo ""

    #
    # Check the crontab is fine
    #
    # Let's not mess around with this too much. 
    # Just get something functional !
    # 

    echo ""
    echo "Checking nagios user's crontab..."
    echo ""
    
    ssh -n ${destination_machine} "${destination_base_dir}/nagios-plugins/check_nagioscrontab.sh"
    rc=$?
    if [ ${rc} -ne 0 ]; then
        echo "Error remote executing: check_nagioscron.sh"
	exit 1
    fi

    echo ""
    echo "Crontab is fine."
    echo ""

    #
    # Verify sudoers config is in place for nagios on the remote machine
    # initial sync will find the nagios sudoers file is absent and copy the file in to place
    #  
    echo ""
    echo "Verifying sudoers config"
    echo ""

    #ssh -n ${destination_machine} "${destination_base_dir}/manual-checks/nagios_sudoers.sh"
    ssh -n ${destination_machine} cp "${destination_base_dir}/deps/sudoers/nagios-monitoring /etc/sudoers.d"

    #
    # Set permissions
    #
    echo ""
    echo "Setting permissions..."
    echo ""
    ssh -n ${destination_machine} "${destination_base_dir}/deps/set_permissions.sh"
    rc=$?
    if [ ${rc} -ne 0 ]; then
        echo "Error setting permissions !"
	exit 1
    fi

done < cluster_monitoring_profile.cfg

echo "Done."

exit 0
