#!/bin/bash


nr_running_procs=$(ps aux | grep -v "$0\|grep -cE intel\.\*lic" |  grep -cE "intel.*lic")

if [ ${nr_running_procs} == "2" ]; then
    echo "OK - Intel License Running."
    exit 0
else
    echo "Critical: Intel License NOT Running."
    exit 2
fi

exit 3
