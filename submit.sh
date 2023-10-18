#!/bin/sh
#SBATCH --account=courses0101
#SBATCH --partition=debug
#SBATCH --ntasks=4
#SBATCH --ntasks-per-node=1
#SBATCH --time=00:10:00
#SBATCH --exclusive
#SBATCH --mem-per-cpu=32G

#SBATCH --output=Testing\ Results/slurm_output/slurm-%j.out

# Define Variables
test_file="Testing Results/results.csv"
compiler_flags="-lm"

# Create results file if it doesn't exist
if [ ! -f "$test_file" ]; then
    echo "MPI, OpenMP, Schedule Type, Chunk Size, Barycenter, Elapsed time(s), Number of processes, Number of threads, Iterate times, Number of fishes" >"$test_file"
fi

# Function to run tests
run_test() {
    echo "=== Running: $1 ==="
    $2                  # Compilation command
    srun -n 4 -c 4 "$3" # Run command
    echo "====================="
}

# Test 1: No OpenMP, No MPI
run_test "No OpenMP, No MPI" "gcc -o compile/FSB2_sequential FSB2.c $compiler_flags" "./compile/FSB2_sequential"

# Test 2: OpenMP, No MPI
export OMP_NUM_THREADS=16
export OMP_SCHEDULE=static
run_test "OpenMP, No MPI" "gcc -fopenmp -o compile/FSB2_OpenMP FSB2.c $compiler_flags" "./compile/FSB2_OpenMP"

# Test 3: No OpenMP, MPI
run_test "No OpenMP, MPI" "mpicc -D USE_MPI -o compile/FSB2_MPI FSB2.c $compiler_flags" "./compile/FSB2_MPI"

# Test 4: OpenMP and MPI
run_test "OpenMP and MPI" "mpicc -D USE_MPI -fopenmp -o compile/FSB2_OpenMP_MPI FSB2.c $compiler_flags" "./compile/FSB2_OpenMP_MPI"
