#!/bin/bash

source $HOME/.plotsettings

most_plots_left=0

for d in ${destdirs[@]}; do 
	freespace=$(df -B1 $d | tail -1 | awk '{print $4}')
	plots_left=$((${freespace}/${plot_size})) 
	echo "$d could hold another $plots_left plots."
	if [ $plots_left -gt $most_plots_left ]; then 
		current_destdir=$d
		most_plots_left=$plots_left
	fi
done

if [ $most_plots_left -gt 1 ]; then 
	echo "the current destination dir will be: $current_destdir that has enough free space to store $most_plots_left" more plots
else echo "there is no space left on any of the specified temp dirs"
fi
