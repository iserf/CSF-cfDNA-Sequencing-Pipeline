#!/usr/bin/python

## Script to plot reads on MYD88_L265 locus: Important Aberation: MYD88:g.3:38141150T>C

import sys
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import Polygon
from matplotlib.pyplot import figure
import seaborn as sns

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

##files
mpileup_report=sys.argv[1]
out_file=sys.argv[2]

#read in data as dataframe
df=skip_meta_info(mpileup_report)
columns=["Start_Position","Tumor_Seq_Allele2","t_ref_count","t_alt_count","DP"]
df_extract=df[columns]
df_extract["VAF"]=df_extract["t_alt_count"] / df_extract["DP"]
df_extract.drop(df_extract.index[df_extract['Tumor_Seq_Allele2'] == "<*>"], inplace=True)

print(df_extract)

#Seaborn plotting
sns.set_theme(style="ticks", palette="pastel")
fig, axes = plt.subplots(1, 2, figsize=(20, 12))

#barplot VAF
a = sns.barplot(data=df_extract, x="Start_Position", y="VAF", hue="Tumor_Seq_Allele2", ax=axes[0])
a.set(title="VAF", xlabel='Position on chr3', ylabel="VAF")
a.set_xticklabels(a.get_xticklabels(),rotation = 90)
a.legend(loc='upper left', borderaxespad=0)

#barplot raw alt read count
b = sns.barplot(data=df_extract, x="Start_Position", y="t_alt_count", hue="Tumor_Seq_Allele2", ax=axes[1])
b.set(title="Alternative read count ", xlabel='Position on chr3', ylabel="Total reads")
b.set_xticklabels(b.get_xticklabels(),rotation = 90)
b.legend(loc='upper left', borderaxespad=0)

fig.suptitle('MYD88:p.L265P locus (3:38141150T>C)')

#save to file
plt.savefig(out_file+'.png', dpi=1000)
plt.savefig(out_file+'.eps', format='eps')
