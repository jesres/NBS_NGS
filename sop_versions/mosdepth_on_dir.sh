#!/bin/bash

input_dir=$1
output_dir=$2
target_bed=$3
target_base=${target_bed##*/}
target_base_no_ext=${target_base%%.*}

if [ $# -ne 3 ];then
    printf "Usage: $0 input_dir output_dir target_bed\n" 
    exit 1
fi


for bam in $input_dir/*.bam
do
	bam_base=${bam##*/}
	bam_base_no_ext=${bam_base%%.*}
	out=${output_dir}/${bam_base_no_ext}_${target_base_no_ext}
	mkdir -p $output_dir
	mosdepth --by $target_bed --threads 4 $out $bam	
done
