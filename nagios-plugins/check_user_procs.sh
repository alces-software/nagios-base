#!/bin/bash

pdsh -g cn '/opt/service/check_user_procs.sh' | grep BAD


