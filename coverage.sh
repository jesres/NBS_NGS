#!/bin/bash

input=$1
bq=$2
mq=$3
output=$4

if [ $# -ne 4 ];then
    printf "Usage: $0 input_file base_qual_cutoff map_qual_cutoff output_file\n" 
    exit 1
fi

#calc depth

samtools depth -aa -b /media/sf_BigShare/SCID/Ion/Design/WG_IAD68323_5.20170321.designed.bed -q $bq -Q $mq -f $input > $output
