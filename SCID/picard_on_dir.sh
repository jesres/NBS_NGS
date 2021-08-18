#!/bin/bash

bam_dir=$1
output_dir=$2
reference_dir=$3


if [ $# -ne 3 ];then
    printf "Usage: $0 bam_dir output_dir reference_sequence\n" 
    exit 1
fi


for bam in $bam_dir/*.bam
do
	sample_base=${bam##*/}
	sample_base_no_ext=${sample_base%%.*}
	out=${output_dir}/${sample_base_no_ext}_pcr_metrics.txt
	picard CollectTargetedPcrMetrics \
	I=$bam \
    O=$out \
    R=${reference_dir}/ucsc.hg19.fa \
    AMPLICON_INTERVALS=${reference_dir}/SCID_v2-2_Amplicons.interval_list \
    TARGET_INTERVALS=${reference_dir}/SCIDv2-2_Targets.interval_list \
	VALIDATION_STRINGENCY=SILENT
done
