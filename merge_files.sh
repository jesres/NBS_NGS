#!/bin/bash
for f in /media/sf_BigShare/SCID/Illumina/cnv/cnvkit/*.call.cns
do
 echo ${f} >> output_merged.txt
 cat $f >> output_merged.txt
done