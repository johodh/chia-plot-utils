#!/bin/bash 

tempdir=$1
if [ ! -f $HOME/.plotsettings ]; echo "error: make sure $HOME/.plotsettings is in place" && exit 1; fi
source $HOME/.plotsettings


if [ -z $tempdir ]; then echo "syntax: newplot <tempdir>" && exit 0; fi
if [ ! -d $tempdir ]; then echo "error: $tempdir is not a directory" && exit 0; fi
if [ ! -d $destdir ]; then echo "error: $destdir is not a directory" && exit 0; fi
if [ ! -d $logdir ]; then echo "error: $logdir is not a directory" && exit 0; fi


tempdirshort=$(echo $tempdir | awk -F '/' '{print $NF}')
logname=`date +%y%m%d-%H%M%S`-$tempdirshort
running=$(ps -eo pid,lstart,cmd | grep -o  "\-t $tempdir" | wc -l)

if [ $running -gt $maxplots ]; then 
	echo "error: $maxplots processes are already plotting to temporary dir $tempdir. change maxplots value and try again" && exit 0; 
fi 

echo "$((running-1)) processes currently plotting to $tempdir. max is $maxplots" 

# execute
nohup $python_venv $chia_bin plots create -k 32 -b 3408 -r 4 -f $farmerkey -p $poolkey -t $tempdir -d $destdir > ${logdir}/${logname} &

 
