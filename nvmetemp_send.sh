
while true; 
do 
	temps=$(sensors | grep Composite)
	nvme_a=$(echo $temps | head -1 | awk '{print $2}')
	nvme_b=$(echo $temps | tail -1 | awk '{print $2}')
        nvme_a_round=$(echo ${nvme_a:1:-3} | awk '{print int($1+0.5)}')
	if [ $nvme_a_round -gt 75 ]; then telegram-send "$temps"; fi
	sleep 240
done
