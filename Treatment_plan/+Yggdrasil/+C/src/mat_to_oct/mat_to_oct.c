#include "mat_to_oct.h"

#define IN_N           prhs[0]
#define IN_DATA_LEN    prhs[1]
#define IN_MAT         prhs[2]
#define IN_EPS         prhs[3]
#define IN_ENUM_ORDER  prhs[4]

#define OUT_DATA    plhs[0]
#define OUT_ADR     plhs[1]

#define CUBE(x) (x)*(x)*(x)


#ifdef MATLAB
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{ 
    // Setup pointers
    float  *eps_ptr;
    uint8_t *enum_order;
    uint64_t *oct_keep, *oct_adr;
    float   *real_mat, *imag_mat;
    float   *oct_real_data, *oct_imag_data;
  
    // Setup non-pointers
    float eps_sq; 
    uint64_t numel_mat;
    uint32_t data_dim;
    uint8_t N;
  
    // Process input data
    real_mat = (float*)  mxGetData(IN_MAT);
    imag_mat = (float*)  mxGetImagData(IN_MAT);  
  
    // Calculate the square of the eps but keep the sign
    eps_ptr  = (float*) mxGetData(IN_EPS);
    if (eps_ptr[0] > 0) {
        eps_sq = eps_ptr[0]*eps_ptr[0];
    } else {
        eps_sq = -eps_ptr[0]*eps_ptr[0];
    }
  
    enum_order =  (uint8_t*)  mxGetData(IN_ENUM_ORDER);
    N          = *(uint8_t*)  mxGetData(IN_N);
    data_dim   = *(uint32_t*) mxGetData(IN_DATA_LEN); 
    numel_mat  = 1 << (3*N); // Number of elements in mat, 8^N

#ifdef DEBUG
    mexPrintf("N: %d \ndata_dim: %d \nnumel_mat: %ld \n",\
              N, data_dim, numel_mat);
    mexPrintf("mat[0]: %f + %fi \n",\
              real_mat[0], imag_mat[0]);
    mexPrintf("eps_sq: %f\n",\
              eps_sq);
    mexPrintf("enum_order: %d, %d, %d, %d, %d, %d, %d, %d\n",\
              enum_order[0],enum_order[1],enum_order[2],enum_order[3],
              enum_order[4],enum_order[5],enum_order[6],enum_order[7]);
    mexPrintf("2^N: %ld\n",(uint64_t)(1 << N));
#endif

    // Worst case size
    uint64_t max_data_size = data_dim * numel_mat;
    uint64_t max_adr_size  = numel_mat + 1;
  
    // Create output arguments data and adr
    OUT_DATA = mxCreateNumericMatrix(data_dim, numel_mat,
                                     mxSINGLE_CLASS, mxCOMPLEX);
    OUT_ADR  = mxCreateNumericMatrix(1, max_adr_size, mxUINT64_CLASS, mxREAL);
  
    if (OUT_DATA == NULL || OUT_ADR == NULL) {
        mexErrMsgTxt("Failed to create matrix/matrices.");
    }
  
    // Get pointers to output data ...
    // ... for real and imag data
    oct_real_data = (float*) mxGetData(OUT_DATA);   
    oct_imag_data = (float*) mxGetImagData(OUT_DATA);
    //... for adresses
    oct_adr = (uint64_t*) mxGetData(OUT_ADR);
      
    uint64_t vac_pos = 
        do_stitching(real_mat, imag_mat, oct_real_data, oct_imag_data,
                     oct_adr, data_dim, N, eps_sq, enum_order);

    // Too much data was allocated before, time to cut off the unneeded parts
    // Set new dimension
    mxSetN(OUT_ADR, vac_pos);
    mxSetN(OUT_DATA, vac_pos-1);

    // Shrink allocated data
    void *new_oct_adr = mxRealloc(oct_adr, sizeof(uint64_t)*vac_pos);
    void *new_oct_real_data = mxRealloc(oct_real_data, data_dim*sizeof(float)*(vac_pos-1));
    void *new_oct_imag_data = mxRealloc(oct_imag_data, data_dim*sizeof(float)*(vac_pos-1));
  
    // Maximum paranoia
    if (new_oct_adr == NULL ||
        new_oct_real_data == NULL ||
        new_oct_imag_data == NULL) {
        if (new_oct_adr != NULL)       mxFree(new_oct_adr);
        else                           mxFree(oct_adr);
        if (new_oct_real_data != NULL) mxFree(new_oct_real_data);
        else                           mxFree(oct_real_data);
        if (new_oct_imag_data != NULL) mxFree(new_oct_imag_data);
        else                           mxFree(oct_imag_data);
        mexErrMsgTxt("Failed to re-allocate array.");
    }
    
    // Replace data pointers
    mxSetData(OUT_ADR, new_oct_adr);
    mxSetData(OUT_DATA, new_oct_real_data);
    mxSetImagData(OUT_DATA, new_oct_imag_data);
}
#endif

