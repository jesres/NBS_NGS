#!/bin/bash

fastq_dir=$1
output_dir=$2


if [ $# -ne 2 ];then
    printf "Usage: $0 fastq_dir output_dir\n" 
    exit 1
fi


for fastq in $fastq_dir/*.fastq.gz
do
	fastqc -o $output_dir --noextract -t 5 $fastq
done
