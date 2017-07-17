/**
 * Structures and methods for internal representation of an octree.
 * There are methods to read, load and resize octree structures.
 */

#ifndef OCTIO_H
#define OCTIO_H

#include "comp.h"
#include <string.h>

#define OMS original_matrix_size

// Struct containting relevant pointers and metadata
typedef struct OCT {
    uint32_t  *OMS;
    uint8_t    N;
    float      eps_sq;
    uint8_t   *enum_order;
    
    complex_v  data;
    size_t     data_len;
    size_t     data_dim;
    uint64_t  *adr;
    size_t     adr_len;
} octree;

// Macro for reading and fail-checking fields
#define READ_FIELD(S,VAR,NAME)                                         \
    mxArray *VAR = mxGetField(S, 0, NAME);                              \
    if (VAR == NULL) mexErrMsgTxt("Field " NAME " couldn't be read.");
    

// Print some octree contents, useful for debugging
void oct_print(octree *oct)
{
    mexPrintf("OMS:       [%d, %d, %d]\n", oct->OMS[0], oct->OMS[1], oct->OMS[2]);
    mexPrintf("N:          %d\n", oct->N);
    mexPrintf("eps_sq:     %f\n", oct->eps_sq);
    mexPrintf("enum_order: %d %d %d %d %d %d %d %d\n",
              oct->enum_order[0], oct->enum_order[1],
              oct->enum_order[2], oct->enum_order[3],
              oct->enum_order[4], oct->enum_order[5],
              oct->enum_order[6], oct->enum_order[7]);
    mexPrintf("data (complex_v): \n");
    cv_print(&(oct->data));
    
    mexPrintf("adr: %p\n", oct->adr);
    mexPrintf("adr_len:    %d\n", oct->adr_len);
        
}

// Allocate contents for an octree
octree oct_create(size_t data_len, size_t data_dim, uint32_t *OMS, uint8_t N,
                  float eps_sq, uint8_t *enum_order)
{
    octree oct;
    
    float *real, *imag;
    real = mxCalloc(data_len*data_dim, sizeof(float));
    imag = mxCalloc(data_len*data_dim, sizeof(float));

    complex_v data = cv_create(real, imag, 1, data_dim, data_dim);
    
    uint64_t *adr;
    size_t adr_len = data_len + 1;
    adr = mxCalloc(adr_len, sizeof(uint64_t));

    oct.OMS = mxCalloc(3,sizeof(uint32_t));
    oct.enum_order = mxCalloc(8,sizeof(uint8_t));
    memcpy(oct.OMS, OMS, 3*sizeof(uint32_t));
    memcpy(oct.enum_order, enum_order, 8*sizeof(uint8_t));

    oct.data       = data;
    oct.data_len   = data_len;
    oct.data_dim   = data_dim;
    oct.adr        = adr;
    oct.adr_len    = adr_len;
    oct.N          = N;
    oct.eps_sq     = eps_sq;

    return oct;
}

// Cut octree to a given size
void oct_cut(octree *oct, size_t size)
{
    // Try to reallocate (shrink)
    void *new_real_ptr = mxRealloc(oct->data.real, oct->data_dim*size);
    void *new_imag_ptr = mxRealloc(oct->data.imag, oct->data_dim*size);
    void *new_adr_ptr  = mxRealloc(oct->adr, size+1);

    // Paranoia
    if (new_real_ptr == NULL ||
        new_imag_ptr == NULL ||
        new_adr_ptr  == NULL) {

        mxFree(new_real_ptr);
        mxFree(new_imag_ptr);
        mxFree(new_adr_ptr);
        mxFree(oct->data.real);
        mxFree(oct->data.imag);
        mxFree(oct->adr);
    }

    // Assign re-allocated space
    oct->data.real = new_real_ptr;
    oct->data.imag = new_imag_ptr;
    oct->adr = new_adr_ptr;

    // Update length
    oct->data_len = size;
    oct->adr_len = size + 1;
}

