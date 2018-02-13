#!/bin/bash

input_regions_file=$1
output_regions_file=$2


if [ $# -ne 2 ];then
    printf "Usage: $0 input_regions_file output_regions_file" 
    exit 1
fi

while read p; do
  samtools faidx /usr/local/share/bcbio/genomes/Hsapiens/GRCh37/seq/GRCh37.fa $p >> $output_regions_file;
done <$input_regions_file

