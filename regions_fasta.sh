#!/bin/bash


while read p; do
  samtools faidx /usr/local/share/bcbio/genomes/Hsapiens/GRCh37/seq/GRCh37.fa $p;
done </media/sf_BigShare/SCID/Sanger/171204-v3/171204-Regions.txt

