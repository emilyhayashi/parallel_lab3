#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <cuda.h>
#include <ctime>
#include <iostream>

#define THREADS 1024

__global__  
void getmaxcu(unsigned int * numbers, unsigned int * result, unsigned int size)
{
  extern __shared__ unsigned int arr[];

  int tx = threadIdx.x;
  arr[tx] = numbers[tx];

  for (int stride = blockDim.x/2; stride > 0; stride = stride /2 ) {
    __syncthreads();
    if(tx<stride){
      if (arr[tx] < arr[tx+stride]) {
        arr[tx] = arr[tx]+stride;
      }
      __syncthreads();
    }
  }
  if(!tx){
    atomicMax(result, arr[0]);
  }
}
int main(int argc, char *argv[])
{
   unsigned int size = 0;  // The size of the array
   unsigned int i;  // loop index
   unsigned int * numbers; // host copy of numbers array
   unsigned int * result; // host copy of result
    
    if(argc !=2)
    {
       printf("usage: maxseq num\n");
       printf("num = size of the array\n");
       exit(1);
    }
   
    size = atol(argv[1]);
    unsigned int grid=ceil((float)size/THREADS);

    numbers = (unsigned int *)malloc(size * sizeof(unsigned int));
    if( !numbers )
    {
       printf("Unable to allocate mem for an array of size %ld\n", size);
       exit(1);
    }    


    result = (unsigned int *)malloc(size * sizeof(unsigned int));


    srand(time(NULL)); // setting a seed for the random number generator
    // Fill-up the array with random numbers from 0 to size-1 
    for( i = 0; i < size; i++)
       numbers[i] = rand() % size;    
  
    unsigned int * device_numbers; 

    cudaMalloc((void **) &device_numbers, sizeof(unsigned int)*size);
    cudaMemcpy(device_numbers, numbers, sizeof(unsigned int) * size, cudaMemcpyHostToDevice);

    unsigned int * device_result; 

    cudaMalloc((void **) &device_result, size);

  dim3 dimGrid(grid);
  dim3 dimBlock(THREADS);
 

    getmaxcu<<<dimGrid,dimBlock,THREADS*sizeof(unsigned int)>>>(device_numbers, device_result, size);

    cudaMemcpy(result, device_result, sizeof(unsigned int), cudaMemcpyDeviceToHost);
    cudaFree(device_result);
    cudaFree(device_numbers);
    free(numbers);
    free(result);
    exit(0);
}





