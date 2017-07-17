#ifndef MTO_H
#define MTO_H

#include <math.h>
#include <stdint.h>
#include <stdbool.h>    
#include "comp.h"

#ifdef MATLAB
#include <matrix.h>
#include <mex.h>
#endif

bool fix_stitch(complex_v mat,
                complex_v oct,
                uint64_t*  oct_keep,
                const uint64_t  block_len,
                const float    eps_sq,
                const uint64_t  enum_order[]);

uint64_t do_stitching(float *real_mat,      float *imag_mat,
                  float *oct_real_data, float *oct_imag_data,
                  uint64_t *oct_adr, 
                  uint32_t data_dim,
                  uint8_t  N, 
                  float    eps_sq, 
                  uint8_t  enum_order[]);

#endif
