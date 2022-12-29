Trimmer
===============
AGeNT Trimmer removes adaptor sequences from Illumina sequencing reads generated using SureSelect and Haloplex library preparation kits. For SureSelect XT HS and XT HS2, Trimmer also processes the Molecular Barcode (MBC) and adds the MBC information to the read name in the output fastq files. Downstream tools, such as AGeNT CReaK make use of these MBC tags in identifying PCR duplicates using molecular barcodes.

*Note: This jar was compiled using Java version 11. Please make sure your Java Runtime Environment is at least at version 11 by running the command* `java -version`.

**Command-line syntax:**
To test that you can run Trimmer, run the following command:

```
java -jar /path/to/trimmer-<version>.jar
```

or, if you have setup an environment variable (such as \$TRIMMER) as a shortcut:

```
java -jar $TRIMMER
```

You should see the Trimmer help text.


Example command-line:

```
java -jar trimmer-<version>.jar [mandatory options] [options] -fq1 <read1_filename> -fq2 <read2_filename>
```

**Required parameters:**

Parameter              | Description                        
---------              | -----------                         
`-fq1 <filename>`      | Read1 FASTQ file (Multiple files can be provided separated by a comma).
`-fq2 <filename>`      | Read2 FASTQ file (Multiple files can be provided separated by a comma).

***Note:***  *Even though -fq1 and -fq2 accept multiple files separated by a comma, the program will output results in a single file for each read.*

At least one of the following available library prep types is also mandatory to set the correct adaptor sequences for trimming.

Mandatory Option| Library Prep Type           
------| ----------------------------
`-halo` | HaloPlex
`-hs`   | HaloPlexHS
`-xt`   | SureSelect XT, XT2, XT HS
`-v2`   | SureSelect XT HS2
`-qxt`  | SureSelect QXT


**Optional Parameters:**

| Option | Description |
| -------|-------------|
| `-fq3 <filename>` | This option is only relevant for SureSelect XT HS. MBCs FASTQ file (Multiple files can be provided separated by a comma).| 
| `-bam` | Turn on to output unaligned bam file instead of fastq files |
| `-out` | Alternative output file name (file path + file name prefix) |
| `-polyG <n>` | The minimum length of polyG to trim from 3' end regardless of base quality (for nextSeq and NovaSeq polyG problem). Value range permitted is >= 1. |
| `-qualityTrimming <n>` |  Quality threshold for trimming. Value range permitted is 0 to 50. Default value is 5. |
| `-minFractionRead <n>`   | Sets the minimum read length as a fraction of the original read length after trimming.<br>Value range permitted is 0 to 99. Default value is 30. |
| `-idee_fixe` | Indicates that the fastq files are in the older Illumina fastq format (v1.5 or earlier). In addition to handling the older style read names, this option also assumes that the base qualities are encoded using the Illumina v1.5+ Phred+64 format and will attempt to convert bases to Phred+33. |
| `-qual_offset <n>`| Overwrite auto-detection to indicate FASTQ quality encoding (1 for Phred+33, 2 for Phred+64, 3 for Solexa+64)
| `-out_loc` | Directory path for output files.  |


**Usage Examples:**<br>

*  SureSelect XT HS2 example

```
java -jar trimmer-<version>.jar \
     -fq1 ./ICCG-repl1_S1_L001_R1_001.fastq.gz,./ICCG-repl1_S1_L001_R1_002.fastq.gz \
     -fq2 ./ICCG-repl1_S1_L001_R2_001.fastq.gz,./ICCG-repl1_S1_L001_R2_002.fastq.gz \ 
     -v2  \
     -out myOutputDirPath/myOutputFilePrefix
```

*  SureSelect XT HS example (with MBC tagging)

```
java -jar trimmer-<version>.jar \
     -fq1 ./ICCG-repl1_S1_L001_R1_001.fastq.gz,./ICCG-repl1_S1_L001_R1_002.fastq.gz \
     -fq2 ./ICCG-repl1_S1_L001_R2_001.fastq.gz,./ICCG-repl1_S1_L001_R2_002.fastq.gz \
     -fq3 ./ICCG-repl1_S1_L001_I2_001.fastq.gz,./ICCG-repl1_S1_L001_I2_002.fastq.gz \     
     -xt  \
     -out myOutputDirPath/myOutputFilePrefix
```

*  SureSelect XT HS example (without MBC tagging)

```
java -jar trimmer-<version>.jar \
     -fq1 ./ICCG-repl1_S1_L001_R1_001.fastq.gz,./ICCG-repl1_S1_L001_R1_002.fastq.gz \
     -fq2 ./ICCG-repl1_S1_L001_R2_001.fastq.gz,./ICCG-repl1_S1_L001_R2_002.fastq.gz \
     -xt  \
     -out myOutputDirPath/myOutputFilePrefix
```

*  Halo example

```
java -jar trimmer-<version>.jar \
     -fq1 ./ICCG-repl1_S1_L001_R1_001.fastq.gz,./ICCG-repl1_S1_L001_R1_002.fastq.gz \
     -fq2 ./ICCG-repl1_S1_L001_R2_001.fastq.gz,./ICCG-repl1_S1_L001_R2_002.fastq.gz \
     -halo  \
     -out_loc result/outputFastqs/
```

**Tags for SureSelect XT HS and SureSelect XT HS2:**

For the SureSelect XT HS and XT HS2 options, trimmed molecular barcodes (MBCs) are formatted as valid SAM tags and added to the read name line. These annotation tags are:

* BC:Z:*sample barcode*
* ZA:Z:*3 bases of MBC (first half of dual MBC) followed by 1 or 2 dark base(s)*
* ZB:Z:*3 bases of MBC (second half of dual MBC) followed by 1 or 2 dark base(s)*
* RX:Z:*first half of MBC + second half of MBC concatenated with a "-")*
* QX:Z:*base quality of sequence in RX:Z (concatenated with a space)* 

e.g.
`@D00266:1113:HTWK5BCX2:1:1102:9976:2206 BC:Z:CTACCGAA+AAGTGTCT ZA:Z:TTAGT ZB:Z:TCCT RX:Z:TTA-TCC QX:Z:DDD DDA`

***Note:*** *The MBC bases are masked as* **N** *and corresponding base qualities marked as* **$** *in some annotations if they are not recognized as a valid XT HS2 MBC.*

e.g.
`@K00336:80:HW7GLBBXX:7:1115:1184:3688 BC:Z:CTACCGAA+AGACACTT ZA:Z:NNNNN ZB:Z:AAAGT RX:Z:NNN-AAA QX:Z:$$$ <AA`

<br>

**Output for SureSelect XT HS2:**

In SureSelect XT HS2 mode (`-v2`), for every two FASTQ files (read 1 FASTQ file and read 2 FASTQ file) the program outputs three compressed files when not in BAM mode: 
* trimmed read 1 FASTQ file (.fastq.gz)
* trimmed read 2 FASTQ file (.fastq.gz)
* MBC sequence file (.txt.gz).
