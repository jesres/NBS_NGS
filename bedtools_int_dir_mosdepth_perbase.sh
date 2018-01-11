#!/bin/bash

input_dir=$1
target_bed=$2
target_base=${target_bed##*/}
target_base_no_ext=${target_base%%.*}

if [ $# -ne 2 ];then
    printf "Usage: $0 input_dir target_bed\n" 
    exit 1
fi


for bed in $input_dir/*.per-base.bed.gz
do
	out=${bed}_intersect_${target_base_no_ext}.txt
	bedtools intersect -a $target_bed -b $bed -wao > $out
done
