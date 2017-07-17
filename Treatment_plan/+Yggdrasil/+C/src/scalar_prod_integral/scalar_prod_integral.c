
#include "scalar_prod_integral.h"

#define IN_DATA_A prhs[0]
#define  IN_ADR_A prhs[1]
#define IN_META_A prhs[2]
#define IN_DATA_B prhs[3]
#define  IN_ADR_B prhs[4]
#define IN_META_B prhs[5]

#define OUT_SCALAR  plhs[0]

#define INDEX(oct)  oct.data.ix
#define ADR(oct) oct.adr[INDEX(oct)]
#define MIN(a,b) (a)<(b)?(a):(b)
#define VOL(oct) (oct.adr[INDEX(oct)] - oct.adr[INDEX(oct)-1])

#define MACHINE_EPS_SQ 1E-16

#define ADVANCE_AND_CALC(octX, octY) /* if ADR(octX) < ADR(octY) */        \
    if (cv_iszero(&octY.data, MACHINE_EPS_SQ)) { /* octY is zero */        \
        /* Advance octX until octX.adr == octY.adr */                      \
        if (ADR(octY) == total_vol) break;                                 \
        INDEX(octX) += 8;                                                  \
        while (ADR(octX) < ADR(octY)) {                                    \
            INDEX(octX) += 7;                                              \
        }                                                                  \
        ++INDEX(octY);                                                     \
    } else {                                                               \
        cv_scalar_prod_scale(integral, &octA.data, &octB.data, VOL(octX)); \
        /* Advance octX once */                                            \
        ++INDEX(octX);                                                     \
    }                      

#ifdef MATLAB
// Matlab I/O
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Check input arguments */
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
    
    /* Create a too large octree to store the prod in */
    OUT_SCALAR = mxCreateNumericMatrix(1, 1, mxSINGLE_CLASS, mxCOMPLEX);
    float *re = mxGetData(OUT_SCALAR);
    float *im = mxGetImagData(OUT_SCALAR);

    complex_v c = cv_create(re,im,1,9001,1);
    scalar_prod_integral(&c, octA, octB);
}
#endif

// Actual work
void scalar_prod_integral(complex_v *integral, octree octA, octree octB)
{
    uint64_t total_vol = 1 << 3*octA.N;
    uint64_t volA, volB;
    // Shift indices for nicer calculations
    ++octA.adr; ++octB.adr;

    for(INDEX(octA) = INDEX(octB) = 0;;) {
        // Pieces of octA and octB at same adress?
        if (ADR(octA) == ADR(octB)) {
            volA = VOL(octA);
            volB = VOL(octB);
            // C = A .* B * dV at current pieces with
            cv_scalar_prod_scale(integral, &octA.data, &octB.data, 
                        MIN(volA,volB));

            // End condition
            if (ADR(octA) >= total_vol) break;

            ++INDEX(octA); ++INDEX(octB);
        } else if (ADR(octA) < ADR(octB)) {
            // Advance octA
            ADVANCE_AND_CALC(octA, octB);
        } else { // If ADR(octA) > ADR(octB)
            // Advance octB
            ADVANCE_AND_CALC(octB, octA);
        }
    }

    // Shift back adresses
    --octA.adr; --octB.adr;
}
