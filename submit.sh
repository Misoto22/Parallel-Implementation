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
    echo "MPI, OpenMP, Schedule Type, Chunk Size, Barycenter, Elapsed time(s), Number of processes, Number of threads, Iterate times, Number of fishes" >"$test_file"
fi

# Function to run tests
run_test() {
    echo "=== Running: $1 ==="
    $2 # Compilation command

    case $1 in
        "Serial")
            srun "$3"
            ;;
        "MPI Only")
            for mpi_nodes in 2 3 4; do
                srun -n $mpi_nodes "$3"
            done
            ;;
        "OpenMP Only")
            for omp_threads in 1 2 4 8 16 32; do
                export OMP_NUM_THREADS=$omp_threads
                export OMP_SCHEDULE=static
                srun -c $omp_threads "$3"
            done
            ;;
        "OpenMP and MPI")
            for mpi_nodes in 2 3 4; do
                for omp_threads in 1 2 4 8 16 32; do
                    export OMP_NUM_THREADS=$omp_threads
                    export OMP_SCHEDULE=static
                    srun -n $mpi_nodes -c $omp_threads "$3"
                done
            done
            ;;
    esac

    echo "====================="
}

# Compile and run the combined OpenMP and MPI version
run_test "OpenMP and MPI" "mpicc -D USE_MPI -fopenmp -o compile/FSB2_OpenMP_MPI FSB2.c $compiler_flags" "./compile/FSB2_OpenMP_MPI"

# Compile and run the serial version (No MPI, No OpenMP)
run_test "Serial" "gcc -o compile/FSB2_Serial FSB2.c $compiler_flags" "./compile/FSB2_Serial"

# Compile and run the MPI version (With MPI, No OpenMP)
run_test "MPI Only" "mpicc -D USE_MPI -o compile/FSB2_MPI FSB2.c $compiler_flags" "./compile/FSB2_MPI"

diff ./fish1.txt ./fish2.txt 2>>diff.txt
if [ "$(cat diff.txt)" = $'\n' ]; then
    echo "The two fish are identical."
else
    echo "The two fish are not identical."
fi


# Compile and run the OpenMP version (No MPI, With OpenMP)
run_test "OpenMP Only" "gcc -fopenmp -o compile/FSB2_OpenMP FSB2.c $compiler_flags" "./compile/FSB2_OpenMP"
