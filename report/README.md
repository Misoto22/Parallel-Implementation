# Parallel Implementation of Search based on Fish School Behaviour Report

## Introduction

This report presents the performance analysis of a parallelized search algorithm implemented using both MPI (Message Passing Interface) and OpenMP. The objective of this study was to evaluate the efficiency and scalability of the combined parallel approach in comparison to a serial version.

## Methodology

The search algorithm was tested under various configurations:

1. Serial version (no MPI, no OpenMP).
2. Only MPI with varying number of processes (2, 3, and 4).
3. Only OpenMP with varying number of threads (1, 2, 4, 8, 16, and 32).
4. Combined MPI and OpenMP with varying processes and threads.

All tests were conducted with: 

- 10,000,000 fish.
- 10 Steps.
- **OpenMP Schedule Type**: Static

### Limitation

During testing, we encountered a limitation when trying to scale the number of threads in combination with MPI nodes. Specifically:

- For configurations with 2 MPI nodes and 128 (or more) threads.
- For configurations with 3 MPI nodes and 64 (or more) threads.

In these scenarios, an error was generated:

```bash
srun: error: Unable to create step for job 492242. More processors requested than permitted.
```

## Results

### Execution Time Distribution

**Base Case (Serial Mode)**: 3.209110s

Of course! Here's the formula for speedup in raw LaTeX format:

$$
\text{Speedup} = \frac{\text{Time of Base Case}}{\text{Time of Parallel Case}}
$$

| Number of processes | Number of threads | Time Spent (in seconds) | Speedup |
| :------------------ | :---------------- | ----------------------: | ------: |
| 4                   | 32                |                0.031519 |  101.82 |
| 2                   | 64                |                0.032177 |   99.73 |
| 3                   | 32                |                0.049247 |   65.16 |
| 2                   | 32                |                0.062844 |   51.06 |
| 4                   | 16                |                0.064624 |   49.66 |
| 3                   | 16                |                0.082341 |   38.97 |
| 4                   | 8                 |                0.121484 |   26.42 |
| 2                   | 16                |                0.127998 |   25.07 |
| 3                   | 8                 |                0.175703 |   18.26 |
| 2                   | 8                 |                0.223086 |   14.39 |
| 4                   | 4                 |                0.223339 |   14.37 |
| 3                   | 4                 |                0.294891 |   10.88 |
| 2                   | 4                 |                0.422008 |    7.60 |
| 4                   | 2                 |                0.422945 |    7.59 |
| 3                   | 2                 |                0.562065 |    5.71 |
| 2                   | 2                 |                0.840413 |    3.82 |
| 4                   | 1                 |                0.841628 |    3.81 |
| 3                   | 1                 |                 1.11957 |    2.87 |
| 2                   | 1                 |                 1.67924 |    1.91 |

The execution times generally decreased with the increase in the number of MPI processes and OpenMP threads. The combination of 4 MPI processes with 32 threads yielded the lowest median execution time, making it the most efficient setup among those tested.

### Speedup Analysis

All parallel configurations offered a significant speedup over the serial version. The highest speedup, over 30 times the performance of the serial version, was achieved with the combination of 4 MPI processes and 32 threads.

However, there were diminishing returns in speedup as the number of threads increased, especially from 16 to 32 threads.
![Speedup Comparison](https://github.com/Misoto22/CITS5507-Project-2/blob/main/report/speedup_comparison.png?raw=true)

As observed:

1. The speedup increases with the number of MPI processes and threads, with the combination of 4 MPI processes and 32 threads achieving the maximum speedup.
2. There is diminishing returns in speedup as we increase the number of threads, especially moving from 16 to 32 threads.
3. Across all configurations, we see a significant speedup compared to the serial execution, highlighting the benefits of parallelization using both MPI and OpenMP.

<div style="page-break-after: always; break-after: page;"></div>

## Appendix

### Testing Script

```bash
#!/bin/sh
#SBATCH --account=courses0101
#SBATCH --partition=debug
#SBATCH --time=00:10:00
#SBATCH --exclusive
#SBATCH --mem-per-cpu=32G
#module load  openmpi/4.0.5

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
```
