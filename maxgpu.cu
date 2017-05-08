#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <cuda.h>
#define BLOCKS 1024
#define THREADS 256

__global__  
void getmaxcu(long * num_d, long * result_d)
{

cudaError_t cudaGetDeviceProperties ( struct cudaDeviceProp *   prop,
int   device   
);

printf(prop.maxThreadsPerBlock + "\n");


  __shared__ long maxResult[THREADS * 2];
  int tx = threadIdx.x;

  for (int stride = THREADS*2; stride > 0; stride = stride /2 ) {
    __syncthreads();

    if (num_d[tx*2] > num_d[(tx*2)+1]) {
      num_d[tx*2] = maxResult[tx];
    }
    else {
      num_d[(tx*2)+1] = maxResult[tx];
    }
  }
  result_d[blockIdx.x] = maxResult[0];
}

int main(int argc, char *argv[])
{
   long size = 0;  // The size of the array
   long i;  // loop index
   long * numbers; // host copy of numbers array
   long * result; // host copy of result
    
    if(argc !=2)
    {
       printf("usage: maxseq num\n");
       printf("num = size of the array\n");
       exit(1);
    }
   
    size = atol(argv[1]);

    numbers = (long *)malloc(size * sizeof(long));
    if( !numbers )
    {
       printf("Unable to allocate mem for an array of size %ld\n", size);
       exit(1);
    }    


        result = (long *)malloc(size * sizeof(long));


    srand(time(NULL)); // setting a seed for the random number generator
    // Fill-up the array with random numbers from 0 to size-1 
    for( i = 0; i < size; i++)
       numbers[i] = rand() % size;    
  
    long * num_d; 

    cudaMalloc((void **) &num_d, size);
    cudaMemcpy(num_d, numbers, size, cudaMemcpyHostToDevice);

    long * result_d; 

    cudaMalloc((void **) &result_d, size);


    clock_t start, end;
    double cpu_time_used;
    start = clock();  
   
    getmaxcu<<<BLOCKS,THREADS>>>(num_d, result_d);
    end = clock();
    cpu_time_used = ((double) (end-start))/CLOCKS_PER_SEC;

    printf(" time taken %d\n", 
           cpu_time_used);


    cudaMemcpy(result, result_d, size, cudaMemcpyDeviceToHost);
    printf(" The maximum number in the array is: %u\n", 
           result);

    cudaFree(result_d);
    cudaFree(num_d);

    free(numbers);
    free(result);
    exit(0);
}





