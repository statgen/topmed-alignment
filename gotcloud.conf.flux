ONE_BWA = 1
# Set number of bwa threads per bwa run.
BWA_THREADS = -t 4

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

KEEP_TMP = 0
KEEP_LOG = 1

FASTQ_LIST = $(OUT_DIR)/fastq.list

BWA_RM_FASTQ = 1

recab_USER_PARAMS = --maxBaseQual 44

[cleanUpBam2fastq]
BAM_LIST = $(OUT_DIR)/bam.list

[cleanUpBam]
CMD = $(CRAM_VIEW) ?(BAM) |  $(BAM_EXE) squeeze --in -.ubam --keepDups --rmTags AS:i,BD:Z,BI:Z,XS:i,MC:Z,MD:Z,NM:i,MQ:i --out - | $(SAMTOOLS_EXE) view -S -b -F 0x800 - | $(SAMTOOLS_SORT_EXE) sort -n -T $(DIR)/?(BAM).temp - | $(SAMTOOLS_EXE) fixmate -O BAM - $(OUTPUT) 2> $(OUTPUT)2fastq.log

[bam2fastqStep]
CMD = $(CRAM_VIEW) ?(BAM) | $(PIPE) $(BAM_EXE) bam2fastq --in -.ubam --outBase $(OUTPUT) --splitRG --gzip 2> $(OUTPUT)2fastq.log
