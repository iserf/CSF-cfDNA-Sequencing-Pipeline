#!/usr/bin/python

import sys
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split

##functions
def skip_meta_info(vcf_file):
    vcf_raw=open(vcf_file)
    i=1
    for line in vcf_raw:
        if line.startswith('##'):
            i = i+1
    #skip vcf header lines starting with ##
    vcf_out_wo_meta = pd.read_csv(vcf_file, skiprows=i, sep='\t', lineterminator='\n')
    return(vcf_out_wo_meta)


#files
input_vcf=sys.argv[1]
input_df=skip_meta_info(input_vcf) #read-in input-vcf as data-frame
train_out=sys.argv[2]
test_out=sys.argv[3]
seed=sys.argv[4]

#Perform train test split
df_train, df_test = train_test_split(input_df, test_size=0.2, random_state=int(seed))

#Write output files
vcf_raw=open(input_vcf)
output_train = open(train_out,'a')
output_test = open(test_out,'a')
for line in vcf_raw:
    if line.startswith('#'):
        output_train.write(line)
        output_test.write(line)

df_train.to_csv(output_train, mode='a', sep='\t', header=False)
df_test.to_csv(output_test, mode='a', sep='\t', header=False)

