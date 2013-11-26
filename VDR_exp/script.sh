#!/bin/zsh
LIMIT=0.06
> pir_range.csv
for a in $(seq 0.01 0.0001 $LIMIT)   # Double parentheses, and "LIMIT" with no "$".
do
    echo $a >> pir_range.csv
done                           # A construct borrowed from 'ksh93'.

