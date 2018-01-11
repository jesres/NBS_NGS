#!/bin/bash

input_dir=$1
output_dir=$2
if [ $# -ne 2 ];then
    printf "Usage: $0 input_dir output_dir\n" 
    exit 1
fi


for bam in $input_dir/*.bam
do
	bam_base=${bam##*/}
	bam_base_no_ext=${bam_base%%.*}
	out_qualimap="$output_dir/$bam_base_no_ext"
	qualimap bamqc -bam $bam -gd hg19 -gff /media/sf_BigShare/SCID/reference/SCIDv2-2_targets_sorted.bed -outdir $out_qualimap
done
