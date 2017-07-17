#include "oct_to_mat.h"

#define IN_DATA       prhs[0]
#define IN_ADR        prhs[1]
#define IN_ENUM_ORDER prhs[2]
#define IN_DATA_LEN   prhs[3]
#define IN_N          prhs[4]

#define OUT_MAT       plhs[0]

#define CUBE(x) (x)*(x)*(x)

// Transforms an octree adress to the corresponding matrix index
size_t get_index_from_oct_adr(uint64_t vol, size_t *modified_enum);
// Transform a number 8^n to 2^n, this is used to go from volume to lengths
uint64_t vol_to_len(uint64_t eight_n);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{ 
    float *real_mat, *imag_mat;
    float *oct_real_data, *oct_imag_data;
    uint64_t *oct_adr;
    uint8_t *enum_order;

    uint8_t N;
    uint32_t data_dim; 

    // Load input arguments
    oct_real_data =    (float*)mxGetData(IN_DATA);
    oct_imag_data =    (float*)mxGetImagData(IN_DATA);
    oct_adr       = (uint64_t*)mxGetData(IN_ADR);
    enum_order    =  (uint8_t*)mxGetData(IN_ENUM_ORDER);
    N             = *(uint8_t*)mxGetData(IN_N);
    data_dim      = *(uint32_t*)mxGetData(IN_DATA_LEN);
  
    // Transform the enum_order into a single index, corresponing to indecies
    // of a 2x2x2 cube.
    size_t modified_enum[8];
    uint64_t L = 1 << N;
    uint64_t look_up[8] = {0, 1, L, 1+L, L*L, L*L+1, L*L+L, L*L+L+1};
    for (int i = 0; i < 8; ++i) {
        modified_enum[i] = look_up[enum_order[i]-1];
    }

    // Create the output matrix
    size_t dims[4] = {L, L, L, data_dim};
    OUT_MAT = mxCreateNumericArray(4,dims,mxSINGLE_CLASS,mxCOMPLEX);   
  
    real_mat = (float*)mxGetData(    OUT_MAT);   
    imag_mat = (float*)mxGetImagData(OUT_MAT);

    // Calculate the total volume of the octree, used for end conditions and
    // indexing of vector data
    uint64_t total_vol = CUBE(L);
    // Nice package of data in complex vectorfields
    complex_v mat = cv_create(real_mat, imag_mat, total_vol, 1, data_dim);
    complex_v oct = cv_create(oct_real_data, oct_imag_data, 1, data_dim, data_dim);
  
    // Go through the octree
    for (uint64_t i = 0; oct_adr[i] < total_vol; ++i){
        // Get the matrix index from the adr
        size_t ind = get_index_from_oct_adr(oct_adr[i], modified_enum);
        // Pick out a piece of constant value to work with
        uint64_t piece_vol = oct_adr[i+1] - oct_adr[i];
        uint64_t piece_len = vol_to_len(piece_vol);

        // Time to put all values from the piece into the matrix

        // Go through every node in the piece
        for (size_t z = 0; z < piece_len; ++z){
            for (size_t y = 0; y < piece_len; ++y){
                for (size_t x = 0; x < piece_len; ++x){
                    // Calculate the node's position in the matrix
                    size_t mat_index = ind + x + L * (y + L * z);
                    // Transfer the data to the matrix from the octree
                    cv_set_rel(&mat,mat_index,&oct,i);
                }
            }
        }
    }
}

// Find the matrix index from the oct adress using some quick
// bitshift operations. The octree have an internal fractal structure,
// it follows that a position can be described with N sequential 
// choices of octants, one for every subdivision.
size_t get_index_from_oct_adr(uint64_t vol, size_t *modified_enum){
    size_t ind = 0;
    uint64_t twoLoopInd = 1;
    // Find the corresponding octant for every subdivision
    while (vol != 0){
        ind += twoLoopInd * (size_t)modified_enum[vol & (uint64_t)7]; 
        twoLoopInd <<= 1;
        vol >>= 3;
    }
    return ind; // Return the matrix index
}
 
// Transforms a number 8^n to 2^n using bitshifts
uint64_t vol_to_len(uint64_t eight_n) {
    uint64_t two_n = 1;
    while (eight_n != 1){
        eight_n >>= 3;
        two_n   <<= 1;
    }
    return two_n;
}
