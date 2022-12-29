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
mv $OUT_DIR/test/$ID/Truth_sets/0000.vcf $OUT_DIR/test/$ID/Truth_sets/SNV_truth_set.${ID}.${seed}.vcf
bgzip -c $OUT_DIR/test/$ID/Truth_sets/SNV_truth_set.${ID}.${seed}.vcf > $OUT_DIR/test/$ID/Truth_sets/SNV_truth_set.${ID}.${seed}.vcf.gz
tabix $OUT_DIR/test/$ID/Truth_sets/SNV_truth_set.${ID}.${seed}.vcf.gz

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
"bcftools isec \
-n~11 -c all \
-p $OUT_DIR/test/$ID/Truth_sets \
-O v \
$Indels ${raw_indel}.gz"
mv $OUT_DIR/test/$ID/Truth_sets/0000.vcf $OUT_DIR/test/$ID/Truth_sets/Indel_truth_set.${ID}.${seed}.vcf
rm $OUT_DIR/test/$ID/Truth_sets/0001.vcf
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
variant_dir=$home_dir/reference/somaticseq_training/$training/${ID}
single_callers_out=$home_dir/reference/somaticseq_training/$training/${ID}/overlap_single_callers
mkdir -p $single_callers_out

#Single caller vcfs
mutect2=$variant_dir/somaticseq_callers/MuTect2.vcf
varscan_snv=$variant_dir/somaticseq_callers/VarScan2.snp.vcf
varscan_indel=$variant_dir/somaticseq_callers/VarScan2.indel.vcf
vardict=$variant_dir/somaticseq_callers/VarDict.vcf
scalpel=$variant_dir/somaticseq_callers/Scalpel.vcf
muse=$variant_dir/somaticseq_callers/MuSE.vcf
octopus_snv=$variant_dir/octopus/${ID}_octopus_calls.snv.vcf
octopus_indel=$variant_dir/octopus/${ID}_octopus_calls.indel.vcf

mutect22=MuTect2.vcf.gz
varscan_snv2=VarScan2.snp.vcf.gz
varscan_indel2=VarScan2.indel.vcf.gz
vardict2=VarDict.vcf.gz
scalpel2=Scalpel.vcf.gz
muse2=MuSE.vcf.gz
lofreq_snv=LoFreq.somatic_final.snvs.vcf.gz
lofreq_indel=LoFreq.somatic_final.indels.vcf.gz

strelka_snv=$variant_dir/somaticseq_callers/Strelka/results/variants/somatic.snvs.vcf.gz
strelka_indel=$variant_dir/somaticseq_callers/Strelka/results/variants/somatic.indels.vcf.gz
octopus_snv2=$variant_dir/octopus/${ID}_octopus_calls.snv.vcf.gz
octopus_indel2=$variant_dir/octopus/${ID}_octopus_calls.indel.vcf.gz

snv_single=($mutect22 $varscan_snv2 $vardict2 $lofreq_snv $muse2)
indel_single=($mutect22 $varscan_indel2 $vardict2 $scalpel2 $lofreq_indel)

for i in "${snv_single[@]}"
do
    docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
    "bcftools isec \
    -n~11 -c all \
    -p $single_callers_out/SNVs \
    -O v \
    $SNVs \
    $variant_dir/somaticseq_callers/${i}"
    mv $single_callers_out/SNVs/sites.txt $single_callers_out/SNVs/${i}.shared_truth.txt
done
wait

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
"bcftools isec \
-n~11 -c all \
-p $single_callers_out/SNVs \
-O v \
$SNVs \
$strelka_snv"
mv $single_callers_out/SNVs/sites.txt $single_callers_out/SNVs/Strelka.shared_truth.txt
wait

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
"bcftools isec \
-n~11 -c all \
-p $single_callers_out/SNVs \
-O v \
$SNVs \
$octopus_snv2"
mv $single_callers_out/SNVs/sites.txt $single_callers_out/SNVs/Octopus.shared_truth.txt
wait

for i in "${indel_single[@]}"
do
    docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
    "bcftools isec \
    -n~11 -c all \
    -p $single_callers_out/Indels \
    -O v \
    $Indels \
    $variant_dir/somaticseq_callers/${i}"
    mv $single_callers_out/Indels/sites.txt $single_callers_out/Indels/${i}.shared_truth.txt
done
wait

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
"bcftools isec \
-n~11 -c all \
-p $single_callers_out/Indels \
-O v \
$Indels \
$strelka_indel"
mv $single_callers_out/Indels/sites.txt $single_callers_out/Indels/Strelka.shared_truth.txt
wait

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
"bcftools isec \
-n~11 -c all \
-p $single_callers_out/Indels \
-O v \
$Indels \
$octopus_indel2"
mv $single_callers_out/Indels/sites.txt $single_callers_out/Indels/Octopus.shared_truth.txt