# FASTQ_LIST = /net/1000g/mktrost/testNewRef/NA12878_30x/fastq.list
# OUT_DIR = /net/1000g/mktrost/testNewRef/NA12878_30x/output_new_dbsnp142_SS
AS = NCBI38

# REF_DIR = /data/local/ref/gotcloud.ref/hg38/
REF = $(REF_DIR)/hs38DH.fa
DBSNP_VCF = $(REF_DIR)/dbsnp_142.b38.vcf.gz
HM3_VCF = $(REF_DIR)/hapmap_3.3.b38.sites.vcf.gz
OMNI_VCF = $(REF_DIR)/1000G_omni2.5.b38.sites.PASS.vcf.gz
INDEL_PREFIX = $(REF_DIR)/1kg.pilot_release.merged.indels.sites.hg38

# BWA_THREADS = -t 15
#MAP_TYPE = BWA_MEM

CHRS = chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX

#CHRS = chr20


#EXT_DIR = /net/wonderland/home/mktrost/seqshop_old/2014Dec/singleSample/hg38
#EXT = $(EXT_DIR)/ALL.CHR.phase3.combined.sites.unfiltered.vcf.gz $(EXT_DIR)/CHR.filtered.sites.vcf.gz

#UNIT_CHUNK = 20000000      # Chunk size of SNP calling : 20Mb

#VCF_EXTRACT = $(EXT_DIR)/snpOnly.vcf.gz
#MODEL_GLFSINGLE = TRUE
#MODEL_SKIP_DISCOVER = FALSE
#MODEL_AF_PRIOR = TRUE

ONE_BWA = 1
# Set number of bwa threads per bwa run.
BWA_THREADS = -t 6

# Skip verifyBamID & run 2 step dedup/recab
PER_MERGE_STEPS = qplot index recab

# Run 2 step dedup/recab
recab_RUN_DEDUP = dedup_LowMem $(dedup_PARAMS) $(dedup_USER_PARAMS) --

# Bin
recab_BINNING = --binMid --binQualS 2,3,10,20,25,30,35,40,50

# Have recalibration write CRAM:
recab_EXT = recal.cram
recab_OUT = -.ubam
index_EXT = $(recab_EXT).crai
qplot_IN = -.ubam
GEN_CRAM = | $(SAMTOOLS_EXE) view -C -T $(REF) - > $(basename $@)
VIEW_CRAM = $(SAMTOOLS_EXE) view -uh -T $(REF) $(basename $<) |
CRAM_VIEW = REF_PATH=$(REF_DIR)/md5/%2s/%2s/%s $(SAMTOOLS_EXE) view -uh

KEEP_TMP = 1
KEEP_LOG = 1

FASTQ_LIST = $(OUT_DIR)/fastq.list

SAMTOOLS_SORT_EXE = /home/software/rhel6/med/samtools/1.2/bin/samtools
BWA_RM_FASTQ = 1

recab_USER_PARAMS = --maxBaseQual 44

[cleanUpBam2fastq]
BAM_LIST = $(OUT_DIR)/bam.list

[cleanUpBam]
CMD = $(CRAM_VIEW) ?(BAM) |  $(BAM_EXE) squeeze --in -.ubam --keepDups --rmTags AS:i,BD:Z,BI:Z,XS:i,MC:Z,MD:Z,NM:i,MQ:i --out - | $(SAMTOOLS_EXE) view -S -b -F 0x800 - | $(SAMTOOLS_SORT_EXE) sort -n -o - $(DIR)/?(BAM).temp | $(SAMTOOLS_EXE) fixmate - $(OUTPUT)) 2> $(OUTPUT)2fastq.log

[bam2fastqStep]
CMD = $(CRAM_VIEW) ?(BAM) | $(PIPE) $(BAM_EXE) bam2fastq --in -.ubam --outBase $(OUTPUT) --splitRG --gzip 2> $(OUTPUT)2fastq.log
