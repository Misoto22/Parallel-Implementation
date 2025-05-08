# Parallel Implementation of Search based on Fish School Behaviour
![fish-school-hpc](https://github.com/user-attachments/assets/e6a5b2a9-147f-4eef-8972-9cee061db8d3)


## Run Test

```bash
sbatch submit.sh
```

## SLURM Guide

### Check Job Status

```bash
squeue -u henrychen
```

### Cancel a Job

```bash
scancel <JOBID>
```

## Compile

In order to facilitate testing, conditional compilation is used to produce various versions of FSB programs.

1. Compile for no openmp no mpi:

    ```bash
    gcc -o FSB2_sequential FSB2.c -lm
    ```

2. Compile for openmp no mpi:

    ```bash
    gcc -fopenmp -o FSB2_OpenMP FSB2.c -lm
    ```

3. Compile for no openmp mpi:

    ```bash
    mpicc -D USE_MPI -o FSB2_MPI FSB2.c -lm
    ```

4. Compile for openmp mpi:

    ```bash
    mpicc -D USE_MPI -fopenmp -o FSB2_OpenMP_MPI FSB2.c -lm
    ```
