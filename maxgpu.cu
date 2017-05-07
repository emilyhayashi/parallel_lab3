#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <cuda.h>

unsigned int getmax(unsigned int *, unsigned int);

int main(int argc, char *argv[])
{
    unsigned int size = 0;  // The size of the array
    unsigned int i;  // loop index
    unsigned int * numbers; //pointer to the array
    
    if(argc !=2)
    {
       printf("usage: maxseq num\n");
       printf("num = size of the array\n");
       exit(1);
    }
   
    size = atol(argv[1]);

    numbers = (unsigned int *)malloc(size * sizeof(unsigned int));
    if( !numbers )
    {
       printf("Unable to allocate mem for an array of size %u\n", size);
       exit(1);
    }    

    srand(time(NULL)); // setting a seed for the random number generator
    // Fill-up the array with random numbers from 0 to size-1 
    for( i = 0; i < size; i++)
       numbers[i] = rand()  % size;    
   
    printf(" The maximum number in the array is: %u\n", 
           getmax(numbers, size));

    free(numbers);
    exit(0);
}


/*
   input: pointer to an array of long int
          number of elements in the array
   output: the maximum number of the array
*/

__global__
getmaxcu(long * num_arr)
{
    __shared__ long maxResult[THREADS * 2];
    int tx = threadIdx.x;

    for (int stride= THREADS * 2; stride > 0; stride = stride/2){
        __syncthreads();

        if (num_arr[tx*2] > num_d[(tx*2)+ 1]){
            num_arr[(tx*2)+1] = maxResult[tx];
        }
        else{
            num_arr[(tx*2) +1] = maxResult[tx];
        }
    }
    result[blockIdx.x] = maxResult[0];
}
