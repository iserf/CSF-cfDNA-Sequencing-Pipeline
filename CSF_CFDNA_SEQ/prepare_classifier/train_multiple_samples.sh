#!/bin/bash

#DONE: prepare 274042S & 274046S markduplicates  + 279692 xthsv1 paired

#prepare 274042S & 274046S markduplicates single
cd /home/iser/cfDNA_docker/pipeline_v2/prepare_classifier/train_classifiers_twist_single
./run_pipeline_prepare_training_data.sh 274042S 22-04-07_single_bam_surgeon
wait
cd /home/iser/cfDNA_docker/pipeline_v2/prepare_classifier/train_classifiers_twist_single
./run_pipeline_prepare_training_data.sh 274046S 22-04-07_single_bam_surgeon
wait

#test classifiers for 3 samples + 247041

#perform bamsurgeon for 274042 & 274046 with xthsv1 deduplication

#prepare tsv 274042v1 & 274046v1 xthsv1 single

#prepare 274042v1 & 274046v1 xthsv1  + 279692 xthsv1 paired

#deduplicate 279692 with xthsv2 duplex mode

#prepare 274042S & 274046S markduplicates  + 279692 xthsv2 paired

# cd /home/iser/cfDNA_docker/pipeline_v2/train_classifiers_twist_single
# ./run_pipeline_prepare_training_data.sh 279690 22-03-25_single_xthsv1
# wait

# #train all xthsv1 samples paired with xthsv1 deduped normal
# cd /home/iser/cfDNA_docker/pipeline_v2/train_classifiers_twist_paired
# ./run_pipeline.sh 22-03-25_paired_xthsv1 274040 274042 274044 274046 279690 279692
# wait

# #train all markduplicates samples with xthsv1 deduped normal
# samples=(274040 274042 274044 274046 279690)
# for i in "${samples[@]}"
# do
#     mv /home/iser/cfDNA_docker/data/results/${i}/bam_ready /home/iser/cfDNA_docker/data/results/${i}/bam_ready_xthsv1
#     mv /home/iser/cfDNA_docker/data/results/${i}/bam_ready_markduplicates /home/iser/cfDNA_docker/data/results/${i}/bam_ready
# done
# wait
# cd /home/iser/cfDNA_docker/pipeline_v2/train_classifiers_twist_paired
# ./run_pipeline.sh 22-03-25_paired_markduplicates 274040 274042 274044 274046 279690 279692
# wait

# #train all markduplicates samples single
# cd /home/iser/cfDNA_docker/pipeline_v2/train_classifiers_twist_single
# ./run_pipeline.sh 22-03-25_single_markduplicates 274040 274042 274044 274046 279690
# wait

#train all markduplicates samples with xthsv2 deduped normal
cd /home/iser/cfDNA_docker/pipeline_v2/prepare_bam/workflow_scripts
./run_preprocess_bam_xthsv2.sh 279692
wait
cd /home/iser/cfDNA_docker/pipeline_v2/train_classifiers_twist_paired
./run_pipeline.sh 22-03-27_paired_t_markduplicates_n_xthsv2 274040 274042 274044 274046 279690 279692
wait

