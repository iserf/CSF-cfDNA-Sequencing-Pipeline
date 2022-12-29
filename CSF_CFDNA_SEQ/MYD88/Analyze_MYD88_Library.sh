#!/bin/bash

# Script to investigate allelic coverage at chr3:38141150T>C (MYD88:p.L265P)
# bcftools mpileup is performed for chr3:38141135 till chr3:38141165
# NGS library has to be prepared with the SureSelect XT HS2 DNA Reagent Kit
# Library preparation and sequencing should be performed according to the manufacturers protocol with the modifications recommended in my thesis
# This script starts with raw bcl files
# Raw data have to be arranged as the following:
#1. raw_data_drive: complete file path to sequencing data $Library folder
#2. Folder $Library containing the Run folder (output from Sequencer)
#3. run_name = Run folder name
#4. SampleSheet within the Run folder (template can be found here: /CSF_CFDNA_SEQ/reference/templates)
#5. Sample_list.txt within $Library Folder (template can be found here: /CSF_CFDNA_SEQ/reference/templates)


#Arguments
raw_data_drive=$1
Library=$2
run_name=$3
home_dir=$4

#Ressources
Sample_list=$raw_data_drive/$Library/Sample_list.txt
BED=$home_dir/CSF_CFDNA_SEQ/MYD88/ressources/MYD88_amplicon.bed
INTERVALS=$home_dir/CSF_CFDNA_SEQ/MYD88/ressources/MYD88_amplicon.interval_list
results=$home_dir/data/results
work_dir=$home_dir/CSF_CFDNA_SEQ


######################
#####BCL-CONVERT######
######################

echo "RUN BCL convert for Library $Library with SampleSheet"
echo "Processing date:"
date

$work_dir/prepare_bam/bcl_convert.sh $raw_data_drive $Library $run_name
wait

######################
######Pipeline########
######################


#####Read in file as array###########
while IFS=$'\t' read -r -a myArray
do
 ID_T="${myArray[0]}"

 echo $ID_T

 #cp files into WSL
 mkdir -p $results/$ID_T/fastq
 cp -r $raw_data_drive/$Library/fastq/${CSF}*.fastq.gz $results/$ID_T/fastq
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

 #More QC and Insert size metrics#
 touch $OUT_DIR/run_scripts/${ID_T}.myd88_qc2.sh
 echo '#!/bin/bash' > $OUT_DIR/run_scripts/${ID_T}.myd88_qc2.sh
 echo $work_dir/MYD88/MYD88_QC.sh $ID_T $home_dir $INTERVALS >> $OUT_DIR/run_scripts/${ID_T}.myd88_qc2.sh

 #special positions#
 touch $OUT_DIR/run_scripts/${ID_T}.myd88_l265p.sh
 echo '#!/bin/bash' > $OUT_DIR/run_scripts/${ID_T}.myd88_l265p.sh
 echo $work_dir/MYD88/special_positions.sh $ID_T $home_dir $BED >> $OUT_DIR/run_scripts/${ID_T}.myd88_l265p.sh

 chmod +x $OUT_DIR/run_scripts/*.sh
 wait

 #####RUN Pipeline#####

 date
 #Preprocess tumor bam
 $OUT_DIR/run_scripts/${ID_T}.dedup.sh
 wait

 date
 #call reads on myd88 amplicon & QC
 parallel ::: $OUT_DIR/run_scripts/${ID_T}.qc.sh $OUT_DIR/run_scripts/${ID_T}.myd88_qc2.sh $OUT_DIR/run_scripts/${ID_T}.myd88_l265p.sh
 wait

 #cp files back
 mkdir -p  $raw_data_drive/$Library/results
 mv $results/$ID_T $raw_data_drive/$Library/results
 wait

done < $Sample_list

