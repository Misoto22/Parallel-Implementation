#!/bin/sh
#SBATCH --account=courses0101
#SBATCH --partition=debug
#SBATCH --ntasks=2
#SBATCH --ntasks-per-node=1
#SBATCH --time=00:10:00
#SBATCH --exclusive
#SBATCH --mem-per-cpu=32G

echo "=== Running: No OpenMP, No MPI ==="
gcc -o compile/FSB2_sequential FSB2.c -lm
srun -n 1 ./compile/FSB2_sequential
echo "=================================="

echo "=== Running: OpenMP, No MPI ==="
export OMP_NUM_THREADS=2
gcc -fopenmp -o compile/FSB2_OpenMP FSB2.c -lm
srun -n 1 ./compile/FSB2_OpenMP
echo "=============================="

echo "=== Running: No OpenMP, MPI ==="
#module load openmpi/4.0.5  # Uncomment if needed
mpicc -D USE_MPI -o compile/FSB2_MPI FSB2.c -lm
srun -n 2 ./compile/FSB2_MPI
echo "============================="

echo "=== Running: OpenMP and MPI ==="
mpicc -D USE_MPI -fopenmp -o compile/FSB2_OpenMP_MPI FSB2.c -lm
srun -n 2 ./compile/FSB2_OpenMP_MPI
echo "==============================="
