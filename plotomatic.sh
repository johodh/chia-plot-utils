#!/bin/bash

function LOG
{
	if test $1 = "e"; then event="[error]:"
	elif test $1 = "s"; then event="[success]:"
	elif test $1 = "info"; then event="[info]:"
	else event="";
	fi
	timestamp=$(date +%Y-%m-%d_%H:%M | sed 's/_/ /g')
	echo [${timestamp}] $event $2 
}

#infiloop
while true; do 
	source $HOME/.plotsettings

	proc_pids=($(ps -eo pid,cmd | grep -e "$python_venv $chia_bin plots create" | awk '{print $1}' | head -n -1))
	proc_starts=($(ps -eo start_time,cmd | grep -e "$python_venv $chia_bin plots create" | awk '{print $1}' | head -n -1))
	proc_times=($(ps -eo etimes,cmd | grep -e "$python_venv $chia_bin plots create" | awk '{print $1}' | head -n -1))
	proc_destdirs=($(ps -eo cmd | grep -e "$python_venv $chia_bin plots create" | grep -o -e "\-t.* \-d.*" | awk '{print $4}' | head -n -1))

	# every other minute we'll do some tests to decide if starting more plots is a good idea

	# 1. maximum number of parallell plots exceeded? specify this value in $HOME/.plotsettings with respect to your systems available ram/cpu resources
	
	if [ ${#proc_pids[@]} -ge $maxparallell ]; then 
		LOG info "${#proc_pids[@]} of max $maxparallell plotting processes running. no go."
		test1=0
	else test1=1 && LOG info "${#proc_pids[@]} of max $maxparallell plotting processes running. test passed."
	fi 

	# 2. maximum number of parallell plots per tempdir exceeded? specify this value in $HOME/.plotsettings with respect to available space on your preferred tempdrives
	for ((i=0;i<${#tempdirs[@]};i++)); do 
		proc_tempdirs=($(ps -eo cmd | grep -e "$python_venv $chia_bin plots create" | grep -o -e "\-t.* \-d.*" | awk '{print $2}' | grep ${tempdirs[${i}]} | wc -l))
		if [ $proc_tempdirs -ge ${maxplotspertempdir[$i]} ]; then 
			LOG info "${proc_tempdirs} of max ${maxplotspertempdir[$i]} processes plotting to  ${tempdirs[$i]}. no go."
			test2=0
		else test2=1 && LOG info "${proc_tempdirs} of max ${maxplotspertempdir[$i]} processes plotting to  ${tempdirs[$i]}. test passed." && newplot_tempdir=${tempdirs[$i]} && break
		fi
	done	 
	
	# TODO: 3. is there any space left on $destdir?
	freespace=$(df $destdir | tail -1 | awk '{print $4}')

	# 4. whats the progress of ongoing plots? 
	closeplots=0
	for t in ${proc_times[@]}; do 
		if [ $(($t/60)) -lt $startdelay ]; then closeplots=$(($closeplots+1)); fi
	done
	if [ $closeplots -lt $parallstarts ]; then 
		LOG info "$closeplots of max $parallstarts plots started the last $startdelay min. test passed."
		test3=1
	else test3=0 && LOG info "$closeplots of max $parallstarts plots started the last $startdelay min. no go."  
	fi
	
	if [ $(($test1+$test2+$test3)) -lt 3 ]; then 
		LOG info "sumtest equals no go. reiterating in 10 minutes"
	else LOG success "starting new plot to $newplot_tempdir" && newplot $newplot_tempdir
	fi

	echo "---"

	sleep 600

done


