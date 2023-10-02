# How to use Setonix for MPI and OpenMP jobs

**CITS3402 and 5507 High Performance Computing**

**Creating a batch file for programs that use both MPI and OpenMP:**
You have to create a batch file (you can give any name). The name of my batch file is `myscript.sh`. This file looks like the following:

```bash
#!/bin/sh 
#SBATCH --account=courses0101
#SBATCH --partition=debug
#SBATCH --ntasks=2
#SBATCH --ntasks-per-node=1
#SBATCH --time=00:01:00
#SBATCH --exclusive
#SBATCH --mem-per-cpu=32G
#module load  openmpi/4.0.5

export OMP_NUM_THREADS=2
mpicc -fopenmp -o second second.c
srun ./second 
```

**Note:** This is the simplest way I could make Setonix work with both MPI and OpenMP. I have asked support for clarifications, but specifying threads using an environment setting seems to work. Also, Setonix by default uses MPIch which has other problems. Most probably there are more recent versions of OpenMPI available. Also note the request for memory (32GB, 64GB seems to fail). You can experiment.

```bash
#SBATCH --exclusive
```

gives you exclusive access to a node. You may otherwise share a node with other jobs. Setonix will give you lower priority when you use the 'exclusive' flag. I suggest you use this flag only when you are timiting your code. You can see details of other scheduling strategies of Setonix [from this link](https://support.pawsey.org.au/documentation/pages/viewpage.action?pageId=116131471#ExampleSlurmBatchScriptsforSetonixonCPUComputeNodes-Multithreadedjobs(OpenMP,pthreads,etc...)).

Here is a sample file `second.c`

```c
#include <stdio.h>
#include <omp.h>
#include <mpi.h>

int main(int argc, char *argv[])
{
    int process_id, number_of_processes;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &process_id);
    MPI_Comm_size(MPI_COMM_WORLD, &number_of_processes);
#pragma omp parallel
    printf("Hello world, I am process %d among %d processes and thread_id %d among %d threads\n", process_id, number_of_processes, omp_get_thread_num(), omp_get_num_threads());
    MPI_Finalize();
}
```

And the output (from two processes and two threads in each process):

```bash
Hello world, I am process 0 among 2 processes and thread_id 0 among 2 threads
Hello world, I am process 0 among 2 processes and thread_id 1 among 2 threads
Hello world, I am process 1 among 2 processes and thread_id 0 among 2 threads
Hello world, I am process 1 among 2 processes and thread_id 1 among 2 threads
```

**Amitava Datta
September 2023**
