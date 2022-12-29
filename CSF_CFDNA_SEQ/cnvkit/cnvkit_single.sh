#!/bin/bash

#Run cnvkit in batch mode for a CSF cfDNA sample WITHOUT matching normal
#Use raw bam file (not deduplicated) as input
#Create single chromose CNV plots with gene annotation

#Input arguments
ID_T=$1
BED=$2
home_dir=$3

#Directories
work_dir=$home_dir/data/results/${ID_T}
OUT_DIR=$work_dir/${ID_T}_cnvkit_single
mkdir -p $OUT_DIR

#Files
BAM_T=$work_dir/bam/${ID_T}.aligned.sort.bam

#Resources
REFERENCE=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.fasta
cnvkit=$home_dir/reference/cnvkit

##Script##
##Run cnvkit batch pipeline for aligned bam and matching normal
docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 60G etal/cnvkit \
cnvkit.py batch --processes 8 \
$BAM_T \
--normal \
--targets $cnvkit/${BED}_targets.bed \
--antitargets $cnvkit/${BED}_antitargets.bed \
--access $cnvkit/access-excludes.hg38.bed \
--annotate $cnvkit/refFlat_hg38.txt \
--fasta $REFERENCE \
--output-reference $OUT_DIR/${ID_T}_reference.cnn \
--output-dir $OUT_DIR \
--diagram --scatter \
--method hybrid
wait

docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 60G etal/cnvkit \
cnvkit.py scatter $OUT_DIR/${ID_T}.aligned.sort.cnr \
--y-max 3 \
--y-min -3 \
-s $OUT_DIR/${ID_T}.aligned.sort.cns \
--segment-color red \
-o $OUT_DIR/${ID_T}_cnv_plot2.pdf 

##Plot genes
OUTPUT=$OUT_DIR
plot_dir=$home_dir/CSF_CFDNA_SEQ/cnvkit
$plot_dir/cnvkit_plot_genes.sh $ID_T $OUTPUT ${ID_T}.aligned.sort chr1 MDM4 $home_dir
$plot_dir/cnvkit_plot_genes.sh $ID_T $OUTPUT ${ID_T}.aligned.sort chr2 MYCN $home_dir
$plot_dir/cnvkit_plot_genes.sh $ID_T $OUTPUT ${ID_T}.aligned.sort chr4 FGFR3,PDGFRA $home_dir
$plot_dir/cnvkit_plot_genes.sh $ID_T $OUTPUT ${ID_T}.aligned.sort chr5 TERT $home_dir
$plot_dir/cnvkit_plot_genes.sh $ID_T $OUTPUT ${ID_T}.aligned.sort chr6 MYB $home_dir
$plot_dir/cnvkit_plot_genes.sh $ID_T $OUTPUT ${ID_T}.aligned.sort chr7 EGFR,CDK6,MET,KIAA1549,BRAF $home_dir 
$plot_dir/cnvkit_plot_genes.sh $ID_T $OUTPUT ${ID_T}.aligned.sort chr8 FGFR1,MYBL1,MYC $home_dir
$plot_dir/cnvkit_plot_genes.sh $ID_T $OUTPUT ${ID_T}.aligned.sort chr9 CDKN2A,CDKN2B,PTCH1 $home_dir
$plot_dir/cnvkit_plot_genes.sh $ID_T $OUTPUT ${ID_T}.aligned.sort chr10 PTEN,MGMT $home_dir
$plot_dir/cnvkit_plot_genes.sh $ID_T $OUTPUT ${ID_T}.aligned.sort chr11 CCND1 $home_dir
$plot_dir/cnvkit_plot_genes.sh $ID_T $OUTPUT ${ID_T}.aligned.sort chr12 CCND2,CDK4,MDM2 $home_dir
$plot_dir/cnvkit_plot_genes.sh $ID_T $OUTPUT ${ID_T}.aligned.sort chr13 RB1 $home_dir
$plot_dir/cnvkit_plot_genes.sh $ID_T $OUTPUT ${ID_T}.aligned.sort chr17 TP53,NF1,PPM1D $home_dir
$plot_dir/cnvkit_plot_coordinates.sh $ID_T $OUTPUT ${ID_T}.aligned.sort chr19:53665746-53761746 $home_dir
$plot_dir/cnvkit_plot_genes.sh $ID_T $OUTPUT ${ID_T}.aligned.sort chr22 SMARCB1,NF2 $home_dir
