#!/bin/bash
touch data.txt
rm data.txt
touch data.txt
#vary area size

repeatation=$1
for ((i = 1; i < 6; i++))
do
    for (( j = 0; j < $repeatation; j++))
    do
        ns ./1805106.tcl $(($i * 250)) 40 20 >> temp_file_106.txt 2>> temp_file_106.txt
        awk -f 1805106.awk trace.tr >> temp_file_106.txt
        # rm temp_file_106.txt
    done
done

echo "AREA DONE"
#vary node number
for ((i = 1; i < 6; i++))
do
    for (( j = 0; j < $repeatation; j++))
    do
        ns ./1805106.tcl 500 $(($i * 20)) 20 >> temp_file_106.txt 2>> temp_file_106.txt
        awk -f 1805106.awk trace.tr >> temp_file_106.txt
        # rm temp_file_106.txt
    done
done


echo "NODE DONE"

#vary flow number
for ((i = 1; i < 6; i++))
do
    for (( j = 0; j < $repeatation; j++))
    do
        ns ./1805106.tcl 500 40 $(($i * 10)) >> temp_file_106.txt 2>> temp_file_106.txt
        awk -f 1805106.awk trace.tr >> temp_file_106.txt
        # rm temp_file_106.txt
    done
done


echo "FLOW DONE"

rm temp_file_106.txt

python3 1805106.py $repeatation