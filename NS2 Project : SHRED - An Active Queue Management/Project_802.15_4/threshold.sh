#!/bin/bash
touch data2.txt
rm data2.txt
touch data2.txt

repeatation=$1
#vary rate number
for (( j = 1; j <= $repeatation; j++))
do
    ns ./1805106.tcl 40 20 $(($j * 100)) 10 true >> data2.txt 2>> temp_file_106.txt
    echo "" >> data2.txt
done


rm temp_file_106.txt

python3 ThresholdPlotter.py
