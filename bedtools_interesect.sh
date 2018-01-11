#!/bin/bash

for vcf in /media/sf_BigShare/SCID/Sanger/170105_TruSeq_r1/vcfeval_*_r1/fp.vcf
do
	bedtools intersect -a $vcf -b /media/sf_BigShare/SCID/reference/161227_SCID_Exons_w_20bp_Padding.bed -loj > ${vcf}.olap.region.txt
done
