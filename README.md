# CSF-cfDNA-Sequencing-Pipeline

SNV/InDel/CNV calling for CSF liquid biopsies.

This pipeline was created to perform SNV, InDel and CNV calling from targeted sequencing data of cell-free DNA (cfDNA) isolated from cerebrospinal fluid (CSF). Libraries need to be prepared using the SureSelect XT HS2 DNA Reagent Kit (Agilent). The original pipeline analyzes the target region of the neurooncology gene panel from the Institute of Neuropathology at Heidelberg Univeristy. Due to legal issues, no Panel bed-File & Picard interval_list ist provided within this repo.

*Detailed wet lab protocols can be found in my MD thesis: XXX*

# Getting started

## Download the repository
Download the github repository with all its sub-direcoties. The main directory is your home directory (home_dir).

**IMPORTANT: The absolute file path ([absolute filepath]/CSF-cfDNA-Sequencing-Pipeline) has to specified as the home_dir argument when running any script of this pipeline**

Scripts can be run from the sub-directory /CSF-cfDNA-Sequencing-Pipeline/CSF_CFDNA_SEQ. Results are produced in the /CSF-cfDNA-Sequencing-Pipeline/data/results section. Ressources and software needed by the respective scripts are stored within CSF-cfDNA-Sequencing-Pipeline/reference or github_repo/software. Due to the large size of several GB, the following ressources have to be manually installed within CSF-cfDNA-Sequencing-Pipeline/reference section:

1. hg38 reference fasta within github_repo/reference/hg38/v0/
2. gatk Funcotator data source within github_repo/reference/funcotator_dat_source_in_use

Both ressources can be obtained from the gatk ressource bundle or be provided upon request. By default, both directories above contain a missing_ressources.txt file where the neccessary ressources are mentioned.

In addition, a Panel bed-file and interval_list have to be provided within the reference/bed directory. To run cnvkit, Panel targets and antitargets have to be provided within reference/cnvkit directory. In both directories placeholder-files "ADD_PANEL_BED_HERE"* have been placed to indicate the correct location for the respective files.

## Prepare the environment
All applications within this pipeline are dockerized. Therefore, only little adjustments of the users environment have to be taken.

1. Install Docker on your machine
2. Install GNU parallel (e.g. sudo apt-get install parallel)
3. Create the docker images used in the pipeline by pulling them from Docker hub (Script: /CSF-cfDNA-Sequencing-Pipeline/CSF_CFDNA_SEQ/docker_images/pull_images.sh) or install them based on the provided Docker Files (Script: /CSF-cfDNA-Sequencing-Pipeline/CSF_CFDNA_SEQ/docker_images/prepare_environment.sh)

# SNV/InDel/CNV Calling Pipeline

## Pipeline Overview
Briefly, the following steps and tools are applied within this pipeline:

1. De-Multiplexing (bcl-convert)**
2. Read trimming (AGeNT Trimmer)
3. Alignment to hg38 reference genome (bwa_mem2)
4. Deduplication using duplex molecular barcodes (AGeNT CReAK, gatk bqsr)
5. Fingerprint comparison of CSF cfDNA sample and matching germline control (gatk CrosscheckFingerprints)***
6. SNV/ InDel Variant Calling (Mutect2, VarScan2, Strelka2, VarDict, Scalpel, LoFreq, MuSE*** from lethalfang/somaticseq)
7. SNV/ InDel Variant Calling (Octopus)
8. Classification of called variants with a pre-trained classifier optimized for targeted sequencing of CSF cfDNA samples with the neurooncology gene panel (SomaticSeq) 
9. Variant calling at specific positions (hotspot mutations) specified in /home_dir/reference/bed/special_positions.tsv (bcftools mpileup)
10. Calling of variants overlapping with the ClinVar or COSMIC database to avoid missing clinically meaningful variants. 
11. Annotation of the calls (gatk Funcotator)
12. Creation of a report (SNV/InDel calls + ClinVar/COSMIC overlaps + Special Positions) (Python)
13. Filtered report (SNV/InDel calls + ClinVar/COSMIC overlaps + Special Positions) in a Format to be used for Oncoprint plotting (Python)
14. CNV calling (cnvkit)
15. Sequencing QC (fastQC, multiQC)
16. Sequencing statistics (gatk FlagStatSpark, gatk CollectHsMetrics)

** Not run when running Analyze_Paired_Sample.sh or Analyze_Single_Sample.sh

*** Not included when running the pipeline in SINGLE mode (without matching germline control).

## Run the Scripts
In the directory /CSF-cfDNA-Sequencing-Pipeline/CSF_CFDNA_SEQ you will find Scripts which combine all applications for an end to end workflow starting with raw bcl or de-multiplexed fastq files:

1. Analyse_Paired_library.sh: For analyzing a NGS library starting with raw bcl files. Library contains CSF cfDNA samples and matching germline control samples.
2. Analyze_Single_library.sh: For analyzing a NGS library starting with raw bcl files. Library contains only CSF cfDNA samples.
3. Analyze_Mixed_library.sh: For analyzing a NGS library starting with raw bcl files. Library contains CSF cfDNA samples with and without matching germline control samples.
4. Analyze_Paired_Sample.sh: For analyzing a matched CSF cfDNA and germline control sample pair. Starting from demultiplexed fastq files.
4. Analyze_Single_Sample.sh: For analyzing a CSF cfDNA sample without matching germline control. Starting from demultiplexed fastq files.

The recquired data structure/ arguments are described within the header of each script.
