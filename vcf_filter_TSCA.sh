#!/bin/bash

input_dir=$1
if [ $# -ne 1 ];then
    printf "Usage: $0 input_dir\n" 
    exit 1
fi

for vcf in $input_dir/*.vcf
do
	vcfBaseNoExt="${vcf%.*}"
	newFileName=${vcfBaseNoExt}.TSCAfilters.vcf
	bcftools filter -i 'FMT/DP>=3 & FMT/GQ[*]>=3.01 & FMT/GQX[*]>=16 & INFO/QD>=2.87 & QUAL>=72.9 & FMT/VF[*]>=0.156' -m x -s + $vcf > $newFileName
	bgzip -c $newFileName > ${newFileName}.gz
	tabix -p vcf ${newFileName}.gz
done
