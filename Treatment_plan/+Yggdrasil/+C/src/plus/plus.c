#include "plus.h"

#define IN_DATA_A prhs[0]
#define  IN_ADR_A prhs[1]
#define IN_META_A prhs[2]
#define IN_DATA_B prhs[3]
#define  IN_ADR_B prhs[4]
#define IN_META_B prhs[5]

#define OUT_DATA  plhs[0]
#define  OUT_ADR  plhs[1]
#define OUT_META  plhs[2]

#define INDEX(oct)  oct.data.ix
#define ADR(oct) oct.adr[INDEX(oct)]
#define MAX(a,b) (a)>(b)?(a):(b)

// Matlab I/O
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Check input arguments */
    if (nlhs != 3)
        mexErrMsgTxt("Exactly three LHS argument needed.");
    
    if (nrhs != 6)
        mexErrMsgTxt("Exactly six arguments needed.");

    octree octA, octB;
    input_to_oct(&octA, IN_DATA_A, IN_ADR_A, IN_META_A);
    input_to_oct(&octB, IN_DATA_B, IN_ADR_B, IN_META_B);

#ifdef DEBUG    
    oct_print(&octA);
    oct_print(&octB);
#endif
    
    /* Check dimensions */
    if (octA.data_dim != octB.data_dim)
        mexErrMsgTxt("The octrees need to have the same dimensions.");
    
    if (octA.original_matrix_size[0] != octB.original_matrix_size[0] ||
        octA.original_matrix_size[1] != octB.original_matrix_size[1] ||
        octA.original_matrix_size[2] != octB.original_matrix_size[2])

        mexErrMsgTxt("The octrees need to represent same-size matrices.");
    
    octree octSum = sum(octA, octB);
    
#ifdef DEBUG  
    oct_print(&octSum);
#endif
    
    oct_to_output(&OUT_DATA, &OUT_ADR, &OUT_META, &octSum);
}

// Actual work
octree sum(octree octA, octree octB)
{   
    // Create a too large octree to store the sum in
    octree octC = oct_create(octA.data_len + octB.data_len,
                             octA.data_dim,
                             octA.original_matrix_size,
                             octA.N,
                             MAX(octA.eps_sq, octB.eps_sq),
                             octA.enum_order);
    
    uint64_t total_vol = 1 << 3*octA.N; 

    // Shift indices for nicer calculations
    ++octA.adr; ++octB.adr; ++octC.adr;
    
    for(INDEX(octA) = INDEX(octB) = INDEX(octC) = 0;;) {
        // C = A + B at current pieces
        cv_add(&octC.data, &octA.data, &octB.data);
        
        // Pieces of octA and octB at same adress?
        if (ADR(octA) == ADR(octB)) {
            // End condition
            if (ADR(octA) >= total_vol) {
                ADR(octC) = ADR(octA);
                break;
            }
            
            // Advance octA and octB
            ADR(octC) = ADR(octA);
            ++INDEX(octA); ++INDEX(octB);
        } else if (ADR(octA) < ADR(octB)) {
            // Advance octA
            ADR(octC) = ADR(octA);
            ++INDEX(octA);
        } else {
            // Advance octB
            ADR(octC) = ADR(octB);
            ++INDEX(octB);
        }
        ++INDEX(octC);
    }

    // Shift back adresses
    --octA.adr; --octB.adr; --octC.adr;
    
    // Remove unused memory and return
    oct_cut(&octC,INDEX(octC)+1);
    return octC;
}
