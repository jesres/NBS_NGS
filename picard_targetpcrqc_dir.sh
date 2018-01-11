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
	out_picard="$output_dir/$bam_base_no_ext"
	picard CollectTargetedPcrMetrics I=$bam O=$out_picard VALIDATION_STRINGENCY=SILENT AMPLICON_INTERVALS=/media/sf_BigShare/SCID/reference/SCID_v2-2_Amplicons.interval_list TARGET_INTERVALS=/media/sf_BigShare/SCID/reference/SCIDv2-2_Targets.interval_list
done
