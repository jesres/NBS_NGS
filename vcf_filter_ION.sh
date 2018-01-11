#!/bin/bash

input_dir=$1
if [ $# -ne 1 ];then
    printf "Usage: $0 input_dir\n" 
    exit 1
fi

for vcf in $input_dir/*.vcf
do
	vcfBaseNoExt="${vcf%.*}"
	newFileName=${vcfBaseNoExt}.Ionfilters.vcf
	#fmt fields GT:GQ:DP:FDP:RO:FRO:AO:FAO:AF:SAR:SAF:SRF:SRR:FSAR:FSAF:FSRF:FSRR
	#using FMT/FIELD[*] means if ANY of the vector numbners match that condition, the variant will pass
	bcftools filter -i 'FMT/DP>=13 & FMT/AF[*]>=0.29 & FMT/AO[*]>=8 & FMT/FAO[*]>=8 & FMT/FDP[*]>=13 & INFO/QD>=2.34 & QUAL>=52.6 & INFO/FWDB[*]>=-0.129 & INFO/SSSB[*]>=-0.613 & INFO/VARB[*]>=-0.285' -m x -s + $vcf > $newFileName
	bgzip -c $newFileName > ${newFileName}.gz
	tabix -p vcf ${newFileName}.gz
done
