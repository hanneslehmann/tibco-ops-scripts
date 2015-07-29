#!/bin/env bash

##
#   Description:    This shell script will print out to the terminal some information about
#                   running ems instances. Will be enhanced to use for ops guys taking
#                   over an EMS infrastructure to get a first idea
#
#   Usage:          Run from the command line
#
#   Author:         Hannes Lehmann
##

#Set the field separator to new line
IFS=$'\n'

COUNTER=1
data=$(ps aux | grep -v grep  | grep emsd)

echo
echo "Checking for EMS instances..."
echo

#Try to iterate over each line
for item in $data
do
        # echo "Item: $item"
        pid=`echo $item | awk '{split($0,a," "); print a[2]}'`
        bin=`echo $item | awk '{split($0,a," "); print a[11]}'`
        log=`lsof -c tibemsd  2>/dev/null | grep logfile | grep $pid | awk '{split($0,a," "); print a[9]}'`
        port=`netstat -antp4 | grep $pid | awk '{split($0,a," "); print a[4]}' | awk '{split($0,a,":"); print a[2]}'`
        conf=`cat $log | grep "Reading configuration" | tail -1 |  awk '{split($0,a,"'"'"'"); print a[2]}'`
        name=`cat $conf | grep "server[[:space:]]*=" | awk '{split($0,a,"="); print a[2]}' `
        echo "-------------------------------------------------------------------------------------"
        echo " Product:       Tibco EMS"
        echo " Instance:      $COUNTER"
        echo " PID:           $pid "
        echo " Port:          $port"
        echo " Executable:    $bin"
        echo " Logfile:       $log"
        echo " Config:        $conf"
        echo " Name:         $name"
        echo
        let COUNTER+=1 
done


