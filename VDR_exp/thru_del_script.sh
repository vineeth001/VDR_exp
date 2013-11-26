#!/bin/zsh
LIMIT=0.06
RESOLUTION=0.001
#to print range of PIR
PIR_RANGE=../../VDR_exp/pir_range.csv
> $PIR_RANGE
for a in $(seq 0.01 $RESOLUTION $LIMIT)   # Double parentheses, and "LIMIT" with no "$".
do
    echo $a >> $PIR_RANGE
done 


SIMUL_RES=../../VDR_exp/res.csv                  #simulation results
DEL_RES=../../VDR_exp/del_res.csv                #pattern matched results for delay
THRU_RES=../../VDR_exp/thru_res.csv                #pattern matched results for throughput
> $SIMUL_RES           # empty res.txt everytime
> $DEL_RES              # empty 
> $THRU_RES              # empty 
for a in $(seq 0.01 $RESOLUTION $LIMIT)   
do
  
  echo PIR=$a ____________________________________________________________ >> $SIMUL_RES
  ./noxim -dimx 8 -dimy 8 -sim 50000 -warmup 10000 -pir $a 0 >> $SIMUL_RES
done                          

awk '$4 == "delay" {print $6}' $SIMUL_RES >> $DEL_RES              #pattern matching for delay
awk '$4 == "throughput" { print $6}' $SIMUL_RES >> $THRU_RES              #pattern matching for delay


