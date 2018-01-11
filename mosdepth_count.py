import pandas as pd
import argparse
import os
import sys

#arguments
parser = argparse.ArgumentParser(description="Generate counts by sample and total bases by sample of low coverage regions") 

parser.add_argument("-i", "--input", help="input filename", required=True)
parser.add_argument("-o", "--output", help="output basename", required=True) 

args = parser.parse_args() 

#output filenames
region_count_file = args.output + "_region_count.txt"
bases_count_file = args.output + "_bases_count.txt"
sample_count_file = args.output + "_sample_count.txt"
region_count_file_html = args.output + "_region_count.html"
bases_count_file_html = args.output + "_bases_count.html"

#read in
df = pd.read_table(args.input)

#check output doesn't exist
if os.path.exists(region_count_file) or os.path.exists(bases_count_file) or os.path.exists(sample_count_file):
    sys.exit("ERROR: output basename %s files already exist" % args.output)

#for filtering on different regions
intron = df['Region'].str.contains('intron')
utr = df['Region'].str.contains('utr')
cds = df['Region'].str.contains('cds')

#count regions per sample
unique_regions = df.groupby('Sample').Region.nunique()
unique_intron = df[intron].groupby('Sample').Region.nunique()
unique_utr = df[utr].groupby('Sample').Region.nunique()
unique_cds = df[cds].groupby('Sample').Region.nunique()

#sum bases per sample
bases_total = df.groupby(['Sample'])['Overlap'].sum()
bases_intron = df[intron].groupby(['Sample'])['Overlap'].sum()
bases_utr = df[utr].groupby(['Sample'])['Overlap'].sum()
bases_cds = df[cds].groupby(['Sample'])['Overlap'].sum()

#count samples per region
samples_per_region = df.groupby('Region').Sample.nunique()

#format regions per sample for output
combine_region_count = pd.concat([unique_regions,unique_intron,unique_utr,unique_cds], axis=1)
combine_region_count.columns = 'Total','Intron','UTR','CDS'

#format bases per sample for output
combine_bases = pd.concat([bases_total,bases_intron,bases_utr,bases_cds], axis=1)
combine_bases.columns = 'Total','Intron','UTR','CDS'

#format samples per region for output
#samples_per_region.reset_index(name='Num Samples')
#not sure why this is not working, but not that important


#output each
combine_region_count.to_csv(region_count_file,sep='\t')
combine_bases.to_csv(bases_count_file,sep='\t')
samples_per_region.to_csv(sample_count_file,sep='\t')
combine_region_count.to_html(region_count_file_html)
combine_bases.to_html(bases_count_file_html)
