#!/bin/bash

for vcf in /media/sf_BigShare/SCID/Ion/vcfs/*.vcf
do
	/media/sf_BigShare/Tools/CAVA-1.2.0/cava.py -c /media/sf_BigShare/Tools/CAVA-1.2.0/config.txt -i $vcf -o ${vcf}.cava
done
