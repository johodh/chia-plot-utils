procalive="1"

while [ ! -z $procalive ] 
do  
	procalive=$(ps aux | awk '{print $2}' | grep $1)
	tstamp=$(date +%Y-%m-%d_%H:%M:%S | sed 's/_/ /g')
	echo "$tstamp $procalive is still alive, waiting.."
	sleep 30
done

newplot $2
