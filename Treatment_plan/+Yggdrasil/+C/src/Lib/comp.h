#ifndef COMP_H
#define COMP_H

#include <stdlib.h>
#include <stdio.h>
#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

#include <matrix.h>
#include <mex.h>

#define RE(C,i) C->real[i]
#define IM(C,i) C->imag[i]

#define SQ(x) (x)*(x)
#define IX(C,i) (C->ix+i)*C->el_stride

#define for_vectrip(A,B,C,i,j,k,dA,dB,dC) \
    for (size_t i = IX(A,dA), j = IX(B,dB), k = IX(C,dC), _I = 0; \
         _I < A->dim; ++_I, i+=A->dim_stride, j+=B->dim_stride, k+=C->dim_stride)
        
#define for_vecpair(A,B,i,j,dA,dB) \
    for (size_t i = IX(A,dA), j = IX(B,dB), _I = 0; \
         _I < A->dim; ++_I, i+=A->dim_stride, j+=B->dim_stride)

#define for_vec(A,i,dA)  \
    for (size_t i = IX(A,dA), _I = 0;\
         _I < A->dim; ++_I, i+=A->dim_stride)

/**
 * Struct and data type
 */

// Datatype for a complex vector field
typedef struct COMPLEXV {
    float *real;
    float *imag;

    size_t dim_stride;
    size_t el_stride;
    size_t dim;
    size_t ix;
} complex_v;

/**
 * Utilities and constructors
 */

void cv_print(complex_v *Z) {
        mexPrintf("real: %p, imag: %p\n",Z->real, Z->imag);
        mexPrintf("dim_stride: %ld, el_stide: %ld, dim: %ld, ix: %ld\n",
                Z->dim_stride, Z->el_stride, Z->dim, Z->ix);
}

// Creates a complex vector field given pointers to real and imaginary
// 1d data, strides for traversing between dimensions and elements, as
// well as spatial dimensions for vectors in the complex vector field.
complex_v cv_create(float *real, float *imag,
                    size_t dim_stride, size_t el_stride, size_t dim)
{
    complex_v C;
    C.real = real;
    C.imag = imag;

    C.dim_stride = dim_stride;
    C.el_stride  = el_stride;
    C.dim        = dim;
    C.ix = 0;

    return C;
}

// Allocates zeroes for real and imaginary data and calls cv_create.
complex_v cv_alloc(size_t data_size,
                   size_t dim_stride, size_t el_stride, size_t dim)
{
    float *real = mxCalloc(data_size, dim*sizeof(float));
    float *imag = mxCalloc(data_size, dim*sizeof(float));
    
    return cv_create(real, imag, dim_stride, el_stride, dim);
}

// Frees data allocated using cv_allocate
void cv_free(complex_v *C)
{
    mxFree(C->real);
    mxFree(C->imag);
}

/**
 * Computations
 */

// Sets a constant complex value to all elements in the current vector
void cv_set_const(complex_v *A, float real, float imag)
{
    for_vec(A,i,0) {
        RE(A,i) = real;
        IM(A,i) = imag;
    }
}

// Sets a complex number in B to a number in A, with an offset for A and B
void cv_set_rel(complex_v *A, int64_t rel_A, complex_v *B, int64_t rel_B)
{
    for_vecpair(A,B,i,j,rel_A,rel_B) {
        RE(A,i) = RE(B,j);
        IM(A,i) = IM(B,j);
    }
}

// Sets a complex number in B to a number in A
void cv_set(complex_v *A, complex_v *B)
{
    for_vecpair(A,B,i,j,0,0) {
        RE(A,i) = RE(B,j);
        IM(A,i) = IM(B,j);
    }
}

// Adds a complex number in B to a number in A, with an offset to B
void cv_addto(complex_v *A, complex_v *B, int64_t rel_B)
{
    for_vecpair(A,B,i,j,0,rel_B) {
        RE(A,i) += RE(B,j);
        IM(A,i) += IM(B,j);
    }
}

// Calculates C = A + B
void cv_add(complex_v *A, complex_v *B, complex_v *C)
{
    for_vectrip(A,B,C,i,j,k,0,0,0) {
        RE(A,i) = RE(B,j) + RE(C,k);
        IM(A,i) = IM(B,j) + IM(C,k);
    }
}

// Calculates C = A .* B
void cv_mult(complex_v *A, complex_v *B, complex_v *C)
{
    for_vectrip(A,B,C,i,j,k,0,0,0) {
        RE(A,i) = RE(B,j)*RE(C,k) - IM(B,j)*IM(C,k);
        IM(A,i) = IM(B,j)*RE(C,k) + RE(B,j)*IM(C,k);
    }
}

// Calculates C = A.weight(B) where A is a vector field
// and B is a scalar field
void cv_weight(complex_v *A, complex_v *B, complex_v *C)
{
    for_vecpair(A,B,i,j,0,0) {
        RE(A,i) = RE(B,j)*RE(C,IX(C,0)) - IM(B,j)*IM(C,IX(C,0));
        IM(A,i) = IM(B,j)*RE(C,IX(C,0)) + RE(B,j)*IM(C,IX(C,0));
    }
}

// Calculates A += <B|C> 
void cv_scalar_prod(complex_v *A, complex_v *B, complex_v *C)
{
    for_vecpair(B,C,j,k,0,0) {
        RE(A,IX(A,0)) += RE(B,j)*RE(C,k) + IM(B,j)*IM(C,k);
        IM(A,IX(A,0)) += RE(B,j)*IM(C,k) - IM(B,j)*RE(C,k);
    }
}

// Calculates A += <B|C> * dV 
void cv_scalar_prod_scale(complex_v *A, complex_v *B, complex_v *C, float dV)
{
    for_vecpair(B,C,j,k,0,0) {
        RE(A,IX(A,0)) += (RE(B,j)*RE(C,k) + IM(B,j)*IM(C,k))*dV;
        IM(A,IX(A,0)) += (RE(B,j)*IM(C,k) - IM(B,j)*RE(C,k))*dV;
    }
}

// Scales a vector with a scalar
void cv_scale(complex_v *A, float sc)
{
    for_vec(A,i,0) {
        RE(A,i) *= sc;
        IM(A,i) *= sc;
    }
}

// Checks if |A-B|^2 < eps^2, with an offset to B
bool cv_isdiffzero(complex_v *A, complex_v *B, int64_t rel_B, float eps_sq)
{
    float len_sq = 0;
    float dr,di; 
    for_vecpair(A,B,i,j,0,rel_B) {
        dr = RE(A,i) - RE(B,j);
        di = IM(A,i) - IM(B,j);

        len_sq += SQ(dr) + SQ(di);

        if (len_sq >= eps_sq) return false;
    }

    return true;
}

// Checks if |A|^2 < eps^2
bool cv_iszero(complex_v *A, float eps_sq)
{   
    float len_sq = 0;
    for_vec(A,i,0) {
        len_sq += SQ(RE(A,i)) + SQ(IM(A,i));
        if (len_sq >= eps_sq) return false;
    }
    return true;
}

// Advances the internal "pointer" with some relative jump
complex_v cv_jump(complex_v C, int64_t jump)
{
    C.ix += jump;
    return C;
}

#endif
