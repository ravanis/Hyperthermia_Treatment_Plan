/**
 * A 3d distance transform. Generalized from the 2d algorithm presented in [1].
 * 
 * [1] "A General Alorithm for Computing Distance Transform in Linear Time"
 *      A. Meijster, J. B. T. M. Roerdink, W. H. Hesselink
 *      University of Groningen
 */

#include "meijster.h"



// Error messages
#ifdef MATLAB
#define ERR(errstr)  mexErrMsgTxt(errstr)
#else
#define ERR(errstr)  perror(errstr); exit(-1)
#endif

// Generic error printing
#define errcase(X) case X: ERR("Argument of class " #X " is not supported.");

// Generic code to convert data from type T
#define CONVDATA(T) { /* Scoping */              \
    T *D = mxGetData(IN_DATA);                   \
    size_t len = mxGetNumberOfElements(IN_DATA); \
    B = malloc(len*sizeof(uint8_t));             \
    for (int i = 0; i < len; ++i) {              \
        B[i] = !!D[i];                           \
    }}

#define IN_DATA     prhs[0]
#define OUT_DATA_D  plhs[0]
#define OUT_DATA_I  plhs[1]

#ifdef MATLAB
// Main function in Matlab
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Check input args */
    if (nrhs == 0) {
        // Send help
        printf(
            "NAME\n"
            "       meijster - Computes a distance transform in (up to) 3 dimensions\n"
            "SYNOPSIS\n"
            "       meijster(matrix)\n"
            );
        return;
    }

    if (nrhs != 1) mexErrMsgTxt("Accepts exactly one argument.");
    
    /* Get input */
    uint8_t *B;
    
    // Check class
    switch(mxGetClassID(IN_DATA)) {
    // If uint8, load.
    case mxUINT8_CLASS: B = mxGetData(IN_DATA); break;
    // If numerical, convert.
    case mxLOGICAL_CLASS: CONVDATA(mxLogical); break;
    case mxCHAR_CLASS:    CONVDATA(char);      break;
    case mxDOUBLE_CLASS:  CONVDATA(double);    break;
    case mxSINGLE_CLASS:  CONVDATA(float);     break;
    case mxINT8_CLASS:    CONVDATA(int8_t);    break;
    case mxINT16_CLASS:   CONVDATA(int16_t);   break;
    case mxUINT16_CLASS:  CONVDATA(uint16_t);  break;
    case mxINT32_CLASS:   CONVDATA(int32_t);   break;
    case mxUINT32_CLASS:  CONVDATA(uint32_t);  break;
    case mxINT64_CLASS:   CONVDATA(int64_t);   break;
    case mxUINT64_CLASS:  CONVDATA(uint64_t);  break;
    // If other, panic.
    errcase(mxUNKNOWN_CLASS);
    errcase(mxCELL_CLASS);
    errcase(mxSTRUCT_CLASS);
    errcase(mxFUNCTION_CLASS);
    errcase(mxVOID_CLASS);
    // MATLAB returned something that it shouldn't be capable of returning.
    default: mexErrMsgTxt("WTF is MATLAB doing?");
    }
    
    /* Read and interpret matrix size */
    int ndims = mxGetNumberOfDimensions(IN_DATA);
    if (ndims > 3) mexErrMsgTxt("Array must be (at most) 3d.");
    
    const mwSize *size = mxGetDimensions(IN_DATA);
    mwSize sX, sY, sZ;
    
    if (ndims == 3) {
        sX = size[0];
        sY = size[1];
        sZ = size[2];
    } else {
        // Shift right
        sX = 1;
        sY = size[0];
        sZ = size[1];

        if (sZ == 1) {
            // If Ax1 vector, interpret as 1x1xA
            sZ = sY;
            sY = 1;
        }
    }

    /* Allocate outputs */
    OUT_DATA_D = mxCreateNumericArray(ndims, size, mxINT32_CLASS, mxREAL);
    
    // Switch types if compiled for 64-bit addresses
    if (sizeof(mwSize) == sizeof(size_t))
        OUT_DATA_I = mxCreateNumericArray(ndims, size, mxUINT64_CLASS, mxREAL);
    else
        OUT_DATA_I = mxCreateNumericArray(ndims, size, mxUINT32_CLASS, mxREAL);

    if (OUT_DATA_D == NULL || OUT_DATA_I == NULL)
        mexErrMsgTxt("Matrix creation failed.");
    
    /* Get pointers for D, distance squared, and g, closest index */
    int32_t *D = mxGetData(OUT_DATA_D);
    mwSize  *g = mxGetData(OUT_DATA_I);

    meister(D, g, B, sX, sY, sZ);
    
    /* Switch to one-indexing because matlab */
    for (int i = 0; i < sX*sY*sZ; ++i)
        ++g[i];
}
#endif

