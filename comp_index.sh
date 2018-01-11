#!/bin/bash


for vcf in /media/sf_BigShare/SCID/Ion/Val-Run4/updatedTS_vcfs/breakmulti/*.vcf
do
	bgzip -i $vcf
	tabix -f -p vcf ${vcf}.gz
done
