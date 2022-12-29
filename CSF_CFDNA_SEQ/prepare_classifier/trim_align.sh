#!/bin/bash

#arguments
ID_N=279692
MBC_N=${ID_N}*MBC*.txt.gz

#Directories
home_dir=/home/iser/cfDNA_docker
OUT_DIR=/home/iser/cfDNA_docker/data/results
work_dir=$home_dir/pipeline_v2


# 1. Preprocess normal with locatit_xthsv1

#Deduplicate Normal#
mkdir -p $OUT_DIR/${ID_N}/run_scripts
touch $OUT_DIR/${ID_N}/run_scripts/${ID_N}.dedup.sh
echo '#!/bin/bash' > $OUT_DIR/${ID_N}/run_scripts/${ID_N}.dedup.sh
echo $work_dir/prepare_bam/workflow_scripts/run_preprocess_bam_xthsv1.sh $ID_N $MBC_N >> $OUT_DIR/${ID_N}/run_scripts/${ID_N}.dedup.sh

#qc Normal#
touch $OUT_DIR/${ID_N}/run_scripts/${ID_N}.qc.sh
echo '#!/bin/bash' > $OUT_DIR/${ID_N}/run_scripts/${ID_N}.qc.sh
echo $work_dir/prepare_bam/workflow_scripts/sequencing_qc.sh $ID_N >> $OUT_DIR/${ID_N}/run_scripts/${ID_N}.qc.sh

chmod +x $OUT_DIR/${ID_N}/run_scripts/*.sh
wait
$OUT_DIR/${ID_N}/run_scripts/${ID_N}.dedup.sh
wait
$OUT_DIR/${ID_N}/run_scripts/${ID_N}.qc.sh
wait

# 2. Generate Trim and align script
samples1=(274040 274042 274044 274046 279690)
for i in "${samples1[@]}"
do
    echo $i
    mkdir -p $OUT_DIR/${i}/run_scripts
    touch $OUT_DIR/${i}/run_scripts/${i}.trim_align.sh
    echo '#!/bin/bash' > $OUT_DIR/${i}/run_scripts/${i}.trim_align.sh
    echo $work_dir/prepare_bam/workflow_scripts/run_preprocess_bam_classifier.sh $i >> $OUT_DIR/${i}/run_scripts/${i}.trim_align.sh

    chmod +x $OUT_DIR/${i}/run_scripts/${i}.trim_align.sh
    $OUT_DIR/${i}/run_scripts/${i}.trim_align.sh
done
wait