// Does the actual work, independent from Matlab stuff
int meister(int32_t *D, index_t *g, uint8_t *B, index_t sX, index_t sY, index_t sZ)
{
    /* Allocate variables needed in calculations */
    size_t numel = sX*sY*sZ;
    int32_t *G_y = calloc(numel, sizeof(int32_t));
    int32_t *G_z = calloc(numel, sizeof(int32_t));
    int32_t *g_i = calloc(numel, sizeof(int32_t));
    int32_t *g_j = calloc(numel, sizeof(int32_t));
    int32_t *g_k = calloc(numel, sizeof(int32_t));

    if (D == NULL || g == NULL ||
        G_y == NULL || G_z == NULL ||
        g_i == NULL || g_j == NULL || g_k == NULL)
        ERR("Failed to allocate some pointers.");

    size_t shift;
    int32_t inf = sX+sY+sZ;
    int32_t inf_sq = inf*inf;
    
    size_t _i,_j,_k;
#pragma omp parallel default(shared) private(shift,_i,_j,_k)
    {
#pragma omp for schedule (static) collapse(2)
    for (size_t j = 0; j < sY; ++j) {
        for (size_t i = 0; i < sX; ++i) {
            shift = i + sX*j;
            meij_phase_1(G_z+shift, g_k+shift, B+shift,
                            sZ, sX*sY, inf);
        }
    }
#pragma omp for schedule (static) collapse(2)
    for (size_t i = 0; i < sX; ++i) {
        for (size_t z = 0; z < sZ; ++z) {
            shift = i + sX*sY*z;
            meij_phase_2(G_y+shift, g_j+shift, G_z+shift,
                             sY, sX, inf_sq);
        }
    }
    
#define IX(x,y,z) (x + y*sX + z*sX*sY)
    
    meij_phase_2(D, g_i, G_y, sX, 1, inf_sq);
    if (D[0] >= inf_sq)
        ERR("No points in volume."); 
    
#pragma omp for schedule (static) collapse(2)
        for (size_t z = 0; z < sZ; ++z) {
            for (size_t y = 0; y < sY; ++y) {
                shift = sX*y + sX*sY*z;
                meij_phase_2(D+shift, g_i+shift, G_y+shift,
                                sX, 1, inf_sq);
            }
        }

#pragma omp for schedule (static) collapse(3)
        for (size_t z = 0; z < sZ; ++z) {
            for (size_t y = 0; y < sY; ++y) {
                for (size_t x = 0; x < sX; ++x) {
                    _i = g_i[IX( x, y,z)];
                    _j = g_j[IX(_i, y,z)];
                    _k = g_k[IX(_i,_j,z)];
                    g[IX(x,y,z)] = IX(_i,_j,_k);
                }
            }
        }
    } // End parallel
    
    free(G_y);
    free(G_z);
    free(g_i);
    free(g_j);
    free(g_k);
}

void meij_phase_1(int32_t *G, int32_t *g, uint8_t *B,
               size_t length, size_t stride, int32_t inf)
{
    index_t last_el = (length-1)*stride;
    
    // Forward sweep
    G[0] = B[0] ? 0 : inf;
    g[0] = 0;
    for (index_t i = stride; i <= last_el; i += stride) {
        if(B[i]) {
            // G[i] is already zero 
            g[i] = i/stride;
        } else {
            G[i] = G[i - stride] + 1;
            g[i] = g[i - stride];
        }
    }

    // Skip backward sweep if empty column
    if (G[last_el] < inf) {
        g[last_el] = (length - 1) - G[last_el];
        for (index_t i = last_el; i > 0; i -= stride) {
            if (G[i - stride] > 1 + G[i]) { // Closest point is to the right
                G[i - stride] = G[i] + 1;
                g[i - stride] = g[i];
            }
        }
    }

    // Square
    for (index_t i = 0; i <= last_el; i += stride) {
        G[i] = G[i]*G[i];
    }
}

#define _F(x, i, G) (x-i)*(x-i) + G
#define _SEP(u,i,G_u,G_i) ((u*u - i*i + G_u - G_i)/(2*(u-i)))
#define f(x,i) _F(x,i,G[i*stride])
#define sep(u,i) _SEP(u,i,G[u*stride],G[i*stride])

void meij_phase_2(int32_t *D, int32_t *g, int32_t *G,
                  size_t length, size_t stride, int32_t inf_sq)
{
    int32_t* s = malloc(length*sizeof(int32_t));
    int32_t* t = malloc(length*sizeof(int32_t));
    int32_t w = 0;
    int32_t q = 0;

    s[0] = 0; t[0] = 0; q = 0;

    // Scan 3
    for (int u = 1; u < length; ++u) {
        while (q>=0 && f(t[q],s[q]) > f(t[q],u))
            --q;
        if (q < 0) {
            q = 0; s[0] = u;
        } else {
            w = 1 + sep(s[q],u);

            if (w < length) {
                ++q; s[q] = u; t[q] = w;
            }
        }
    }

    // Scan 4
    for (int u = length; u-- > 0;) {
        D[u*stride] = f(u, s[q]);

        g[u*stride] = D[u*stride] >= inf_sq ? -1 : s[q];

        if (u == t[q]) {
            --q;
        }
    }

    free(s);
    free(t);
}
