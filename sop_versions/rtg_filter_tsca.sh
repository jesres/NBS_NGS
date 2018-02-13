#!/bin/bash

vcf_dir=$1
output_dir=$2

if [ $# -ne 2 ];then
    printf "Usage: $0 vcf_dir output_dir\n" 
    exit 1
fi

for vcf in $vcf_dir/*.vcf
do
	sample_base=${vcf##*/}
	sample_base_no_ext=${sample_base%%.*}
	vcf_comp_out=${vcf_dir}/${sample_base_no_ext}.gz
	
	bgzip -i -c $vcf > $vcf_comp_out
	tabix -f -p vcf $vcf_comp_out
	
	newFileName=${output_dir}/${sample_base_no_ext}.TSCAfilters.vcf
	echo $sample_base_no_ext
	/home/rsicko/bin/rtg-core-non-commercial-3.8.4/rtg vcffilter \
	-i $vcf_comp_out -o $newFileName --keep-expr '(!has(SAMPLES.VF) || SAMPLES.VF >= 0.156) && (!has(SAMPLES.GQ) || SAMPLES.GQ >= 3.01) && (!has(SAMPLES.GQX) || SAMPLES.GQX >= 16) && (!has(INFO.QD) || INFO.QD >= 2.87) && (!has(QUAL) || QUAL >= 72.9) && (!has(INFO.DP) || INFO.DP >= 3)' \
	--fail=filtered
done