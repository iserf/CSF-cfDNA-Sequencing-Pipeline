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
        output.write('##INFO=<ID=DP4_normal,Number=4,Type=Integer,Description="ref forward, ref reverse, alt forward, alt reverse">\n')
        output.write('##INFO=<ID=DP4_tumor,Number=4,Type=Integer,Description="ref forward, ref reverse, alt forward, alt reverse">\n')
        output.write('##INFO=<ID=VAF_normal,Number=1,Type=Float,Description="Variant Allele Frequency">\n')
        output.write('##INFO=<ID=VAF_tumor,Number=1,Type=Float,Description="Variant Allele Frequency">\n')
        output.write(line)

    if line.startswith('chr'):
        elements=line.split('\t')

        format_normal=elements[9]
        format_fields_normal=format_normal.split(':')

        format_tumor=elements[10]
        format_fields_tumor=format_tumor.split(':')

        info_out=elements[7]+';'+'DP4_normal='+format_fields_normal[1]+';'+'DP4_tumor='+format_fields_tumor[1]+';'+'VAF_normal='+format_fields_normal[-1]+';'+'VAF_tumor='+format_fields_tumor[-1]

        line_out=('\t'.join(elements[:7]))+'\t'+info_out.strip()+'\t'+('\t'.join(elements[8:]))
       
        output.write(line_out)