#!/bin/bash

input_dir=$1
output_dir=$2
if [ $# -ne 2 ];then
    printf "Usage: $0 input_dir output_dir\n" 
    exit 1
fi


for vcf in $input_dir/*.vcf.gz
do
	vcf_base=${vcf##*/}
	vcf_base_no_ext=${vcf_base%%.*}
	out_bcftools_stats="$output_dir/${vcf_base_no_ext}-bcftools-stats"
	#note: only filtered variants will be in the bcftools stats analysis... delete -f PASS if you want all variants present in stats file
	bcftools stats -f PASS $vcf > $out_bcftools_stats
done
