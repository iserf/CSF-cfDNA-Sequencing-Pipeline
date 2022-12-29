#!/bin/bash

#Input arguments
training=$1
seed=$2
ID=$3
SNVs=$4
Indels=$5

#Directories
home_dir=/home/iser/cfDNA_docker
work_dir=$home_dir/reference/somaticseq_training/$training
OUT_DIR=$work_dir/classifiers/$seed
mkdir -p $OUT_DIR

#Resources
REFERENCE=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.fasta
DICT=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.dict

###SCRIPT###

#intersect raw snv/indel with truth set --> new truth set
docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G broadinstitute/gatk \
gatk SortVcf \
-I $OUT_DIR/test/$ID/Ensemble.sSNV.${seed}.test.predicted.vcf \
--SEQUENCE_DICTIONARY $DICT \
-O $OUT_DIR/test/$ID/Ensemble.sSNV.${seed}.test.predicted.sort.vcf
docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G broadinstitute/gatk \
gatk SortVcf \
-I $OUT_DIR/test/$ID/Ensemble.sINDEL.${seed}.test.predicted.vcf \
--SEQUENCE_DICTIONARY $DICT \
-O $OUT_DIR/test/$ID/Ensemble.sINDEL.${seed}.test.predicted.sort.vcf

raw_snv=$OUT_DIR/test/$ID/Ensemble.sSNV.${seed}.test.predicted.sort.vcf
raw_indel=$OUT_DIR/test/$ID/Ensemble.sINDEL.${seed}.test.predicted.sort.vcf

bgzip -c $raw_snv > ${raw_snv}.gz
tabix ${raw_snv}.gz
bgzip -c $raw_indel > ${raw_indel}.gz
tabix ${raw_indel}.gz

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
"bcftools isec \
-n~11 -c all \
-p $OUT_DIR/test/$ID/Truth_sets \
-O v \
$SNVs ${raw_snv}.gz"
mv $OUT_DIR/test/$ID/Truth_sets/0001.vcf $OUT_DIR/test/$ID/Truth_sets/SNV_truth_set.${ID}.${seed}.vcf
bgzip -c $OUT_DIR/test/$ID/Truth_sets/SNV_truth_set.${ID}.${seed}.vcf > $OUT_DIR/test/$ID/Truth_sets/SNV_truth_set.${ID}.${seed}.vcf.gz
tabix $OUT_DIR/test/$ID/Truth_sets/SNV_truth_set.${ID}.${seed}.vcf.gz

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
"bcftools isec \
-n~11 -c all \
-p $OUT_DIR/test/$ID/Truth_sets \
-O v \
$Indels ${raw_indel}.gz"
mv $OUT_DIR/test/$ID/Truth_sets/0001.vcf $OUT_DIR/test/$ID/Truth_sets/Indel_truth_set.${ID}.${seed}.vcf
#rm $OUT_DIR/test/$ID/Truth_sets/0001.vcf
bgzip -c $OUT_DIR/test/$ID/Truth_sets/Indel_truth_set.${ID}.${seed}.vcf > $OUT_DIR/test/$ID/Truth_sets/Indel_truth_set.${ID}.${seed}.vcf.gz
tabix $OUT_DIR/test/$ID/Truth_sets/Indel_truth_set.${ID}.${seed}.vcf.gz


#intersect classified variants with new truth set
grep -v "REJECT" $raw_snv > $OUT_DIR/test/$ID/Ensemble.sSNV.${seed}.test.predicted.pass.vcf
bgzip -c $OUT_DIR/test/$ID/Ensemble.sSNV.${seed}.test.predicted.pass.vcf > $OUT_DIR/test/$ID/Ensemble.sSNV.${seed}.test.predicted.pass.vcf.gz
tabix $OUT_DIR/test/$ID/Ensemble.sSNV.${seed}.test.predicted.pass.vcf.gz

grep -v "REJECT" $raw_indel > $OUT_DIR/test/$ID/Ensemble.sINDEL.${seed}.test.predicted.pass.vcf
bgzip -c $OUT_DIR/test/$ID/Ensemble.sINDEL.${seed}.test.predicted.pass.vcf > $OUT_DIR/test/$ID/Ensemble.sINDEL.${seed}.test.predicted.pass.vcf.gz
tabix $OUT_DIR/test/$ID/Ensemble.sINDEL.${seed}.test.predicted.pass.vcf.gz

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
"bcftools isec \
-n~11 -c all \
-p $OUT_DIR/test/$ID/overlap_truth/SNV \
-O v \
$OUT_DIR/test/$ID/Truth_sets/SNV_truth_set.${ID}.${seed}.vcf.gz \
$OUT_DIR/test/$ID/Ensemble.sSNV.${seed}.test.predicted.pass.vcf.gz"

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
"bcftools isec \
-n~11 -c all \
-p $OUT_DIR/test/$ID/overlap_truth/Indel \
-O v \
$OUT_DIR/test/$ID/Truth_sets/Indel_truth_set.${ID}.${seed}.vcf.gz \
$OUT_DIR/test/$ID/Ensemble.sINDEL.${seed}.test.predicted.pass.vcf.gz"

