#!/bin/bash

input_dir=$1
if [ $# -ne 1 ];then
    printf "Usage: $0 input_dir\n" 
    exit 1
fi

for vcf in $input_dir/*.vcf.gz
do
	vcfBaseNoExt="${vcf%.*}"
	newFileName=${vcfBaseNoExt}.TSCAfilters.vcf
	/media/sf_BigShare/Tools/rtg-core-non-commercial-3.8.4/rtg vcffilter -i $vcf -o $newFileName --keep-expr '(!has(SAMPLES.VF) || SAMPLES.VF >= 0.253) && (!has(SAMPLES.GQ) || SAMPLES.GQ >= 75.3) && (!has(SAMPLES.GQX) || SAMPLES.GQX >= 75) && (!has(INFO.MQ) || INFO.MQ >= 47)  && (!has(INFO.QD) || INFO.QD >= 2.15) && (!has(QUAL) || QUAL >= 402)  && (!has(INFO.DP) || INFO.DP >= 25) && (!has(INFO.ReadPosRankSum) || INFO.ReadPosRankSum >= -14.1)  && (!has(INFO.BaseQRankSum) || INFO.BaseQRankSum >= -21.3)' --fail=FAIL
done