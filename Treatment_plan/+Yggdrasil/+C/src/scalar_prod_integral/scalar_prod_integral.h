#ifndef SCALAR_PROD_INTEGRAL_H
#define SCALAR_PROD_INTEGRAL_H

#include <math.h>
#include <stdint.h>
#include <stdbool.h>

#ifdef MATLAB
#include <matrix.h>
#include <mex.h>
#endif

#include "comp.h"
#include "octio.h"

void scalar_prod_integral(complex_v*, octree, octree);

#endif
