#!/bin/bash
LIMIT=0.05
RESOLUTION=0.001
TRAFFIC=(random transpose1 transpose2 bitreversal butterfly shuffle)	#synthetic traffic patterns

#to print range of PIR
PIR_RANGE=../../VDR_exp/pir_range.csv
> $PIR_RANGE
for a in $(seq 0.01 $RESOLUTION $LIMIT)   
do
    echo $a >> $PIR_RANGE
done 

#stat collection files
for t in $(seq 0 5)
do
	SIMUL_RES[t]=../../VDR_exp/${TRAFFIC[t]}/res.csv                  #simulation results
	DEL_RES[t]=../../VDR_exp/${TRAFFIC[t]}/del_res.csv                #pattern matched results for delay
	THRU_RES[t]=../../VDR_exp/${TRAFFIC[t]}/thru_res.csv                #pattern matched results for throughput
	FIN_DEL[t]=../../VDR_exp/${TRAFFIC[t]}/fin_del.csv
	FIN_THRU[t]=../../VDR_exp/${TRAFFIC[t]}/fin_thru.csv
	
done

#clearing up before a new simulation
for t in $(seq 0 5)
do
	> ${SIMUL_RES[t]}           # empty res.txt everytime
	> ${DEL_RES[t]}              # empty 
	> ${THRU_RES[t]}              # empty 
done


for t in $(seq 0 5)
do
	for a in $(seq 0.01 $RESOLUTION $LIMIT)   
	do
  
	  echo PIR=$a _____________________${TRAFFIC[t]}" traffic"_______________________ >> ${SIMUL_RES[t]}
	  ./noxim -dimx 8 -dimy 8 -traffic ${TRAFFIC[t]} -sim 50000 -warmup 10000 -pir $a 0 >> ${SIMUL_RES[t]}
	done      

done

for t in $(seq 0 5)
do
		awk '$4 == "delay" {print $6}' ${SIMUL_RES[t]} >> ${DEL_RES[t]}             	#pattern matching for delay
		awk '$4 == "throughput" { print $6}' ${SIMUL_RES[t]} >> ${THRU_RES[t]}              #pattern matching for delay
		
		#merging
		paste ../../VDR_exp/pir_range.csv ${DEL_RES[t]} | awk '{print $1,$2}'> ${FIN_DEL[t]}
		paste ../../VDR_exp/pir_range.csv ${THRU_RES[t]} | awk '{print $1,$2}'> ${FIN_THRU[t]}

		#plot graphs		
		gnuplot <<- EOF
		set terminal jpeg
		set output '../../VDR_exp/${TRAFFIC[t]}/thru_plot.jpeg'
		set title "Throughput vs Applied Load (traffic: ${TRAFFIC[t]})" 
		set xlabel "Applied Load (in packets per cycles per node)" 
		set ylabel "Throughput (in flits per cylce)" 
		plot "${FIN_THRU[t]}" using 1:2 with lines notitle
		EOF

		gnuplot <<- EOF
		set terminal jpeg
		set output '../../VDR_exp/${TRAFFIC[t]}/del_plot.jpeg'
		set title "Delay vs Applied Load (traffic: ${TRAFFIC[t]})" 
		set xlabel "Applied Load (in packets per cycles per node)" 
		set ylabel "Delay (in cylces)" 
		plot "${FIN_DEL[t]}" using 1:2 with lines notitle
		EOF
done

