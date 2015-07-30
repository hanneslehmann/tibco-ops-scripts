#!/bin/env bash

##
#   Description:    This shell script will print out to the terminal some information about
#                   running bwengines instances. Will be enhanced to use for ops guys taking
#                   over an BW infrastructure to get a first idea
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
        echo "-------------------------------------------------------------------------------------"
        echo " Product:       Tibco BusinessWorks Engine"
        echo " Number:        $COUNTER"
        echo " PID:           $pid "
	echo " Domain:        $domain"
        echo " Executable:    $bin"
	echo " TRA:           $tra"
	echo " Repo:          $repo"
	for params in $details
	do
		 [[ $params == *.log ]] && echo " Logfile:       $params"
	done
	echo " HEAP:          $heap"
	IFS=',' read -a array <<< "$starters"
	for starter in "${array[@]}"
	do
		 echo " Proc. Starter: $starter"
	done
	for process in `find  $repo | grep ".process"`
	do
		echo " Process:       $process"
	done 
        echo
        let COUNTER+=1 
done


