#!/bin/bash

#Input arguments
ID_T=$1
BAM_T=$2
training=$3
BED=$4

#Directories
home_dir=/home/iser/cfDNA_docker
work_dir=$home_dir/reference/somaticseq_training/$training/${ID_T}
OUT_DIR=$work_dir/somaticseq_callers
mkdir -p $OUT_DIR

#Files
BAM_DIR=$home_dir/data/results/${ID_T}/bam_ready

#Resources
REFERENCE=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.fasta
#BED=$home_dir/reference/bed/NPHD2019A_Covered_hg38.bed
DATA_SOURCE=$home_dir/reference/funcotator_dat_source_in_use
dbSNP=$home_dir/reference/funcotator_dat_source_in_use/dbsnp/hg38/hg38_All_20180418.vcf.gz

##Script##
docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G lethalfang/somaticseq:latest /bin/bash -c \
"makeSomaticScripts.py single \
--genome-reference $REFERENCE \
--inclusion-region $BED \
--bam $BAM_DIR/$BAM_T \
--sample-name $ID_T \
--output-directory $OUT_DIR \
--dbsnp-vcf $dbSNP \
--minimum-VAF 0.0025 \
--run-mutect2 --run-varscan2 --run-lofreq --run-vardict --run-scalpel --run-strelka2 --exome-setting \
--run-somaticseq \
--run-workflow --by-caller"
wait

chmod +x $OUT_DIR/logs/*
wait

parallel -j0 ::: $OUT_DIR/logs/*.cmd


#Zip & unzip files
mutect2=$work_dir/somaticseq_callers/MuTect2.vcf
varscan_snv=$work_dir/somaticseq_callers/VarScan2.snp.vcf
varscan_indel=$work_dir/somaticseq_callers/VarScan2.indel.vcf
vardict=$work_dir/somaticseq_callers/VarDict.vcf
scalpel=$work_dir/somaticseq_callers/Scalpel.vcf

strelka_snv=$work_dir/somaticseq_callers/Strelka/results/variants/somatic.snvs.vcf.gz
strelka_indel=$work_dir/somaticseq_callers/Strelka/results/variants/somatic.indels.vcf.gz
lofreq_snv=$work_dir/somaticseq_callers/LoFreq.somatic_final.snvs.vcf.gz
lofreq_indel=$work_dir/somaticseq_callers/LoFreq.somatic_final.indels.vcf.gz

unzip=($strelka_indel $strelka_snv $lofreq_indel $lofreq_snv)
zip=($mutect2 $varscan_snv $varscan_indel $vardict $scalpel $muse)

for i in "${unzip[@]}"
do
    gunzip -k ${i}
done

for i in "${zip[@]}"
do
    bgzip -c ${i} > ${i}.gz
    tabix ${i}.gz
done
