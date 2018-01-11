#!/bin/bash
intervar_file=$1
vcf_file=$2
target_base=${target_bed##*/}
target_base_no_ext=${target_base%%.*}

if [ $# -ne 2 ];then
    printf "Usage: $0 file1 file2\n" 
    exit 1
fi

awk 'NR==FNR{a[$1,$2]=$6OFS$7OFS$8OFS$9OFS$10;next}{$6=a[$1,$2,$3];print}' OFS='\t' $vcf_file $intervar_file

6,7,8,9,10

####NOT FUNCTIONAL. FOUND ALT METHOD. ABANDONED SCRIPT!####