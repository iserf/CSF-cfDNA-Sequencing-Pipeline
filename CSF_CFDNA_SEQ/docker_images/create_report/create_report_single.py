#!/usr/bin/python

## Script for variant calling performed WITHOUT matching normal

## Script to create Excel report with seperate sheets for:
# 1. Classified SNVs
# 2. Classified Indels
# 3. Filtered SNVs
# 4. Filtered Indels
# 5. Special position calls in raw bam file
# 6. Special position calls in deduplicated bam file

import sys
import pandas as pd
import openpyxl

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
snv_maf=sys.argv[1]
indel_maf=sys.argv[2]
special_positions_raw=sys.argv[3]
special_positions_deduped=sys.argv[4]
out_file=sys.argv[5]

##read-in input-vcfs as data-frames
input_snv=skip_meta_info(snv_maf)
input_indel=skip_meta_info(indel_maf)
input_special_raw=skip_meta_info(special_positions_raw)
input_special_deduped=skip_meta_info(special_positions_deduped)


#Info header
info_list=['#version 2.4', \
'##', \
'## fileformat=VCFv4.2', \
'## dbSNP=<ID=dbSNP_CAF,Number=1,Type=String,Description="An ordered, comma delimited list of allele frequencies based on 1000Genomes, starting with the reference allele followed by alternate alleles as ordered in the ALT column.">', \
'## dbSNP=<ID=dbSNP_COMMON,Number=1,Type=String,Description="RS is a common SNP. A common SNP is one that has at least one 1000Genomes population with a minor allele of frequency >= 1% and for which COMMON 2 or more founders contribute to that minor allele frequency.">', \
'## dbSNP=<ID=dbSNP_G5A,Number=1,Type=String,Description=">5% minor allele frequency in each and all populations">', \
'## dbSNP=<ID=dbSNP_GENEINFO,Number=1,Type=String,Description="Pairs each of gene symbol:gene id. The gene symbol and id are delimited by a colon (:) and each pair is delimited by a vertical bar (|)">', \
'## dbSNP=<ID=dbSNP_KGPhase3,Number=1,Type=String,Description="1000 Genome phase 3">', \
'## dbSNP=<ID=dbSNP_PM,Number=1,Type=String,Description="Variant is Precious(Clinical,Pubmed Cited)">', \
'## dbSNP=<ID=dbSNP_PMC,Number=1,Type=String,Description="Links exist to PubMed Central article">', \
'## dbSNP=<ID=dbSNP_SAO,Number=1,Type=String,Description="Variant Allele Origin: 0 - unspecified, 1 - Germline, 2 - Somatic, 3 - Both">', \
'## dbSNP=<ID=dbSNP_ID,Number=1,Type=String,Description="dbSNP ID (i.e. rs number)">', \
'##INFO=<ID=SOMATIC,Number=0,Type=Flag,Description="Somatic mutation in primary">', \
'##INFO=<ID=MVDPK0,Number=6,Type=Integer,Description="Calling decision of the 6 algorithms: MuTect, VarScan2, VarDict, Scalpel, Strelka, Octopus">', \
'##INFO=<ID=NUM_TOOLS,Number=1,Type=Float,Description="Number of tools called it Somatic">', \
'##INFO=<ID=LC,Number=1,Type=Float,Description="Linguistic sequence complexity in Phred scale between 0 to 40. Higher value means higher complexity.">', \
'##INFO=<ID=DP4_tumor,Number=4,Type=Integer,Description="ref forward, ref reverse, alt forward, alt reverse">', \
'##INFO=<ID=VAF_tumor,Number=1,Type=Float,Description="Variant Allele Frequency">', \
'##']

info_df= pd.DataFrame(info_list, columns = ['VCF_INFO'])

#Shared MAF fields
shared_columns=["Chromosome","Start_Position","End_Position","Reference_Allele","Tumor_Seq_Allele2","Match_Norm_Seq_Allele2", \
"Hugo_Symbol","Variant_Classification","Variant_Type","dbSNP_Val_Status","Genome_Change","cDNA_Change","Codon_Change","Protein_Change","Refseq_mRNA_Id","Refseq_prot_Id","ref_context", \
"OREGANNO_Values","tumor_f","t_alt_count","t_ref_count","n_alt_count","n_ref_count"
,"dbSNP_ID","dbSNP_CAF","dbSNP_COMMON","dbSNP_G5A","dbSNP_GENEINFO","dbSNP_KGPhase3", \
"dbSNP_PM","dbSNP_PMC","dbSNP_SAO","SOMATIC","NUM_TOOLS","LC","DP4_tumor","VAF_tumor"]

