all: align

align:
	@sbatch ./align.sh

status:
	@squeue -u $(USER)

clean:
	@rm -f ../run/* ../logs/*
