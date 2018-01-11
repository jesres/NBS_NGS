#!/bin/bash

input_dir=$1
if [ $# -ne 1 ];then
    printf "Usage: $0 input_dir\n" 
    exit 1
fi

for vcf in $input_dir/*.vcf.gz
do
	vcfBaseNoExt="${vcf%.*}"
	newFileName=${vcfBaseNoExt}.Ionfilters.vcf
	/media/sf_BigShare/Tools/rtg-core-non-commercial-3.8.4/rtg vcffilter -i $vcf -o $newFileName --keep-expr '(!has(INFO.AF) || INFO.AF >= 0.222) && (!has(INFO.AO) || INFO.AO >= 19) && (!has(INFO.DP) || INFO.DP >= 22) && (!has(INFO.FAO) || INFO.FAO >= 10)  && (!has(INFO.FDP) || INFO.FDP >= 22)  && (!has(INFO.FSAR) || INFO.FSAR >= 4) && (!has(INFO.FWDB) || INFO.FWDB >= -0.246)  && (!has(INFO.GQ) || INFO.GQ >= 14) && (!has(INFO.MLDD) || INFO.MLDD >= 23.2)  && (!has(INFO.QD) || INFO.QD >= 1.25) && (!has(QUAL) || QUAL >= 14) && (!has(INFO.REVB) || INFO.REVB >= -0.332) && (!has(INFO.SAR) || INFO.SAR >= 5) && (!has(INFO.SSSB) || INFO.SSSB >= -0.373)' --fail=FAIL
done