#!/bin/bash

critical=500000
warning=100000

slab_value=$(ls -1 /sys/kernel/slab/ | wc -l)

if [ ${slab_value} -gt ${critical} ]; then
  echo "CRITICAL: Slab allocation has exceeded critical threshold (${critical})."
  exit 2
elif [ ${slab_value} -gt ${warning} ]; then
  echo "WARNING: Slab allocation exceeded warning threshold (${warning})"
  exit 1
else
  echo "OK: Slab value at: ${slab_value}."
  exit 0
fi

exit 3
