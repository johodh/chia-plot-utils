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
	proc_destdirs=($(ps -eo cmd | grep -e "$python_venv $chia_bin plots create" | grep -o -e "\-t.* \-d.*" | awk '{print $4}'))

	# every other minute we'll do some tests to decide if starting more plots is a good idea

	# 1. maximum number of parallell plots exceeded? specify this value in $HOME/.plotsettings with respect to your systems available ram/cpu resources
	
	if [ ${#proc_pids[@]} -ge $maxparallell ]; then 
		LOG info "TEST 1: ${#proc_pids[@]} of max $maxparallell plotting processes running. no go."
		test1=0
	else test1=1 && LOG info "TEST 1: ${#proc_pids[@]} of max $maxparallell plotting processes running. test passed."
	fi 

	# 2. maximum number of parallell plots per tempdir exceeded? specify this value in $HOME/.plotsettings with respect to available space on your preferred tempdrives
	for ((i=0;i<${#tempdirs[@]};i++)); do 
		proc_tempdirs=($(ps -eo cmd | grep -e "$python_venv $chia_bin plots create" | grep -o -e "\-t.* \-d.*" | awk '{print $2}' | grep ${tempdirs[${i}]} | wc -l))
		if [ $proc_tempdirs -ge ${maxplotspertempdir[$i]} ]; then 
			LOG info "TEST 2: ${proc_tempdirs} of max ${maxplotspertempdir[$i]} processes plotting to  ${tempdirs[$i]}. no go."
			test2=0
		else test2=1 && LOG info "TEST 2: ${proc_tempdirs} of max ${maxplotspertempdir[$i]} processes plotting to  ${tempdirs[$i]}. test passed." && newplot_tempdir=${tempdirs[$i]} && break
		fi
	done	 
	
	# 3. is there any space left on the destination disks?

	most_plots_left=0
	LOG info "TEST 3: does destination dirs have enough space?"
	for d in ${destdirs[@]}; do 
		freespace=$(df -B1 $d | tail -1 | awk '{print $4}')
		plots_left=$((${freespace}/${plot_size})) 

		# how many plots with destination $d is currently ongoing? those also need to be accounted for
		# TODO: current ongoing test works but is somewhat flawed, test should be done on device rather than path level as there might be situations with multiple paths on same device.

		ongoing=$(echo ${proc_destdirs[@]} | grep $d | wc -w) 
		actual_plots_left=$(($plots_left-$ongoing))
		LOG info "- $d can store $actual_plots_left more plots. (there is currently enough space for $plots_left plots on device, and there is $ongoing plots with destination $d ongoing.)"
		if [ $actual_plots_left -gt $most_plots_left ]; then 
			newplot_destdir=$d
			most_plots_left=$plots_left
		fi
	done
	
	if [ $most_plots_left -gt 1 ]; then 
		LOG info "TEST 3: choosing $newplot_destdir that has enough free space to store $most_plots_left more plots. test passed" && test3=1
	else LOG info "TEST 3: there is not enough space left on any of the specified temp dirs. no go." && test3=0
	fi

	# 4. whats the progress of ongoing plots? 
	closeplots=0
	for t in ${proc_times[@]}; do 
		if [ $(($t/60)) -lt $startdelay ]; then closeplots=$(($closeplots+1)); fi
	done
	if [ $closeplots -lt $parallstarts ]; then 
		LOG info "TEST 4: $closeplots of max $parallstarts plots started the last $startdelay min. test passed."
		test4=1
	else test4=0 && LOG info "TEST 4: $closeplots of max $parallstarts plots started the last $startdelay min. no go."  
	fi
	
	if [ $(($test1+$test2+$test3+$test4)) -lt 4 ]; then 
		LOG info "SUM TESTS equals no go. reiterating in 10 minutes"
	else LOG success "starting new plot to $newplot_tempdir" && newplot $newplot_tempdir $newplot_destdir
	fi

	echo "---"

	sleep 600

done


