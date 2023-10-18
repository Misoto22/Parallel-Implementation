#!/bin/sh
#SBATCH --account=courses0101
#SBATCH --partition=debug
#SBATCH --ntasks=4
#SBATCH --ntasks-per-node=1
#SBATCH --time=00:10:00
#SBATCH --exclusive
#SBATCH --mem-per-cpu=32G

#SBATCH --output=Testing\ Results/slurm_output/slurm-%j.out


test_file="Testing Results/results.csv"

if [ ! -f "$test_file" ]; then
    echo "MPI, OpenMP, Schedule Type, Chunk Size, Barycenter, Elapsed time(s), Number of processes, Number of threads, Iterate times, Number of fishes" >"$test_file"
fi

echo "=== Running: No OpenMP, No MPI ==="
gcc -o compile/FSB2_sequential FSB2.c -lm
srun -n 4 -c 4 ./compile/FSB2_sequential
echo "=================================="

echo "=== Running: OpenMP, No MPI ==="
export OMP_NUM_THREADS=16
export OMP_SCHEDULE=static
gcc -fopenmp -o compile/FSB2_OpenMP FSB2.c -lm
srun -n 4 -c 4 ./compile/FSB2_OpenMP
echo "=============================="

echo "=== Running: No OpenMP, MPI ==="
#module load openmpi/4.0.5  # Uncomment if needed
mpicc -D USE_MPI -o compile/FSB2_MPI FSB2.c -lm
srun -n 4 -c 4 ./compile/FSB2_MPI
echo "============================="

echo "=== Running: OpenMP and MPI ==="
mpicc -D USE_MPI -fopenmp -o compile/FSB2_OpenMP_MPI FSB2.c -lm
srun -n 4 -c 4 ./compile/FSB2_OpenMP_MPI
echo "==============================="
