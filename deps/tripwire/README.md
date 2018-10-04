# Tripwire Dependencies for Nagios

This directory stores the files necessary for tripwire monitoring. Please not that it does not contain check_tripwire.sh, as this check
is kept in the same directory as the Nagios Plugins.

### tripwire_install.sh

Installer for the tripwire files.

### alces-tripwire-check

A cron-script that is to be placed in /etc/cron.d, that controls the invocation of the tripwire check. 

### alces-tripwire-check.sh

The script that is run by cron. This script, causes Nagios to run an integrity check on the filesystem, using the Alces policy file.
As part of the integrity check task, Nagios generates a report file, which is stored in /var/lib/tripwire/report

This script will generate a plaintext version of this report, and use grep to inspect it for changes.

If a change is noticed, a "1" is written to a file, otherwise a "0" is written to a file. When check_tripwire.sh is run via nrds.pl,
this check inspects the file. If it reads a 1, then it clears the flag and generates a Nagios alert, to inform the support team that
changes have occured.. Otherwise it continues to trigger OK messages for nrds.pl to report back.

### local.key

This key is used to protect the database. The database contains the information tripwire gathers from inspecting the filesystem and taking a snapshot of certain
properties such as checksums and other information specified in the policy file.

### site.key

This key is used to protect the policy file that tripwire uses to determine which file system objects to monitor.

### tw.cfg

Configuration file that is used by tripwire for refering to external object such as name and filesystem path of keys, policy file, reports and database location.
