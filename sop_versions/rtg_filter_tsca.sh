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
	-i $vcf_comp_out -o $newFileName --keep-expr '(!has(SAMPLES.VF) || SAMPLES.VF >= 0.253) && (!has(SAMPLES.GQ) || SAMPLES.GQ >= 75.3) && (!has(SAMPLES.GQX) || SAMPLES.GQX >= 75) && (!has(INFO.MQ) || INFO.MQ >= 47) && (!has(INFO.QD) || INFO.QD >= 2.15) && (!has(QUAL) || QUAL >= 402) && (!has(INFO.DP) || INFO.DP >= 25) && (!has(INFO.ReadPosRankSum) || INFO.ReadPosRankSum >= -14.1) && (!has(INFO.BaseQRankSum) || INFO.BaseQRankSum >= -21.3)' \
	--fail=filtered
done