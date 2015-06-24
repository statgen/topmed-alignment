all: align

align:
	@sbatch ./align.sh

status:
	@squeue -u $(USER)
