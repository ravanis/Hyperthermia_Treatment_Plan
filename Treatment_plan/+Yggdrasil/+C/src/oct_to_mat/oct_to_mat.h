#ifndef OTM_H
#define OTM_H

#include <math.h>
#include <stdint.h>
#include <stdbool.h>

#ifdef MATLAB
#include <matrix.h>
#include <mex.h>
#endif

#include "comp.h"

// Transforms an octree adress to the corresponding matrix index
size_t get_index_from_oct_adr(uint64_t vol, size_t *modified_enum);
// Transform a number 8^n to 2^n, this is used to go from volume to lengths
uint64_t vol_to_len(uint64_t eight_n);


#endif
