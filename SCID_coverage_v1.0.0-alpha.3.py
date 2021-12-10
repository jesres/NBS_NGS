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

parser.add_argument("-s", "--sample", help="sample name", required=True)
parser.add_argument("-i", "--input", help="input per-base file", required=True)
parser.add_argument("-t", "--target_bed", help="target bed", required=True)
parser.add_argument("-o", "--output", help="output file", required=True)
args = parser.parse_args() 


perbase = BedTool(args.input)
target = BedTool(args.target_bed)

result = perbase.intersect(target, wa=True, wb=True, nonamecheck=True)
df = result.to_dataframe()
df.columns = ['Cov_Chr','Cov_Start','Cov_Stop','Cov','Region_Chr','Region_Start','Region_Stop','Region_Name']

#print df
encoding='utf-8-sig'

#either for loop, going through each element and calc size with min of each stop and max of start

#or some pandas command to check the min/max while calculating size for the whole data frame

#from: https://stackoverflow.com/questions/33975128/pandas-get-the-row-wise-minimum-value-of-two-or-more-columns
#data['min_c_h'] = data[['flow_h','flow_c']].min(axis=1)

df['interval_start'] = df[['Cov_Start','Region_Start']].max(axis=1)
df['interval_stop'] = df[['Cov_Stop','Region_Stop']].min(axis=1)
df['Size'] = df['interval_stop']-df['interval_start']
df['Cov_Size_Corr'] = df['Cov']*df['Size']

#for filtering on different regions
intron = df['Region_Name'].str.contains('intron')
utr = df['Region_Name'].str.contains('utr')
cds = df['Region_Name'].str.contains('exon')


#sum bases per region
bases_total = df['Size'].sum()
bases_intron = df[intron]['Size'].sum()
bases_utr = df[utr]['Size'].sum()
bases_cds = df[cds]['Size'].sum()


#sum coverage per region
cov_total = df['Cov_Size_Corr'].sum()
cov_intron = df[intron]['Cov_Size_Corr'].sum()
cov_utr = df[utr]['Cov_Size_Corr'].sum()
cov_cds = df[cds]['Cov_Size_Corr'].sum()


#averages
ave_cov_total = round(cov_total/bases_total,0)
ave_cov_intron = round(cov_intron/bases_intron,0)
ave_cov_utr = round(cov_utr/bases_utr,0)
ave_cov_cds = round(cov_cds/bases_cds,0)


#predefine thresholds for uniformity
total_un = ave_cov_total*0.2
intron_un = ave_cov_intron*0.2
utr_un = ave_cov_utr*0.2
cds_un = ave_cov_cds*0.2


#now uniformity
uni_total_bases = df[(df.Cov > total_un)]['Size'].sum()
uni_intron_bases = df[intron & (df.Cov > intron_un)]['Size'].sum()
uni_utr_bases = df[utr & (df.Cov > utr_un)]['Size'].sum()
uni_cds_bases = df[cds & (df.Cov > cds_un)]['Size'].sum()


#print uni_total_bases
#print uni_cds_bases
#print bases_cds


per_uni_total = round((uni_total_bases/bases_total)*100,1)
per_uni_intron = round((uni_intron_bases/bases_intron)*100,1)
per_uni_utr = round((uni_utr_bases/bases_utr)*100,1)
per_uni_cds = round((uni_cds_bases/bases_cds)*100,1)


#print per_uni_cds

#format regions per sample for output
combine_out = pd.DataFrame({'Sample':[args.sample],
							'Average_Coverage_Overall': [ave_cov_total],
							'Average_Coverage_Exon': [ave_cov_cds],
							'Average_Coverage_Intron': [ave_cov_intron],
							'Average_Coverage_UTR': [ave_cov_utr],
							'Uniformity_Overall': [per_uni_total],
							'Uniformity_Exon': [per_uni_cds],
							'Uniformity_Intron': [per_uni_intron],
							'Uniformity_UTR': [per_uni_utr]})
#order columns
combine_out = combine_out[['Sample','Average_Coverage_Overall','Average_Coverage_Exon','Average_Coverage_Intron','Average_Coverage_UTR','Uniformity_Overall','Uniformity_Exon','Uniformity_Intron','Uniformity_UTR']]

#output each. mode='a' to append
combine_out.to_csv(args.output, mode='a' ,sep='\t', header = False, index = False, index_label = False)



