#!/bin/bash

vcf_dir=$1
output_dir=$2


if [ $# -ne 2 ];then
    printf "Usage: $0 vcf_dir output_dir\n" 
    exit 1
fi


for vcf in $vcf_dir/*.TSCAfilters.vcf.gz
do
	sample_base=${vcf##*/}
	sample_base_no_ext=${sample_base%%.*}
	out=${output_dir}/${sample_base_no_ext}_filtered
	
	bcftools stats -f PASS,PASS_QD,PASS_LOW_SB,PASS_HIGH_QUAL,PASS_DEFAULT -e 'FMT/ROI="OUTSIDE_ROI"' $vcf > $out
done
