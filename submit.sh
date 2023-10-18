#!/bin/sh
#SBATCH --account=courses0101
#SBATCH --partition=debug
#SBATCH --time=00:10:00
#SBATCH --exclusive
#SBATCH --mem-per-cpu=32G

#SBATCH --output="Testing Results/slurm_output/slurm-%j.out"

# Define Variables
test_file="Testing Results/OMP_MPI_results.csv"
compiler_flags="-lm"

# Create results file if it doesn't exist
if [ ! -f "$test_file" ]; then
    echo "MPI Nodes, OpenMP Threads, Elapsed time(s), Number of fishes" > "$test_file"
fi

# Function to run tests
run_test() {
    echo "=== Running: $1 ==="
    $2  # Compilation command

    # Vary the number of MPI nodes
    for mpi_nodes in 2 3 4; do
        # Vary the number of OpenMP threads
        for omp_threads in 2 4 8 16; do
            export OMP_NUM_THREADS=$omp_threads
            srun -n $mpi_nodes -c $omp_threads "$3"  # Run command
        done
    done

    echo "====================="
}

# Compile and run the combined OpenMP and MPI version
run_test "OpenMP and MPI" "mpicc -D USE_MPI -fopenmp -o compile/FSB2_OpenMP_MPI FSB2.c $compiler_flags" "./compile/FSB2_OpenMP_MPI"
