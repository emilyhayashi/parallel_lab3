#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <cuda.h>

#define BLOCKS 1024
#define THREADS 256

void getmaxcu(long *, long *);

/*
   input: pointer to an array of long int
          number of elements in the array
   output: the maximum number of the array
*/


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
   

    // (1) Transfer numbers array
    long * num_d; //device copy of numbers array

    cudaMalloc((void **) &num_d, size);
    cudaMemcpy(num_d, numbers, size, cudaMemcpyHostToDevice);

    long * result_d; //device copy of result

    // (2) Allocate device memory for result array
    cudaMalloc((void **) &result_d, size);



     //(3) kernel launch code
    getmaxcu<<<BLOCKS,THREADS>>>(num_d, result_d);


     //(4) copy get max array from the device memory 
    cudaMemcpy(result, result_d, size, cudaMemcpyDeviceToHost);
    //free device memory
    cudaFree(result_d);
    cudaFree(num_d);

    free(numbers);
    free(result);
    exit(0);
}

__global__  void
getmaxcu(long * num_d, long * result_d)
{

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



