#!/bin/bash

/opt/nagios/nagios-plugins/check_fileage.py -f /opt/site/license-monitor/abaqus-licenses.rc -w 30 -c 60
abaqusrc=$?

/opt/nagios/nagios-plugins/check_fileage.py -f /opt/site/license-monitor/ansa-licenses.rc -w 30 -c 60
ansarc=$?

if [ ${abaqusrc} -ne 0 ] || [ ${ansarc} -ne 0 ]; then
    echo "Abaqusrc or Ansa License files not updated within 30 mins."
    exit 1
else
    exit 0
fi

exit 3

