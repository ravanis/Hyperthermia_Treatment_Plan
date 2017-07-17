#define IX(x,y,z) ((x) + (y)*stridex + (z)*stridexy)
#define DATA(x,y,z) data[IX(x,y,z)]
#include <cmath>
#include <cstdio>
#include <vector>
#include <cstddef>
#include <limits>

#define NODEBUG
#ifdef DEBUG
#define PRINT(...) do{ fprintf( stderr, __VA_ARGS__ ); } while( false )
#else
#define PRINT(...) do{ } while ( false )
#endif

class TheGrandInterpolator : public Expression
{
public:
    //std::shared_ptr<double> shared_data;
    double *data;
    size_t stridex;
    size_t stridexy;
    size_t sizex;
    size_t sizey;
    size_t sizez;
    double sidelen = 0;

    ~TheGrandInterpolator()
    {
        // Set them free!
        free(data);
    }
    
    void set_data(double* dbl_in )
    {
    //    Data is copied, but should be shared pointer, TODO
    //    shared_data = std::shared_ptr<double>(dbl_in);
    //    data = shared_data.get();
          data = (double*)malloc(sizex * sizey * sizez * sizeof(double));
          memcpy(data, dbl_in, sizex * sizey * sizez * sizeof(double));
    }
    // Get weights for coord (x,y,z) inside unit cube
    void weights(double * const w, double x, double y, double z) const
    {
        double mx = 1-x;
        double my = 1-y;
        double mz = 1-z;

        // Weights are volume opposite point
        w[0] = mx*my*mz;
        w[1] = x *my*mz;
        w[2] = mx*y *mz;
        w[3] = x *y *mz;
        w[4] = mx*my*z ;
        w[5] = x *my*z ;
        w[6] = mx*y *z ;
        w[7] = x *y *z ;
    }

    // Interpolate, assuming normalized
    double interp(double * const w, double * const node) const
    {
        return
        w[0]*node[0] + w[1]*node[1] + w[2]*node[2] + w[3]*node[3] +
        w[4]*node[4] + w[5]*node[5] + w[6]*node[6] + w[7]*node[7];
    }

    void eval(Array<double>& values, const Array<double>& X) const
    {
        PRINT("%d\n", sizex);
        PRINT("%d\n", sizey);
        PRINT("%d\n", sizez);
        PRINT("%d\n", stridex);
        PRINT("%d\n", stridexy);
        
        
        
        assert(data);

        double x = X[0]/sidelen;
        double y = X[1]/sidelen;
        double z = X[2]/sidelen;

	x = round(x);
	y = round(y);
	z = round(z);
        
        if (x < 0) x = 0;
        if (y < 0) y = 0;
        if (z < 0) z = 0;
        if (x >= sizex - 1) x = sizex - DOLFIN_EPS - 1;
        if (y >= sizey - 1) y = sizey - DOLFIN_EPS - 1;
        if (z >= sizez - 1) z = sizez - DOLFIN_EPS - 1;

        size_t ix = x;
        size_t iy = y;
        size_t iz = z;
        
        // Calculate weights
        double w[8];
        weights(w, x-ix, y-iy, z-iz);

        PRINT("weights:\n");
        PRINT("%f ",  w[0]);
        PRINT("%f ",  w[1]);
        PRINT("%f ",  w[2]);
        PRINT("%f\n", w[3]);
        PRINT("%f ",  w[4]);
        PRINT("%f ",  w[5]);
        PRINT("%f ",  w[6]);
        PRINT("%f\n", w[7]);

        // Interpolate
        double node_val[8] = {  DATA(ix,   iy,   iz  ),
                                DATA(ix+1, iy,   iz  ),
                                DATA(ix,   iy+1, iz  ),
                                DATA(ix+1, iy+1, iz  ),
                                DATA(ix,   iy,   iz+1),
                                DATA(ix+1, iy,   iz+1),
                                DATA(ix,   iy+1, iz+1),
                                DATA(ix+1, iy+1, iz+1)};
        
        PRINT("node_val:\n");
        PRINT("%d: %f ",  IX(ix,   iy,   iz  ), node_val[0]);
        PRINT("%d: %f ",  IX(ix+1, iy,   iz  ), node_val[1]);
        PRINT("%d: %f ",  IX(ix,   iy+1, iz  ), node_val[2]);
        PRINT("%d: %f\n", IX(ix+1, iy+1, iz  ), node_val[3]);
        PRINT("%d: %f ",  IX(ix,   iy,   iz+1), node_val[4]);
        PRINT("%d: %f ",  IX(ix+1, iy,   iz+1), node_val[5]);
        PRINT("%d: %f ",  IX(ix,   iy+1, iz+1), node_val[6]);
        PRINT("%d: %f\n", IX(ix+1, iy+1, iz+1), node_val[7]);
        
        // Return values
        values[0] = interp(w, node_val);
    }
};
