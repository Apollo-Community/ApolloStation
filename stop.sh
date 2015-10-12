#!/bin/bash
clear
echo "<stop.sh> Attempting to stop DreamDaemon on port $1"
pid=$(lsof -i:$1 -t)
kill -KILL $pid

newpid=$(lsof -i:$1 -t)
if [ -z "$newpid" ]; then
	echo "<stop.sh> Server has been shutdown on port $1"
else
	echo "<stop.sh> There was an issue shutting the server on port $1 down. Please contact a server administrator"
fi


