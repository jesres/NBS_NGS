#!/bin/bash

input_dir=$1

if [ $# -ne 1 ];then
    printf "Usage: $0 input_dir \n" 
    exit 1
fi

for vcf in $input_dir/*.vcf
do
	vcf_base=${vcf##*/}
	vcf_base_no_ext=${vcf_base%%.*}
	sorted_vcf=${vcf_base_no_ext}_sorted.vcf
	grep '^#' $vcf > $input_dir/$sorted_vcf && grep -v '^#' $vcf | LC_ALL=C sort -t $'\t' -k1,1 -k2,2n >> $input_dir/$sorted_vcf
	bgzip -i $input_dir/$sorted_vcf
	tabix -f -p vcf $input_dir/${sorted_vcf}.gz
done
