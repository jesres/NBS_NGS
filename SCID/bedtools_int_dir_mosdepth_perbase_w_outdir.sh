#!/bin/bash

input_dir=$1
out_dir=$2
target_bed=$3
target_base=${target_bed##*/}
target_base_no_ext=${target_base%%.*}

if [ $# -ne 3 ];then
    printf "Usage: $0 input_dir output_dir target_bed \n" 
    exit 1
fi


for sample in $input_dir/*.per-base.bed.gz
do
	out=$out_dir/${sample##*/}_intersect_${target_base_no_ext}.txt
	mkdir -p $out_dir
	bedtools intersect -a $target_bed -b $sample -wao > $out
done