#Create classified snv df
snv_columns=["MVDLK0"]
snv_shared=input_snv[shared_columns]
snv_unique=input_snv[snv_columns]
snv_out=pd.concat([snv_shared,snv_unique],axis=1, join="inner")

#Create classified indel df
indel_columns=["MVDLPK0"]
indel_shared=input_indel[shared_columns]
indel_unique=input_indel[indel_columns]
indel_out=pd.concat([indel_shared,indel_unique],axis=1, join="inner")

#Regex for filtering calls with alternative reads only supporting one strand (fw or rv)
regex = "(.*),(.*),(.*),[\s]0."
regex2 = "(.*),(.*),[\s]0,(.*)."

#Create snv_hard_filter df
snv_hard_filter = input_snv.drop(input_snv.index[input_snv['dbSNP_Val_Status'] == 'byFrequency;by1000genomes'])
snv_hard_filter.drop(snv_hard_filter.index[snv_hard_filter['dbSNP_COMMON'] == 1], inplace=True)
snv_hard_filter.drop(snv_hard_filter.index[snv_hard_filter['dbSNP_Val_Status'] == 'by1000genomes'], inplace=True)
snv_hard_filter.drop(snv_hard_filter.index[snv_hard_filter['DP4_tumor'].str.contains(regex) == True], inplace=True)
snv_hard_filter.drop(snv_hard_filter.index[snv_hard_filter['DP4_tumor'].str.contains(regex2) == True], inplace=True)
snv_hard_filter.drop(snv_hard_filter.index[snv_hard_filter['Variant_Classification'] == 'Intron'], inplace=True)
snv_hard_filter.drop(snv_hard_filter.index[snv_hard_filter['Variant_Classification'] == 'Silent'], inplace=True)
snv_columns=["MVDLK0"]
snv_shared_hard_filter=snv_hard_filter[shared_columns]
snv_unique_hard_filter=snv_hard_filter[snv_columns]
snv_hard_filter_out=pd.concat([snv_shared_hard_filter,snv_unique_hard_filter],axis=1, join="inner")

#Create indel_hard_filter df
indel_hard_filter =input_indel.drop(input_indel.index[input_indel['dbSNP_Val_Status'] == 'byFrequency;by1000genomes'])
indel_hard_filter.drop(indel_hard_filter.index[indel_hard_filter['dbSNP_COMMON'] == 1], inplace=True)
indel_hard_filter.drop(indel_hard_filter.index[indel_hard_filter['dbSNP_Val_Status'] == 'by1000genomes'], inplace=True)
indel_hard_filter.drop(indel_hard_filter.index[indel_hard_filter['DP4_tumor'].str.contains(regex) == True], inplace=True)
indel_hard_filter.drop(indel_hard_filter.index[indel_hard_filter['DP4_tumor'].str.contains(regex2) == True], inplace=True)
indel_hard_filter.drop(indel_hard_filter.index[indel_hard_filter['Variant_Classification'] == 'Intron'], inplace=True)
indel_hard_filter.drop(indel_hard_filter.index[indel_hard_filter['Variant_Classification'] == 'Silent'], inplace=True)
indel_columns=["MVDLPK0"]
indel_shared_hard_filter=indel_hard_filter[shared_columns]
indel_unique_hard_filter=indel_hard_filter[indel_columns]
indel_hard_filter_out=pd.concat([indel_shared_hard_filter,indel_unique_hard_filter],axis=1, join="inner")

#Write dataframes to excel
with pd.ExcelWriter(out_file) as writer:
    info_df.to_excel(writer, sheet_name='VCF_info_fields')
    snv_out.to_excel(writer, sheet_name='SSeq.Classified.sSNV')
    indel_out.to_excel(writer, sheet_name='SSeq.Classified.sINDEL')
    snv_hard_filter_out.to_excel(writer, sheet_name='SSeq.Classified.sSNV.filter')
    indel_hard_filter_out.to_excel(writer, sheet_name='SSeq.Classified.sINDEL.filter')
    input_special_raw.to_excel(writer, sheet_name='SPECIAL_POSITIONS_raw_bam')
    input_special_deduped.to_excel(writer, sheet_name='SPECIAL_POSITIONS_deduped_bam')