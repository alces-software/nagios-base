#!/bin/bash
#
# To be run on controller.pri.CLUSTER
#
#1. Clone checks repoistory
#2. Clone branch


#
# Make sure I am running as root
#

if [ `id -u` -ne 0 ]; then
    echo "Error! ${0} must be run as root."
    exit 1
fi

this_host=`hostname -f | sed -e s/.alces.network$//g`

#
# Make sure I am being run on the controller node
#

echo "${this_host}" | grep -i "^controller\."
is_controller=$?

# dev
is_controller=0

if [ ${is_controller} -ne 0 ]; then
    echo "This must be run on the controller!"
    exit 1
fi

#
# Set the name of the config file used by the installer.
#

installer_config_file="nagios_install.cfg"

if [ ! -f ${installer_config_file} ]; then
    echo "Installation config file not found!"
    exit 1
fi

#
# Ensure that the /opt/alces directory exists and exit if it doesn't.
#

if [ ! -d ${parent_source_dir} ]; then
    echo "Error! Parent directory: ${parent_source_dir} does not exist!"
    exit 1
fi

#
# Get nagios-base Repo URL from config file
#

nagios_base_repo=`grep -i "nagios_base_repo" ${installer_config_file} | sed -e 's/nagios_base_repo=//' | tr -d \"`


#
# Get local directory in which nagios-base will be stored
#
source_base_dir=`grep -i "source_base_dir" ${installer_config_file} | sed -e 's/source_base_dir=//' | tr -d \"`


#
# Clone nagios-base, which is the repo containing plugins
#   and a limited but defined set of plugin dependencies.
#   Also will store scripts for checking the Nagios User is correct
#      and creating the cronjob.
#   The repo that is stored will be placed in ${source_base_dir}.
#   Typically /opt/alces/nagios-base
#

echo "Nagios Base Repo is: ${nagios_base_repo}"
echo "Nagios Base Directory is: ${source_base_dir}"

git clone ${nagios_base_repo} ${source_base_dir}
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Error cloning repo!"
    exit ${rc}
fi


#
# Get repo Nagios config URL from config file.
#

nagios_config_repo=`grep -i "nagios_config_repo" ${installer_config_file} | sed -e 's/nagios_config_repo=//' | tr -d \"`
echo ""
echo "Nagios Config Repository is: ${nagios_config_repo}"
echo ""

#
# Get the local directory that the configs repo will be stored.
#

source_configs_dir=`grep -i "source_configs_dir" ${installer_config_file} | sed -e 's/source_configs_dir=//' | tr -d \"`

# 
# Determine which cluster this is, I will fetch a configuration that is specific to my cluster.
#

# dev
test_hostname="controller.pri.csf3.alces.network"

this_cluster=`echo ${test_hostname} | sed -e 's/controller.pri.\(.*\).alces.network/\1/'`
echo ""
echo "Cluster is: ${this_cluster}"
echo ""

branch=${this_cluster}

echo ""
echo "Cloning repo: ${nagios_config_repo}, branch: ${branch}"
echo ""

#
# Clone nagios-configs, which is the repo containing configs 
#   The repo that is cloned will be placed in ${source_configs_dir}.
#   Typically /opt/alces/nagios-configs
#

git clone -b ${branch} ${nagios_config_repo} ${source_configs_dir}
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Error cloning repo: ${nagios_config_branch}"
    exit ${rc}
fi

#
# OK, launch sync script.
# 


exit 0
