#!/bin/bash
clear
pid=$(lsof -i:$1 -t)

if [ -z "$pid" ]; then
	echo "<start.sh> Starting Server on port $1 - you may close the SSH client now."
	DreamDaemon apollo.dmb $1 -trusted -webclient &
	exit 0
else
	echo "<start.sh> Server is currently running on port $1 . Please use [sh stop.sh] to hard restart the server."
	exit 1
fi