// Convert input data to octree struct
void input_to_oct(octree *oct, const mxArray *data, const mxArray *adr, const mxArray *meta)
{
    // Read fields
    READ_FIELD(meta, OMS,  "original_matrix_size");
    READ_FIELD(meta, N,    "N");
    READ_FIELD(meta, epsf, "eps");
    READ_FIELD(meta, eo,   "enum_order");

    // Acquire data and put into a complex_v, store dimensions
    oct->data_dim =  mxGetM(data);
    oct->data_len =  mxGetN(data);
    
    float *real, *imag;
    real =  (float*) mxGetData(data);
    if (mxIsComplex(data)) {
        imag =  (float*) mxGetImagData(data);
    } else {
        imag = (float*) mxCalloc(oct->data_dim * oct->data_len,sizeof(float));
    }
    oct->data = cv_create(real, imag, 1, oct->data_dim, oct->data_dim);

    // Acquire adress vector and length
    oct->adr     =  (uint64_t*) mxGetData(adr);
    oct->adr_len =  mxGetN(adr);
    
    // Acquire other stuff
    oct->OMS    =  (uint32_t*) mxGetData(OMS);
    oct->N      = *(uint8_t*)  mxGetData(N);
    float eps   = *(float*)    mxGetData(epsf);
    oct->eps_sq =              eps < 0 ? -eps*eps : eps*eps;
    
    oct->enum_order = mxGetData(eo);
}

// Convert octree struct to output data
void oct_to_output(mxArray **data, mxArray **adr, mxArray **meta, const octree *oct)
{
    const char *fields[6] = {
        "original_matrix_size",
        "N",
        "eps",
        "enum_order"
    };
    
    *meta = mxCreateStructMatrix(1,1,4,fields);

    if (*meta == NULL) mexErrMsgTxt("Failed to create structure array.");

    // Create arrays
    *data = mxCreateUninitNumericMatrix(1, 1, mxSINGLE_CLASS, mxCOMPLEX);
    *adr  = mxCreateUninitNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);

    mxArray *OMS        = mxCreateUninitNumericMatrix(1, 3, mxUINT32_CLASS, mxREAL);
    mxArray *N          = mxCreateNumericMatrix(1, 1, mxUINT8_CLASS, mxREAL);
    mxArray *eps        = mxCreateNumericMatrix(1, 1, mxSINGLE_CLASS, mxREAL);
    mxArray *enum_order = mxCreateUninitNumericMatrix(1, 8, mxUINT8_CLASS, mxREAL);

    // Paranoia
    if ( *data == NULL || *adr == NULL ||        OMS == NULL ||
             N == NULL ||  eps == NULL || enum_order == NULL) {
        mxDestroyArray(*data);
        mxDestroyArray(*adr);
        mxDestroyArray(OMS);
        mxDestroyArray(N);
        mxDestroyArray(eps);
        mxDestroyArray(enum_order);

        mexErrMsgTxt("Failed to allocate array.");
    }

    mxFree(mxGetData(*data));
    mxFree(mxGetImagData(*data));
    mxFree(mxGetData(*adr));
    mxFree(mxGetData(OMS));
    mxFree(mxGetData(enum_order)); 
    
    mxSetData(*data, oct->data.real);
    mxSetImagData(*data, oct->data.imag);
    mxSetM(*data, oct->data_dim);
    mxSetN(*data, oct->data_len);
    
    mxSetData(*adr, oct->adr);
    mxSetN(*adr, oct->adr_len);
    
    mxSetData(OMS, oct->OMS);
    
    uint8_t *N_ptr = mxGetData(N);
    *N_ptr = oct->N;
    
    float *eps_ptr = mxGetData(eps);
    *eps_ptr = oct->eps_sq < 0 ? -sqrt(-oct->eps_sq) : sqrt(oct->eps_sq);
    
    mxSetData(enum_order, oct->enum_order);
    
    mxSetField(*meta, 0, "original_matrix_size",  OMS);
    mxSetField(*meta, 0, "N",                       N);
    mxSetField(*meta, 0, "eps",                   eps);
    mxSetField(*meta, 0, "enum_order",     enum_order);
}

#endif
