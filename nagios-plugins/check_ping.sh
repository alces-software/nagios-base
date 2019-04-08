#!/bin/bash

./check_ping $1

rc=$?

if [ "$rc" -eq "1" ]; then
    exit 2
elif [ "$rc" -eq "2" ]; then
    exit 1
fi

echo $rc 