#intersect single callers output with truth set
# docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G broadinstitute/gatk \
# gatk SortVcf \
# -I $OUT_DIR/test/$ID/Truth_sets/Indel_truth_set.${ID}.${seed}.vcf \
# --SEQUENCE_DICTIONARY $DICT \
# -O $OUT_DIR/test/$ID/Truth_sets/Indel_truth_set.${ID}.${seed}.sort.vcf
# docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G broadinstitute/gatk \
# gatk SortVcf \
# -I $OUT_DIR/test/$ID/Truth_sets/SNV_truth_set.${ID}.${seed}.vcf \
# --SEQUENCE_DICTIONARY $DICT \
# -O $OUT_DIR/test/$ID/Truth_sets/SNV_truth_set.${ID}.${seed}.sort.vcf

# docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G broadinstitute/gatk \
# gatk MergeVcfs \
# -I $OUT_DIR/test/$ID/Truth_sets/Indel_truth_set.${ID}.${seed}.sort.vcf \
# -I $OUT_DIR/test/$ID/Truth_sets/SNV_truth_set.${ID}.${seed}.sort.vcf \
# -O $OUT_DIR/test/$ID/Truth_sets/All_sites_truth_set.${ID}.${seed}.vcf
# bgzip -c $OUT_DIR/test/$ID/Truth_sets/All_sites_truth_set.${ID}.${seed}.vcf > $OUT_DIR/test/$ID/Truth_sets/All_sites_truth_set.${ID}.${seed}.vcf.gz
# tabix $OUT_DIR/test/$ID/Truth_sets/All_sites_truth_set.${ID}.${seed}.vcf.gz

#All_sites=$OUT_DIR/test/$ID/Truth_sets/All_sites_truth_set.${ID}.${seed}.vcf.gz
All_sites=$home_dir/reference/bed/sides_twist/All_sides_truth_set.leftalignedtrimmed.NPHD2019A.vcf.gz
variant_dir=$home_dir/reference/somaticseq_training/$training/${ID}
single_callers_out=$home_dir/reference/somaticseq_training/$training/${ID}/overlap_single_callers
mkdir -p $single_callers_out

#Single caller vcfs
mutect2=$variant_dir/somaticseq_callers/MuTect2.vcf.gz
varscan=$variant_dir/somaticseq_callers/VarScan2.vcf
vardict=$variant_dir/somaticseq_callers/VarDict.vcf
scalpel=$variant_dir/somaticseq_callers/Scalpel.vcf.gz
octopus=$variant_dir/octopus/${ID}_octopus_calls.vcf
lofreq=$variant_dir/somaticseq_callers/LoFreq.vcf

strelka=$variant_dir/somaticseq_callers/Strelka/results/variants/variants.vcf.gz

zip=($varscan $vardict $octopus $lofreq)

for i in "${zip[@]}"
do
    bgzip -c ${i} > ${i}.gz
    tabix ${i}.gz
done


mutect22=MuTect2.vcf.gz
varscan2=VarScan2.vcf.gz
vardict2=VarDict.vcf.gz
scalpel2=Scalpel.vcf.gz
lofreq2=LoFreq.vcf.gz
octopus2=$variant_dir/octopus/${ID}_octopus_calls.vcf.gz

snv_single=($mutect22 $varscan_snv2 $vardict2 $lofreq_snv $muse2)
indel_single=($mutect22 $varscan_indel2 $vardict2 $scalpel2 $lofreq_indel)


callers=($mutect22 $varscan2 $vardict2 $scalpel2  $lofreq2 )

for i in "${callers[@]}"
do
    docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
    "bcftools isec \
    -n~11 -c all \
    -p $single_callers_out \
    -O v \
    $All_sites \
    $variant_dir/somaticseq_callers/${i}"
    mv $single_callers_out/sites.txt $single_callers_out/${i}.shared_truth.txt
done
wait

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
"bcftools isec \
-n~11 -c all \
-p $single_callers_out \
-O v \
$All_sites \
$strelka"
mv $single_callers_out/sites.txt $single_callers_out/Strelka.shared_truth.txt
wait

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
"bcftools isec \
-n~11 -c all \
-p $single_callers_out \
-O v \
$All_sites \
$octopus2"
mv $single_callers_out/sites.txt $single_callers_out/Octopus.shared_truth.txt
wait
