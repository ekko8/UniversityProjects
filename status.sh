#!/bin/bash
# Ethan Koen - epkknd
# status.sh
# This script uses the systemctl command to check the status of a daemon. It also allows the user to start or stop a daemon by entering "start" or "stop" as the second argument. 
# Second argument is not required
# Input: status.sh <daemon name> <"start" or "stop">
systemctl status $1 > /dev/null 2>&1 
CODE=$?
DATE=$(date)
PREFIX="[$USER] [$DATE] "
# Status Checking
if [ $CODE -eq 0 ]
	then
		STATUS=0
		OUTPUT="$PREFIX The $1 service is running"
elif [ $CODE -eq 3 ]
	then
		STATUS=3
		OUTPUT="$PREFIX The $1 service is stopped"
elif [ $CODE -eq 4 ]
	then
		STATUS=4
		OUTPUT="$PREFIX The $1 service is not installed"
	else
		echo "ERROR"
fi

echo $OUTPUT
echo $OUTPUT >> /tmp/services.logs
# If there is no second argument, exit
if [ -z $2 ]
then 
	exit 0
fi
# Start/Stop
if [ $STATUS -eq 4 ]
then
	OUTPUT="ERROR: $1 could not be found"
	echo $OUTPUT
fi

if [[ $2 == "start" && $STATUS -eq 3 ]]
then
	OUTPUT="Starting $1"
	echo $OUTPUT
	systemctl start $1 > /dev/null
fi

if [[ $2 == "stop" && $STATUS -eq 0 ]]
then
	OUTPUT="Stopping $1"
	echo $OUTPUT
	systemctl stop $1 > /dev/null
fi

if [[ $2 == "start" && $STATUS -eq 0 ]]
then 
	OUTPUT="$1 is already started."
	echo $OUTPUT
fi

if [[ $2 == "stop" && $STATUS -eq 3 ]] 
then 
	OUTPUT="$1 is already stopped."
	echo $OUTPUT
fi

if [[ $2 != "start" && $2 != "stop" ]]
then
	OUTPUT="ERROR: Input ('$2') not recognized by script. (Must be 'start or 'stop')"
	echo $OUTPUT
fi

echo $OUTPUT >> /tmp/services.logs
