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
data=$(ps aux | grep -v grep  | grep bwengine)

echo
echo "Checking for BW engines..."
echo

#Try to iterate over each line
for item in $data
do
		IFS=' ' read -a array <<< "$item"
        # echo "Item: $item"
        pid=${array[1]}
        bin=${array[10]}
		for params in "${array[@]}"
		do
			 [[ $params == *.tra ]] && tra=$params
		done
        details=`lsof -c bwengine  2>/dev/null | grep $pid | awk '{split($0,a," "); print a[9]}'`
		IFS=$'\n'
        heap=`cat $tra | grep "java.heap.size.max=" | awk '{split($0,a,"="); print a[2]}'`
		domain=`cat $tra | grep "java.property.TIBCO_DOMAIN_NAME=" | awk '{split($0,a,"="); print a[2]}'`
		repo=`cat $tra | grep "tibco.repourl=" | awk '{split($0,a,"="); print a[2]}'`
		starters=`cat $tra | grep "Config.Primary.Partitions=" | awk '{split($0,a,"="); print a[2]}' `
        # conf=`cat $log | grep "Reading configuration" | tail -1 |  awk '{split($0,a,"'"'"'"); print a[2]}'`
        # name=`cat $conf | grep "server[[:space:]]*=" | awk '{split($0,a,"="); print a[2]}' `
        echo "-------------------------------------------------------------------------------------"
        echo " Product:       Tibco BusinessWorks Engine"
        echo " Instance:      $COUNTER"
        echo " PID:           $pid "
		echo " Domain:        $domain"
        # echo " Port:          $port"
        echo " Executable:    $bin"
		echo " TRA:           $tra"
		echo " Repo:          $repo"
        # echo " Logfile:       $log"
        # echo " Config:        $conf"
        # echo " Name:         $name"
		for params in $details
		do
			 [[ $params == *.log ]] && echo " Logfile:       $params"
		done
		echo " HEAP:          $heap"
		IFS=',' read -a array <<< "$starters"
		for starter in "${array[@]}"
		do
			 echo " Proz. Starter: $starter"
		done
        echo
        let COUNTER+=1 
done


