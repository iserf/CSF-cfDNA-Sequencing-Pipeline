#!/usr/bin/python

import sys
import pandas as pd
import numpy as np

##functions

def filter_special(special_df):
    alt_ADF_raw=str(special_df['ADF_raw']).split(",")[1].split("]")[0]
    alt_ADR_raw=str(special_df['ADR_raw']).split(",")[1].split("]")[0]
    alt_ADF_DEDUPED=str(special_df['ADF_DEDUPED']).split(",")[1].split("]")[0]
    alt_ADR_DEDUPED=str(special_df['ADR_DEDUPED']).split(",")[1].split("]")[0]
    if int(alt_ADF_raw) >= 30:
        return(special_df)
    elif int(alt_ADR_raw) >= 30:
        return(special_df)        
    elif int(alt_ADF_DEDUPED) >= 8:
        return(special_df)
    elif int(alt_ADR_DEDUPED) >= 8:
        return(special_df)
    else:
        return("None")

def get_coverage(hs_metrics):
    stats_raw=open(hs_metrics)
    for line in stats_raw:
        if line.startswith('NPHD'):
            coverage=line.split('\t')[9].strip('\n')
            return(coverage)

def calculate_VAF(special_df):
    alt=int(special_df['AD_DEDUPED'].split(",")[1].split("]")[0])
    ref=int(special_df['AD_DEDUPED'].split(",")[0].split("[")[1])
    if ref > 0:
        VAF=alt/(alt+ref)
        special_df['VAF_tumor']=VAF
        return(special_df)
    else:
        special_df['VAF_tumor']=0.0
        return(special_df)

#files
ID=sys.argv[1]
report=sys.argv[2]
stats=sys.argv[3]
outfile=sys.argv[4]
#report='/home/iser/cfDNA_docker/data/results/'+ID+'/variants/'+dedup+'/somaticseq/report/'+ID+'.pipeline_v2.report.xlsx'
#stats='/home/iser/cfDNA_docker/data/results/'+ID+'/stats/'+ID+'.aligned.deduped.hs_metrics.txt'

SNV=pd.read_excel(report, sheet_name="SSeq.Classified.sSNV.filter", engine='openpyxl')
INDEL=pd.read_excel(report, sheet_name="SSeq.Classified.sINDEL.filter", engine='openpyxl')
SPECIAL=pd.read_excel(report, sheet_name='SPECIAL_POSITIONS', engine='openpyxl')
SNV_clinvar=pd.read_excel(report, sheet_name="SSeq.sSNV.cosmic.clinvar", engine='openpyxl')
INDEL_clinvar=pd.read_excel(report, sheet_name="SSeq.sINDEL.cosmic.clinvar", engine='openpyxl')
final_dataframe=outfile

##Create file for oncoprint

#snv calls
SNV['Index_gene'] = SNV['Hugo_Symbol'].map(str) + '_' + SNV['Protein_Change'].map(str)
SNV['Method'] = "SomaticSeq"
snv_out=SNV[['Index_gene','Hugo_Symbol','Protein_Change','Variant_Classification','VAF_tumor','DP4_tumor','Method']]
snv_out.set_index('Index_gene', inplace=True)
#snv_out.rename(columns={'Variant_Type': ID}, inplace=True)

#indel calls
INDEL['Index_gene'] = INDEL['Hugo_Symbol'].map(str) + '_' + INDEL['Protein_Change'].map(str)
INDEL['Method'] = "SomaticSeq"
indel_out=INDEL[['Index_gene','Hugo_Symbol','Protein_Change','Variant_Classification','VAF_tumor','DP4_tumor','Method']]
indel_out.set_index('Index_gene', inplace=True)
#indel_out.rename(columns={'Variant_Type': ID}, inplace=True)

#special pos calls
SPECIAL.fillna(value={"AD_DEDUPED": "[0, 0]","ADF_raw": "[0, 0]","ADR_raw": "[0, 0]","ADF_DEDUPED": "[0, 0]","ADR_DEDUPED": "[0, 0]"}, inplace=True)
special_pos=SPECIAL.apply(filter_special,axis=1,result_type="broadcast")
special_pos.drop(special_pos.index[special_pos['Hugo_Symbol'] == "None"], inplace=True)
special_pos['Index_gene'] = special_pos['Hugo_Symbol'].map(str) + '_' + special_pos['Genome_Change'].map(str) + '_' + special_pos['Protein_Change'].map(str)
special_pos['Method'] = "SPECIAL_POS"
special_out=special_pos[['Index_gene','Hugo_Symbol','Protein_Change','Variant_Classification','AD_raw','AD_DEDUPED','Method']]
special_out['VAF_tumor'] = 0.0
special_out=special_out.apply(calculate_VAF,axis=1)
special_out.drop(special_out.index[special_out['VAF_tumor'] < 0.03], inplace=True)
special_out.set_index('Index_gene', inplace=True)
special_out.rename(columns={'Variant_Type': ID}, inplace=True)

#snv_clinvar calls
SNV_clinvar['Index_gene'] = SNV_clinvar['Hugo_Symbol'].map(str) + '_' + SNV_clinvar['Protein_Change'].map(str)
SNV_clinvar['Method'] = "ClinVar_COSMIC"
snv_clinvar_out=SNV_clinvar[['Index_gene','Hugo_Symbol','Protein_Change','Variant_Classification','VAF_tumor','DP4_tumor','Method']]
snv_clinvar_out.set_index('Index_gene', inplace=True)
#snv_clinvar_out.rename(columns={'Variant_Type': ID}, inplace=True)

#indel calls
INDEL_clinvar['Index_gene'] = INDEL_clinvar['Hugo_Symbol'].map(str) + '_' + INDEL_clinvar['Protein_Change'].map(str)
INDEL_clinvar['Method'] = "ClinVar_COSMIC"
#INDEL_clinvar.drop(INDEL_clinvar.index[INDEL_clinvar['ClinVar_VCF_CLNSIG'] == 'Uncertain_significance'], inplace=True)
indel_clinvar_out=INDEL_clinvar[['Index_gene','Hugo_Symbol','Protein_Change','Variant_Classification','VAF_tumor','DP4_tumor','Method']]
indel_clinvar_out.set_index('Index_gene', inplace=True)
#indel_clinvar_out.rename(columns={'Variant_Type': ID}, inplace=True)

out=pd.concat([snv_out, indel_out, special_out, snv_clinvar_out, indel_clinvar_out])
out["ID_NPH"]=ID


#coverage table
coverage=get_coverage(stats)
coverage_data = {'Sample': [ID], 'Coverage': [coverage]}
coverage_table = pd.DataFrame(data=coverage_data)
coverage_table.set_index('Sample', inplace=True)


#Create excel file
with pd.ExcelWriter(final_dataframe) as writer:
    out.to_excel(writer, sheet_name='oncoprint')
    coverage_table.to_excel(writer, sheet_name='coverage')