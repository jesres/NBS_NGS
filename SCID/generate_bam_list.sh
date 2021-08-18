#!/bin/bash

bam_dir=$1
output_dir=$2
work_dir=$3
reference_dir=$4
cumulative_bam_list=$5

if [ $# -ne 4 ];then
    printf "Usage: $0 bam_dir output_dir work_dir reference_dir cumulative_bam_list\n" 
    exit 1
fi

NTC="NTC"

for bam in $bam_dir/*.bam
do
	if [[ $bam =~ $NTC ]];
	then
		echo "skipping NTC for bam list"
	else
		echo $bam >> $cumulative_bam_list
	fi
done