uint64_t do_stitching(float *real_mat,      float *imag_mat,
                      float *oct_real_data, float *oct_imag_data,
                      uint64_t *oct_adr, 
                      uint32_t data_dim,
                      uint8_t  N, 
                      float    eps_sq, 
                      uint8_t  enum_order[])
{
  
    // Translate enumeration order to 1d displacements
    uint64_t L = 1 << N; // Side length of input matrix
    uint64_t look_up[8] = {0, 1, L, 1+L, L*L, L*L+1, L*L+L, L*L+L+1};
  
    uint64_t modified_enum[8];
    for (int i = 0; i < 8; ++i) {
        modified_enum[i] = look_up[enum_order[i]-1];
    }
  
    uint64_t numel_mat = CUBE(L);

    // Nice package of data in complex vectorfields
    complex_v mat = cv_create(real_mat, imag_mat, numel_mat, 1, data_dim);
    complex_v oct = cv_create(oct_real_data, oct_imag_data, 1, data_dim, data_dim);

    // Run the recursive function to transfer mat to oct and at
    // the same time stitch the octree
    fix_stitch(mat, oct, oct_adr, L, eps_sq, modified_enum);

    // First vacant position
    uint64_t vac_pos = 0;
    uint64_t *oct_keep = oct_adr;
    // All the values to be kept in the final octree
    // has been marked in oct_keep
    for (uint64_t i = 0; i < numel_mat; ++i) {
        if (oct_keep[i]) { // Keep all
            oct_adr[vac_pos] = i; // Save adress
            cv_set_rel(&oct, vac_pos, &oct, i); // Save data element
            ++vac_pos;
        }
    }
  
    // Set final element
    oct_adr[vac_pos] = numel_mat;
    ++vac_pos;
  
    return vac_pos;
}


/*
 * Fix stitches is a recursive function that tries to collapse 8 sub-blocks
 * into a single block if they are similar enough, which we call "Stitching".
 * Returns true if stitch possible and false when not possible.
 * block_len is a decreasing variable during the recursion andrecursion
 * ends when block_len reaches 2.
 */
bool fix_stitch(complex_v mat,
                complex_v oct,
                uint64_t*  oct_keep,
                const uint64_t  block_len,
                const float    eps_sq,
                const uint64_t  enum_order[]) {
    complex_v mean;
    
    if (block_len == 2) {
        // On next to last level (end condition) 
        mean = cv_alloc(1,1,1,mat.dim); // Allocate complec vector for mean
        
        // Go through the next 8 values 
        for (size_t i = 0; i<8; ++i) {
            cv_set_rel(&oct, i, &mat, enum_order[i]); // Copy element from mat to oct
            cv_addto(&mean, &oct, i);                 // Track sum for mean calc
        }
        cv_scale(&mean, 0.125f); // Scale sum to get mean

        // If for any vec, abs(mean - vec) >= eps, stiching cannot be done.
        for (size_t i = 0; i<8; ++i) {
            if (!cv_isdiffzero(&mean, &oct, i, eps_sq)) {
                // Can not stitch. Then keep all 8 values
                for (size_t j = oct.ix; j < 8 + oct.ix; ++j)
                    oct_keep[j] = 1; 
                cv_free(&mean);
                return false;
            }
        }
        
        // It is possible to stitch! Mark one value to keep
        oct_keep[oct.ix] = 1;
        
    } else { // block_len > 2
        // Precalculate values for translations
        uint64_t block_vol = CUBE(block_len);
        uint64_t sub_block_len = block_len / 2;
        uint64_t sub_block_vol = block_vol / 8;
        
        // Check if all sub-blocks are constant
        bool isConst = true;
        for (size_t i = 0; i < 8; ++i) {
            isConst &= fix_stitch(   
                cv_jump(mat, sub_block_len*enum_order[i]),
                cv_jump(oct, sub_block_vol*i),
                oct_keep,
                sub_block_len,
                eps_sq,
                enum_order);
        }
        
        if (!isConst)
            return false;
        
        // All sub-blocks constant. Are they the same constant?

        // Calc mean
        mean = cv_alloc(1,1,1,mat.dim);
        for (size_t i = 0; i < block_vol; i += sub_block_vol) {
            cv_addto(&mean, &oct, i);
        }
        cv_scale(&mean, 0.125f);
        
        // Compare to mean
        for (size_t i = 0; i < block_vol; i+=sub_block_vol) {
            if (!cv_isdiffzero(&mean, &oct, i, eps_sq)) {
                // It is not possible to stitch, return
                cv_free(&mean);
                return false;
            }
        }

        // All sub-blocks same constant, ok to stitch.
        // Mark blocks not to keep.
        for (size_t i = sub_block_vol; i < block_vol; i += sub_block_vol) {
            oct_keep[oct.ix + i] = 0;
        }
    }
    
    // Stitch is ok, set new value
    if (cv_iszero(&mean, eps_sq)) {
        // |mean| < eps, set to zero
        cv_set_const(&oct,0,0);
    } else {
        // otherwize, set mean
        cv_set(&oct, &mean);
    }
    
    cv_free(&mean);
    return true;
}
