logdir=/home/jo/plotlogs

for f in $logdir/*; do 
	if [ -f $f ]; then 
		i=1
		plotname=$(echo $f | awk -F '/' '{print $NF}')
		plotrow=$plotname
		while [ $i -ne 5 ]; do 
			phase=$(cat $f | grep "phase ${i} =")
			pduration=$(echo $phase | awk '{print $6}')
			ptime=$(echo $phase | awk '{print $10,$11,$12,$13}')
			pcpu=$(echo $phase | awk '{print $9}' | tr -d '()')
		
			# tidying up
			if [ ! -z "$ptime" ]; then ptime=${ptime:0:-3}; fi
			if [ ! -z "$pduration" ]; then pduration=${pduration:0:-4}; fi

			phaserow=";$ptime;${pduration};$pcpu"
			plotrow+=$phaserow
			i=$((i+1))
		done
		echo $plotrow
	fi
done | column -s ';' -t -N PLOT,"PHASE 1 FINISHED","TIME (s)","CPU","PHASE 2 FINISHED","TIME (s)","CPU","PHASE 3 FINISHED","TIME (s)","CPU","PHASE 4 FINSHED","TIME(s)","CPU" -o ' | ' 
