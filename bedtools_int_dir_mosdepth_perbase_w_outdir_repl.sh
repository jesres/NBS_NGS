#!/bin/bash

input_dir=$1
target_bed=$2
out_dir=$3
target_base=${target_bed##*/}
target_base_no_ext=${target_base%%.*}

if [ $# -ne 3 ];then
    printf "Usage: $0 input_dir target_bed output_dir\n" 
    exit 1
fi


for sample in $input_dir/*.per-base_collapsed_repl.bed
do
	out=$out_dir/${sample##*/}_intersect_${target_base_no_ext}.txt
	bedtools intersect -a $target_bed -b $sample -wao > $out
done
