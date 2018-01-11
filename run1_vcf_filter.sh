#!/bin/bash

work_dir=/media/sf_BigShare/SCID/Illumina/vcfs/run1/for_filter/
for vcf in $work_dir/*.vcf.gz
do
	vcfBaseNoExt="${vcf%.*}"
	newFileName=${vcfBaseNoExt}.run1filters.vcf
	bcftools filter -i 'FMT/DP>=10 & FMT/GQ>=95 & INFO/QD>=4 & QUAL>=330 & FMT/VF>=0.190' $vcf > $newFileName
	bgzip -c $newFileName > ${newFileName}.gz
	tabix -p vcf ${newFileName}.gz
done
