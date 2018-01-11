#!/bin/bash

input_dir=$1
output_dir=$2
if [ $# -ne 2 ];then
    printf "Usage: $0 input_dir output_dir\n" 
    exit 1
fi


for fastq in $input_dir/*.fastq.gz
do
	fastqc $fastq --outdir $output_dir

done
