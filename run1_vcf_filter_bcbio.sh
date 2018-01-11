#!/bin/bash

work_dir=/media/sf_BigShare/SCID/bcbio_projects/170310_SCID_TSCA_run1/170315_vcfeval/input/for_filter
for vcf in $work_dir/*.vcf.gz
do
	vcfBaseNoExt="${vcf%.*}"
	newFileName=${vcfBaseNoExt}.run1filters.vcf
	bcftools filter -i 'FMT/DP>=13 & QUAL>=1500' $vcf > $newFileName
	bgzip -c $newFileName > ${newFileName}.gz
	tabix -p vcf ${newFileName}.gz
done
