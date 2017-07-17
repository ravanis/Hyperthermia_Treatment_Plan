#ifndef MEIJSTER_H
#define MEIJSTER_H


// Threading
#include <omp.h>

#include <math.h>
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>

#ifdef MATLAB
#include <matrix.h>
#include <mex.h>
typedef mwSize index_t;
#else
#include <stdio.h>
typedef size_t index_t;
#endif
    
void meij_phase_1(int32_t *G, int32_t *g, uint8_t *B,
                  size_t length, size_t stride, int32_t inf);
void meij_phase_2(int32_t *D, int32_t *g, int32_t *G,
                  size_t length, size_t stride, int32_t inf_sq);
int meister(int32_t *D, index_t *g, uint8_t *B, index_t sX, index_t sY, index_t sZ);

#endif
