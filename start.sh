#!/bin/bash
#Brian Check
#https://github.com/bcheck555

#vars
interval=60
services=(
	"/usr/sbin/gpsd -n -r /dev/ttyAMA0"
	"/usr/sbin/chronyd"
        )

#init
stty -F /dev/ttyAMA0 raw 9600 cs8 clocal -cstopb

#start
for (( i = 0; i < ${#services[@]}; i++ )); do
  ps -ef | grep "${services[$i]}" | grep -q -v grep
  status=$?
  if [ $status -ne 0 ]; then
    `${services[$i]}`
    status=$?
    if [ $? -ne 0 ]; then
      echo "Failed to start ${services[$i]}: $status"
      exit $status
    else
      echo "Started ${services[$i]}: $status"
    fi
  else
    echo "${services[$i]} is already running."
  fi
done

#check
while sleep $interval; do
  for (( i = 0; i < ${#services[@]}; i++ )); do
    ps -ef | grep "${services[$i]}" | grep -q -v grep
    status=$?
    if [ $status -ne 0 ]; then
      echo "${services[$i]} is not running: $status"
      exit $status
    fi
  done
done
