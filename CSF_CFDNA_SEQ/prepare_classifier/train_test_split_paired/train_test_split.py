#!/usr/bin/python

import sys
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split

#files
input_df=pd.read_csv(sys.argv[1], sep='\t', lineterminator='\n')
train_out=sys.argv[2]
test_out=sys.argv[3]
seed=sys.argv[4]

#Perform train test split
df_train, df_test = train_test_split(input_df, test_size=0.2, random_state=int(seed))

#Write output files
output_train = open(train_out,'a')
output_test = open(test_out,'a')
df_train.to_csv(output_train, mode='a', sep='\t', index=False)
df_test.to_csv(output_test, mode='a', sep='\t', index=False)

