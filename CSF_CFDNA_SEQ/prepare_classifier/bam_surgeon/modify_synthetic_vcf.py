#!/usr/bin/python
## Script to add bring Varscan2 VCF into a format readable by Funcotator
import sys

#files
input_vcf=sys.argv[1]
output_vcf=sys.argv[2]

#Script#
vcf_raw=open(input_vcf)
output = open(output_vcf,'a')

for line in vcf_raw:
    if line.startswith('##'):
        output.write(line)

    if line.startswith('#CHROM'):
        output.write('#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tTRUTH_SET\n')

    if line.startswith('chr'):
        elements=line.split('\t')

        QUAL='.'
        FILTER='PASS'
        INFO='CATEGORY=SYNTHETIC;GENE=RANDOM;ID=BAMSURGEON;MUTATION=RANDOM;TYPE=RANDOM_SPIKE_IN'
        FORMAT='GT:AD:AF:DP:F1R2:F2R1:SB'
        TRUTH_SET='0/1:250,250:0.5:500:125,125:125,125:125,125,125,182'

        line_out=('\t'.join(elements[:5]))+'\t'+QUAL+'\t'+FILTER+'\t'+INFO+'\t'+FORMAT+'\t'+TRUTH_SET+'\n'    

        output.write(line_out)