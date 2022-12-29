
CReaK
=======
CReaK (**C**onsensus **Rea**d **K**it) identifies PCR duplicates in Illumina sequencing data from SureSelect XT HS or SureSelect XT HS2 Illumina sequencing data. It uses both alignment position and molecular barcode (MBC) information to group reads into MBC families. For each MBC family, CReaK constructs an error-corrected, deduplicated consensus read pair. CReaK requires that the reads in the input BAM file have already been annotated with their corresponding MBC sequences and MBC base qualities (using AGeNT Trimmer and BWA-MEM with “-C” parameter, for example).

***Note:*** *This jar was compiled using Java version 11. Please make sure your Java Runtime Environment is at least at version 11 by running the command* `java -version`

### Command-line syntax
To test that you can run CReaK, run the following command:

```
java -jar /path/to/creak-<version>.jar -h
```

or, if you have setup an environment variable (such as "$CREAK) as a shortcut:

```
java -jar $CREAK -h
```

You should see the CReaK help text which includes its usage and options.

To run CReaK:

```
java -Xmx8G -jar creak-<version>.jar -f -F [OPTIONS] input_bam_file_name
```

***Note:*** *-Xmx8G is just an example, please adjust memory based on sequencing depth and size of the input file.*

```
Usage: CReaK [-ehrvg] [-b=<bedFile>] -c=<cMode> [-d=<mbcMismatch>] -o=<outBam>
             [-s=<cacheSize>] (-f [-fi] [-mm=<minAvgMBCQual>]
             [-mr=<minAvgReadQual>] [-mq=<minMAPQ>]) (-F
             [-MS=<minMulti4Sinlge>] [-MD=<minMulti4Duplex>]) FILE
```

Minimal input required: 

* Input BAM file
* Output BAM file name/path
* Consensus calling mode (see *Consensus Modes* table below)
* Filtering options
	* `-f`: Enable input read flagging/filtering. This parameter must be present. 
	* `-F`: Enable consensus read filtering. This parameter must be present.

### Required parameters:
| Parameter | Description |
| ----- | -----|
| FILE | name of the input BAM or SAM file |
| `-o`, `--output-bam-file=<outBam>` | Output BAM file name/path. Avoid spaces when setting the path/file name. |
| `-c`, `--consensus-mode=<cMode>` | Consensus calling mode: SINGLE, HYBRID, DUPLEX. For more details see below for table of *Consensus Modes*. |

### Input read filter parameters:
Filtered input reads are always removed from the output file regardless of `-r` parameter.

| Parameter | Sub-option | Description | 
| --------- | ---------- | ----------- | 
| `-f`, `--input-read-filtering` | | Enable input read filtering. With no additional filtering options specified only unmapped (SAM flag 0x4), secondary (SAM flag 0x100), and supplementary (SAM flag 0x800) reads will be filtered. Other optional filters can be specified using `-fi`, `-mm`, `-mr` and `-mq`. |
|  | `-fi`, `--interval-filter` | Enable this filter to remove reads that are not covered by intervals in the optionally provided bed file. **In the case of input BAM with many chimeric alignments, this filter may cause loss of read pairs before consensus calling.**|
|  | `-mm <number>`, `--min-avg-MBC-qual=<minAvgMBCQual>` | Sets the minimum average MBC base quality. Filter reads with lower average MBC base quality. <br> Range is [0, 40], default is 0. |
|  | `-mr <number>`, `--min-avg-read-qual=<minAvgReadQual>` | Set the minimum average read base quality. Filter reads with lower average read base quality. <br> Range is [0, 40], default is 0.|
|  | `-mq <number>`, `--min-MAPQ=<minMAPQ>` | Sets the minimum read mapping quality (MAPQ). Filter reads with lower MAPQ. <br> Range is [0, 255], default is 0. |

### Consensus read filter parameters
Filtered consensus reads are flagged with SAM flag 0x200.

| Parameter | Sub-option | Description | 
| --------- | ---------- | ----------- | 
| `-F`, `--consensus-read-filtering` | | Enable consensus read filtering. Filtered reads will be flagged with SAM flag 0x200.  `-MS` and `-MD` are applied either using default values or with values specified by user with option `-MS` and `-MD`. |
| | `-MS <number>`, `--min-multiplicity-in-single=<minMulti4Single>` | Minimum number of read pairs associated with an MBC/single consensus read pair (amplification level). Single consensus read pairs generated from fewer read pairs than the specified threshold will be flagged with SAM flag 0x200. In duplex mode (-c DUPLEX), in which duplex consensus read pairs are formed from two single consensus read pairs, this threshold applies to whichever single consensus read pair has the smaller value.  <br> Range is >= 1, default is 1. |
| | `-MD <number>`, `--min-multiplicity-in-duplex=<minMulti4Duplex>` | Minimum number of read pairs associated with duplex MBC/duplex consensus read pairs (total number of read pairs associated with the two single consensus read pairs that form the duplex consensus read pair). Duplex consensus read pairs generated from fewer read pairs than the specified threshold will be flagged with SAM flag 0x200. <br> Range is >= 2, default is 2. | 

###  Additional Options:

| Option | Description |
| ------ | -------- | 
| `-v`, `--version` | Displays version info |
| `-h`, `--help` | Displays help message |
| `-e`, `--memory-efficient-mode` | Enables memory-efficient mode.  Uses less memory at the cost of computational time. |
| `-r`, `--remove-dup-mode` | Removes duplicates (SAM flag 0x400) and filtered consensus reads (SAM flag 0x200) from the output bam file. |
| `-g`, `--keep-singleton` | Keep singleton reads (that have unmapped mate) in the output bam. |
| `-d <number>`, `--MBC-mismatch=<mbcMismatch>` | Sets the maximum number of MBC sequence mismatches allowed for the corresponding reads to be considered part of the same MBC family. <br> Range is [0, 2], default is 0. |
| `-b <bed_file>`, `--bed-file=<bedFile>` | Sets optional file used to define the covered regions for metrics calculations. If not provided, all reads will be treated as not in a covered region. Required if option `-fi` filtering option is applied. |
| `-s <number>`,  `--cache-size=<cacheSize>` | Sets the pairing cache size. The default value should cover most cases but may be increased if the output .stat file reveals an unreasonably large gap between `# sam records passed input read filtering` and `# correctly-paired read pairs for MBC Consensus calling`. <br> Range is 1000-1000000, default is 100000. |


### Consensus Mode:
CReaK identifies consensus reads in three different modes: SINGLE, HYBRID, and DUPLEX. All three modes can be applied to SureSelect XT HS2 but only SINGLE can be applied to SureSelect XT HS (since XT HS data does not have a dual MBC). 

| Mode | Description  |
|------|----------|
| SINGLE | One read pair is generated from a group of read pairs that share the same mapped start and end coordinate as well as the same MBC sequence. If `-d` is not 0, a representative read pair is further chosen from read pairs of different MBC groups (`-d` allows merging of MBCs with mismatches). |
| DUPLEX | After single consensus calling, a duplex MBC/duplex consensus read pair is generated when two complementary single consensus MBCs/consensus read pairs are present (one from each strand). All single consensus read pairs that do not have its complementary partner are flagged as *not passing platform/vendor quality controls* (SAM flag 0x200).|
| HYBRID | Follows the same approach as DUPLEX mode, but the single consensus read pairs are not flagged as *not passing platform/vendor quality controls* (SAM flag 0x200). Also, for compatibility with downstream applications, duplex consensus read pairs are output twice (once for each input single read pairs) in order to match the stoichiometry of the single consensus read pairs. |

### Usage examples:
* SureSelect XT HS (and SureSelect XT HS2 in single consensus mode)

```
java -Xmx8G -jar creak-<version>.jar \
     -c SINGLE -d 0 -f -mm 25 -mr 30 -F -MS 1 \
     -b Covered.bed -o test_output.bam \
     test_input.bam
```

* SureSelect XT HS2 in duplex mode

```
java -Xmx8G -jar creak-<version>.jar \
     -c DUPLEX -d 0 -f -mm 25 -mr 30 -F -MS 1 -MD 2 \
     -b Covered.bed -o test_output.bam \
     test_input.bam
```
* SureSelect XT HS2 in hybrid mode

```
java -Xmx8G -jar creak-<version>.jar \
     -c HYBRID -d 0 -f -mm 25 -mr 30 -F -MS 1 -MD 2 \
     -b Covered.bed -o test_output.bam \
     test_input.bam
```
* SureSelect XT HS2 in hybrid mode (with less memory)

```
java -Xmx8G -jar creak-<version>.jar \
     -e -c HYBRID -d 0 \
     -f -mm 25 -mr 25 -F -MS 1 -MD 2 \
     -b Covered.bed -o test_output.bam \
     test_input.bam
``` 
***Note***: *memory efficient mode(-e) works for any mode,  "SureSelect XT HS2 in hybrid mode" is just an example.* 

* SureSelect XT HS2 in hybrid mode (with duplicates and filtered reads removed)

```
java -Xmx12G -jar creak-<version>.jar \
     -r -c HYBRID -d 0 \
     -f -mm 25 -mr 25 -F -MS 1 -MD 2 \
     -b Covered.bed -o test_output.bam \ 
     test_input.bam
``` 
***Note***:  *removal mode (-r) works for any mode,  "SureSelect XT HS2 in hybrid mode" is just an example.* 

### Relevant SAM Tags:
CReaK requires tag values in the SAM record of the input BAM file that contain the molecular barcode sequence and quality:

| Tag | Type |Description | Example |
|---|---|---------------|-----------|
| `RX` | String(Z) | Sequence bases of the unique molecular barcode | `RX:Z:CGT-CCG` |
| `QX` | String(Z) | Quality score of the unique molecular barcode in the RX tag | `QX:Z:DDD BDB`|

CReaK may insert some tags into the output SAM records to provide additional information about the deduplication process:

| Tag | Type |Description |
|---|---|---------------|
| `xc` | Integer(i) | Indicates whether this read is covered by intervals in the bed file. A read with mapped bases overlapping with the `-b` BED file has tag value set to 1, otherwise the value is set to 0. The read pair with two reads mapped to different reference names is always set to 0. <br> e.g. `xc:i:0` means this read does not intersect with the BED file. |
| `xm` | Integer(i) | Indicates the number of read pairs associated with an MBC/single consensus read pair. <br> e.g. `xm:i:5` means this MBC has 5 read pairs associated with it (including this single consensus read pair itself).|
| `xd` | Integer(i) | Indicates the number of read pairs associated with a duplex MBC/duplex consensus read pair (or the two single MBCs that form this duplex MBC). This tag is only present for duplex consensus reads. <br>  e.g. `xd:i:8` means this duplex MBC has 8 read pairs associated with it (including this duplex consensus read pair itself). If the same read has `xm:i:5`, that means that one of the single MBCs that forms the duplex MBC has 5 read pairs associated with it, and the other single MBC has 8 - 5 = 3 read pairs associated with it. |
| `zd` | String(Z) | Contains the read names of duplicates that are associated with this single/duplex consensus read. The number of read names is capped at 50/100 for single/duplex consensus read. Read names are comma-separated. <br> e.g. `zd:Z:D00266:1113:HTWK5BCX2:1:1115:2885:70626` means one read pair with the name being D00266...70626 is flagged as a duplicate of this consensus read pair. |
| `zp` | String(Z) | Contains original information from the single consensus read that shares the same name as the duplex consensus read before it was merged. This tag is only for duplex consensus reads. One duplex read is created by merging two single consensus reads.  The read name, sequence, quality, CIGAR and MD are preserved in this tag, separated by a vertical bar `|`.  <br> e.g.`zp:Z:D00266:1113:HTWK5BCX2:1:1211:8833:23978|GACGCTCTTCCGATCTCCGT|0/<GHG??DHFHGCHHIIHH|3S17M|17` contains original read name (same as the duplex read), sequence, quality, CIGAR, and MD of a single consensus read before it is merged into this duplex consensus read. |
| `zn` | String(Z) | Contains original information from the single consensus read that does not share the same name as the duplex consensus read before it was merged. This tag is only for duplex consensus reads. One duplex read is created by merging two single consensus reads.  The read name, sequence, quality, CIGAR and MD are preserved in this tag, separated by vertical bar `|`. <br> e.g.`zn:Z:D00266:1113:HTWK5BCX2:1:1214:18553:39660|GACGCTCTTCCGATCTCCGT|0/<GHG??DHFHGCHHIIHH|3S17M|17` contains original read name, sequence, quality, CIGAR, and MD of a single consensus read before it is merged into this duplex consensus read. |

### Statistics in .stats file:
CReaK generates a .stats file along with the output .bam file.  The .stats file contains duplicate and filtering statistics which are categorized into single number statistics and histograms. Please see below for detailed descriptions of all metrics. 
#### Single number statistics

| Item name | Description |
|------------------|-----------------|
| `# processed sam records:` | the total number of SAM records that CReaK processed |
| `# sam records passed input read filtering:` | the total number of SAM records that pass the filtering caused by the application of `-f`, `-fi`, `-mm`, `-mr` and `-mq`.  |
| `# correctly-paired read pairs for MBC Consensus calling:` | after input read filtering, the total number of SAM records that are properly paired with each other. |
| `# read pairs already marked as duplicate and not used for MBC Consensus calling:` | among the correctly paired SAM records, the total number of read pairs that are already flagged as duplicate in the input bam file and are thus ignored in consensus read calling. |
| `# read pairs that are chimeric (on diff ref names):` | among the correctly paired SAM records, the number of read pairs that have reads mapped to different chromosomes/reference names. This does not include chimeric alignments that are mapped very far away from each other on the same chromosome/reference name. |
| `# read pairs called as single consensus:` | the number of read pairs that are called as single consensus read pairs. In SINGLE consensus mode, reports the total number of all consensus read pairs. In DUPLEX or HYBRID consensus mode, reports the number of single consensus read pairs that cannot be merged into duplex consensus read pairs. |
| `# read pairs called as duplex consensus:` | the total number of read pairs that are called as duplex consensus read pairs. In SINGLE consensus mode, this number should be 0. | 
| `# read pairs called as chimeric (on diff ref names) consensus:` | the total number of consensus read pairs that are based on chimeric alignments, specifically those that are mapped to different chromosomes/reference names. This metric applies to both single consensus or duplex consensus modes, and is a subset of `# read pairs get called as single consensus` or `# read pairs get called as duplex consensus`.|
| `# read pairs marked as dups during consensus calling:` |  the total number of read pairs that are flagged as duplicate (SAM flag 0x400). |
| `# read pairs that failed consensus filter:` | the total number of read pairs that are flagged as not passing platform/vendor quality control(SAM flag 0x200) due to the application of the `-MS` and `-MD` parameters. |
| `# read pairs called as single consensus and failed to form duplex consensus:` | the total number of read pairs that are called as single consensus but are unable to form duplex consensus. In SINGLE consensus mode, this number should be 0. In DUPLEX or HYBRID consensus mode, this number should be equal to `# read pairs get called as single consensus`. |

#### Histograms
The histogram is represented by a series of  numbers on the *X axis* and  their counterparts on the *Y axis* .  These numbers are comma-separated.  

| Histogram | X axis | Y axis | Description |
|---------- |------- | ------ |-------------|
| `SINGLE CONSENSUS HISTOGRAM (uncovered)` | the number of read pairs associated with an MBC family, or the amplification level of a single MBC in the uncovered regions (defined by the user-provided bed file) | the number of MBCs at this amplification level | Shows the distribution of MBCs at different amplification levels in the uncovered regions. <br> e.g., x_axis=1,2 and y_axis=4,5 means that, in the uncovered regions, there are 4 MBCs having only 1 read pair associated with them, and 5 MBCs having 2 read pairs associated with them |
|`SINGLE CONSENSUS HISTOGRAM (covered)` | same as above but for the covered regions | same as above | same as above but for the covered regions |
|`DUPLEX_CONSENSUS HISTOGRAM 1 (uncovered)` | the minimum number of read pairs associated with the two MBCs that form the duplex MBC, or the minimum amplification level of this duplex MBC family in the uncovered regions (defined by the user-provided bed file) | the number of duplex MBCs at this amplification level | Shows the distribution of duplex MBCs at different minimum amplification levels in the uncovered regions. <br> e.g., x_axis=1,2 and y_axis=4,5 means that, in the uncovered regions, there are 4 duplex MBCs having at least 1 read pair associated with one of its two single MBCs, and 5 duplex MBCs having at least 2 read pairs associated with one of its two single MBCs. |
|`DUPLEX CONSENSUS HISTOGRAM 1 (covered)` | same as above but for the covered regions | same as above | same as above but for the covered regions|
|`DUPLEX_CONSENSUS HISTOGRAM 2 (uncovered):` | the total number of read pairs associated with the two MBCs that form the duplex MBC family, or the maximum amplification level of this duplex MBC in the uncovered regions (defined by the user-provided bed file) | the number of duplex MBCs at this amplification level | Shows the distribution of duplex MBCs at different maximum amplification levels in the uncovered regions. <br> e.g., x_axis=3,4 and y_axis=4,5 means that, in the uncovered regions, there are 4 duplex MBCs having at least 3 read pairs in total associated with its two single MBCs, and 5 duplex MBCs having 4 read pairs associated with its two single MBCs. |
|`DUPLEX CONSENSUS HISTOGRAM 2 (covered)` | same as above but for the covered regions | same as above | same as above but for the covered regions|
***Note:*** *The histograms are based on read pairs instead of reads, and in cases where a read pair has one read in a covered region and the other read in an uncovered region, the first read of this pair (by SAM flag 0x40) decides where it belongs.*

