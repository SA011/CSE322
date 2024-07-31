#!/bin/bash
touch data.txt
rm data.txt
touch data.txt

#vary node size
repeatation=$1
prev=1
tot=$#
if((tot >= 2))
then
    prev=$2
fi
for ((i = 1; i < 6; i++))
do
    for (( j = 0; j < $repeatation; j++))
    do
        ns ./1805106.tcl $(($i * 20)) 20 200 10 true >> temp_file_106.txt 2>> temp_file_106.txt
        awk -f 1805106.awk trace.tr >> temp_file_106.txt
        if ((prev == 1))
        then
            ns ./1805106.tcl $(($i * 20)) 20 200 10 false >> temp_file_106.txt 2>> temp_file_106.txt
            awk -f 1805106.awk trace.tr >> temp_file_106.txt
        fi
        # rm temp_file_106.txt
    done
done

echo "NODE DONE"
#vary flow number
for ((i = 1; i < 6; i++))
do
    for (( j = 0; j < $repeatation; j++))
    do
        ns ./1805106.tcl 40 $(($i * 10)) 200 10 true >> temp_file_106.txt 2>> temp_file_106.txt
        awk -f 1805106.awk trace.tr >> temp_file_106.txt
        if ((prev == 1))
        then
            ns ./1805106.tcl 40 $(($i * 10)) 200 10 false >> temp_file_106.txt 2>> temp_file_106.txt
            awk -f 1805106.awk trace.tr >> temp_file_106.txt
        fi
        # rm temp_file_106.txt
    done
done


echo "FLOW DONE"

#vary rate number
for ((i = 1; i < 6; i++))
do
    for (( j = 0; j < $repeatation; j++))
    do
        ns ./1805106.tcl 40 20 $(($i * 100)) 10 true >> temp_file_106.txt 2>> temp_file_106.txt
        awk -f 1805106.awk trace.tr >> temp_file_106.txt
        if ((prev == 1))
        then
            ns ./1805106.tcl 40 20 $(($i * 100)) 10 false >> temp_file_106.txt 2>> temp_file_106.txt
            awk -f 1805106.awk trace.tr >> temp_file_106.txt
        fi
        # rm temp_file_106.txt
    done
done


echo "RATE DONE"

#vary speed number
for ((i = 1; i < 6; i++))
do
    for (( j = 0; j < $repeatation; j++))
    do
        ns ./1805106.tcl 40 20 200 $(($i * 5)) true >> temp_file_106.txt 2>> temp_file_106.txt
        awk -f 1805106.awk trace.tr >> temp_file_106.txt
        if ((prev == 1))
        then
            ns ./1805106.tcl 40 20 200 $(($i * 5)) false >> temp_file_106.txt 2>> temp_file_106.txt
            awk -f 1805106.awk trace.tr >> temp_file_106.txt
        fi
        # rm temp_file_106.txt
    done
done


echo "SPEED DONE"

rm temp_file_106.txt

python3 1805106.py $repeatation $prev
