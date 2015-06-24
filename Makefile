all: clean align

clean:
	@rm logs/*.err logs/*.out

align:
	@sbatch ./align.sh
