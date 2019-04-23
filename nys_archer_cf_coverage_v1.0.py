from __future__ import division
from decimal import *
import pandas as pd
import argparse
import pybedtools
import os
import sys

from pybedtools import BedTool


#arguments
parser = argparse.ArgumentParser(description="Calculate average coverage and uniformity per region type") 

parser.add_argument("-i", "--input", help="input per-base file", required=True)
parser.add_argument("-t", "--target_bed", help="target bed", required=True)
parser.add_argument("-o", "--output", help="output file", required=True)
args = parser.parse_args() 

#output filenames
combine_out_file = args.output + "_coverage.txt"
combine_out_file_html = args.output + "_coverage.html"

perbase = BedTool(args.input)
target = BedTool(args.target_bed)

result = perbase.intersect(target, wa=True, wb=True, nonamecheck=True)
df = result.to_dataframe()
df.columns = ['Cov_Chr','Cov_Start','Cov_Stop','Cov','Region_Chr','Region_Start','Region_Stop','Region_Name']

#print df
#check output doesn't exist
if os.path.exists(combine_out_file) or os.path.exists(combine_out_file_html):
    sys.exit("ERROR: output basename %s files already exist" % args.output)

encoding='utf-8-sig'

df['Size'] = df['Cov_Stop']-df['Cov_Start']
df['Cov_Size_Corr'] = df['Cov']*df['Size']

#for filtering on different regions
intron = df['Region_Name'].str.contains('intron')
utr = df['Region_Name'].str.contains('utr')
cds = df['Region_Name'].str.contains('cds')
snp = df['Region_Name'].str.contains('snp-amps')
prom = df['Region_Name'].str.contains('promoter')

#sum bases per region
bases_total = df['Size'].sum()
bases_intron = df[intron]['Size'].sum()
bases_utr = df[utr]['Size'].sum()
bases_cds = df[cds]['Size'].sum()
bases_snp_amps = df[snp]['Size'].sum()
bases_prom = df[prom]['Size'].sum()

#sum coverage per region
cov_total = df['Cov_Size_Corr'].sum()
cov_intron = df[intron]['Cov_Size_Corr'].sum()
cov_utr = df[utr]['Cov_Size_Corr'].sum()
cov_cds = df[cds]['Cov_Size_Corr'].sum()
cov_snp_amps = df[snp]['Cov_Size_Corr'].sum()
cov_prom = df[prom]['Cov_Size_Corr'].sum()

#averages
ave_cov_total = round(cov_total/bases_total,0)
ave_cov_intron = round(cov_intron/bases_intron,0)
ave_cov_utr = round(cov_utr/bases_utr,0)
ave_cov_cds = round(cov_cds/bases_cds,0)
ave_cov_snp_amps = round(cov_snp_amps/bases_snp_amps,0)
ave_cov_prom = round(cov_prom/bases_prom,0)

#predefine thresholds for uniformity
total_un = ave_cov_total*0.2
intron_un = ave_cov_intron*0.2
utr_un = ave_cov_utr*0.2
cds_un = ave_cov_cds*0.2
snp_un = ave_cov_snp_amps*0.2
prom_un = ave_cov_prom*0.2

#now uniformity
uni_total_bases = df[(df.Cov > total_un)]['Size'].sum()
uni_intron_bases = df[intron & (df.Cov > intron_un)]['Size'].sum()
uni_utr_bases = df[utr & (df.Cov > utr_un)]['Size'].sum()
uni_cds_bases = df[cds & (df.Cov > cds_un)]['Size'].sum()
uni_snp_amps_bases = df[snp & (df.Cov > snp_un)]['Size'].sum()
uni_prom_bases = df[prom & (df.Cov > prom_un)]['Size'].sum()

#print uni_total_bases
#print uni_cds_bases
#print bases_cds


per_uni_total = round((uni_total_bases/bases_total)*100,1)
per_uni_intron = round((uni_intron_bases/bases_intron)*100,1)
per_uni_utr = round((uni_utr_bases/bases_utr)*100,1)
per_uni_cds = round((uni_cds_bases/bases_cds)*100,1)
per_uni_snps = round((uni_snp_amps_bases/bases_snp_amps)*100,1)
per_uni_prom = round((uni_prom_bases/bases_prom)*100,1)

#print per_uni_cds

#format regions per sample for output
combine_out = pd.DataFrame({'Average Coverage Overall': [ave_cov_total],
							'Average Coverage CDS': [ave_cov_cds],
							'Average Coverage Intron': [ave_cov_intron],
							'Average Coverage UTR': [ave_cov_utr],
							'Average Coverage SNP Amps': [ave_cov_snp_amps],
							'Average Coverage Promoter': [ave_cov_prom],
							'Uniformity Overall': [per_uni_total],
							'Uniformity CDS': [per_uni_cds],
							'Uniformity Intron': [per_uni_intron],
							'Uniformity UTR': [per_uni_utr],
							'Uniformity SNP Amps': [per_uni_snps],
							'Uniformity Promoter': [per_uni_prom]})
#output each
combine_out.to_csv(combine_out_file,sep='\t', index = False)

