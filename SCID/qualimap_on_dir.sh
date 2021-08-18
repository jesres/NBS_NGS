#!/bin/bash

bam_dir=$1
output_dir=$2
target_bed=$3


if [ $# -ne 3 ];then
    printf "Usage: $0 bam_dir output_dir target_bed\n" 
    exit 1
fi


for bam in $bam_dir/*.bam
do
	sample_base=${bam##*/}
	sample_base_no_ext=${sample_base%%.*}
	out=${output_dir}/${sample_base_no_ext}
	qualimap bamqc -bam $bam -gd hg19 -gff $target_bed -outdir $out
done
