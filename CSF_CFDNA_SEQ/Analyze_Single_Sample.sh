#!/bin/bash

# Script to perform SNV/INDEL/CNV calling for a CSF cfDNA prepared with the SureSelect XT HS2 DNA Reagent Kit
# Library preparation and sequencing should be performed according to the manufacturers protocol with the modifications recommended in my thesis
# This script starts with raw fastq files
#Raw data have to be arranged as the following:
#1. raw_data_drive: complete file path to directory containing ID_T as sub-directories
#2. sub-directory fastq (containing the raw fastq files) within the ID_T directory
#-raw_data_drive
#       |--ID_T
#       |   --fastq: R1 & R2 fastq files

#Arguments
raw_data_drive=$1
ID_T=$2
home_dir=$3

#Ressources
BED=$home_dir/reference/bed/NPHD2022A_3383431_Covered_adaptedChrom_padded_2_hg38.bed
BED2=NPHD2022A_3383431_Covered_adaptedChrom_padded_2_hg38
INTERVALS=$home_dir/reference/bed/NPHD2022A_3383431_Covered_adaptedChrom_padded_2_hg38.interval_list
classifier=classifier_DUPLEX_single
results=$home_dir/data/results
work_dir=$home_dir/CSF_CFDNA_SEQ


######################
######Pipeline########
######################

#cp files into WSL
mkdir -p $results/$ID_T/fastq
cp -r $raw_data_drive/$ID_T/fastq/${ID_T}*.fastq.gz $results/$ID_T/fastq
wait
 
###Prepare run scripts###
OUT_DIR=$results/$ID_T
mkdir -p $OUT_DIR/run_scripts

#Deduplicate Tumor#
touch $OUT_DIR/run_scripts/${ID_T}.dedup.sh
echo '#!/bin/bash' > $OUT_DIR/run_scripts/${ID_T}.dedup.sh
echo $work_dir/prepare_bam/run_preprocess_bam.sh $ID_T $BED DUPLEX $home_dir >> $OUT_DIR/run_scripts/${ID_T}.dedup.sh

#qc Tumor#
touch $OUT_DIR/run_scripts/${ID_T}.qc.sh
echo '#!/bin/bash' > $OUT_DIR/run_scripts/${ID_T}.qc.sh
echo $work_dir/prepare_bam/run_sequencing_qc.sh $ID_T $INTERVALS $home_dir >> $OUT_DIR/run_scripts/${ID_T}.qc.sh

#Variant calling#
touch $OUT_DIR/run_scripts/${ID_T}.variant_calling.sh
echo '#!/bin/bash' > $OUT_DIR/run_scripts/${ID_T}.variant_calling.sh
echo $work_dir/Single_sample/run_pipeline.sh $ID_T $classifier $BED $home_dir >> $OUT_DIR/run_scripts/${ID_T}.variant_calling.sh

#CNV Kit#
touch $OUT_DIR/run_scripts/${ID_T}.cnvkit.sh
echo '#!/bin/bash' > $OUT_DIR/run_scripts/${ID_T}.cnvkit.sh
echo $work_dir/cnvkit/cnvkit_single.sh $ID_T $BED2 $home_dir >> $OUT_DIR/run_scripts/${ID_T}.cnvkit.sh

chmod +x $OUT_DIR/run_scripts/*.sh
wait

####Run Pipeline####

date
#Preprocess tumor bam
$OUT_DIR/run_scripts/${ID_T}.dedup.sh
wait

date
#variant calling
$OUT_DIR/run_scripts/${ID_T}.variant_calling.sh
wait

date
#QC & CNVkit
parallel ::: $OUT_DIR/run_scripts/${ID_T}.qc.sh $OUT_DIR/run_scripts/${ID_T}.cnvkit.sh
wait

PROPERTIES_FILE=$OUT_DIR/${ID_T}.PIPELINE_SETTINGS.txt
echo "Tumor ID: ${ID_T}" | tee -a $PROPERTIES_FILE
echo "No Matching Blood available: Pipeline run in SINGLE mode" | tee -a $PROPERTIES_FILE
echo "Panel Version: ${BED}" | tee -a $PROPERTIES_FILE
echo "SomaticSeq classifier used: ${classifier}" | tee -a $PROPERTIES_FILE
echo "Tumor deduplication mode: DUPLEX" | tee -a $PROPERTIES_FILE

#cp files back
mkdir -p  $raw_data_drive/$ID_T/results
mv $results/$ID_T $raw_data_drive/$ID_T/results