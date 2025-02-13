![splpak](media/splpak.png)
============

This library contains routines for fitting (least squares) a multidimensional cubic spline to arbitrarily located data.  It also contains routines for evaluating this spline (or its partial derivatives) at any point.
The double precision SPLPAK files from [NCL](https://github.com/NCAR/ncl) were modernised by Jacob Williams to be in modern maintainable Fortran, but keep very similar interfaces to the original code so that it is a near 'drop in' replacement. This library breaks that backwards compatibility to produce an interface that is more idomatic for the modern programmer.

By default, the library is built with double precision (`real64`) real values. Explicitly specifying the real kind can be done using the following processor flags:

Preprocessor flag | Kind  | Nominal number of bytes
----------------- | ----- | ---------------
`SPLINE_REAL32`  | `real(kind=real32)`  | 4
`SPLINE_REAL64`  | `real(kind=real64)`  | 8
`SPLINE_REAL128` | `real(kind=real128)` | 16

## Compiling

This library is a single file that is quick to compile. Simply copy the `splpak.F90` file into your project and use `spline` in modules that need the functions.

## Basic Use

Spline fitting is done by creating an instance of the object `spline_fitter`. Each `spline_fitter` object can be used to fit a spline to a set of data points and then calculate the value of the spline and it's derivatives (up to the 4th derivative) at any point. The data points for fitting are specified as a point in N-D space and a value at that point.

### 1D

The simplest way of using the library is to fit 1D points. At this point, the spline fitting is simple least squares fitting of a curve with a spline. To do this, generate two arrays, one containing the coordinate values of your points(`x`), and one containing the values at those coordinates (`y`). To fit your points, simply call the `fit` method

```fortran
type(spline_fitter) :: solver
call solver%fit(x,y,nodes, ierror = ierror)
```

The first two parameters are your x and y arrays, the third is the number of nodal points in the spline to fit. This must be <= the number of points that you are fitting. Optionally you can specify a default kind integer parameter `ierror` to return an integer error code which will be the constant `spline_no_error` if there is no error.

Optionally if you want to adjust the weight that you assign to each point while fitting you can pass an array of weights after x and y

```fortran
type(spline_fitter) :: solver
call solver%fit(x,y,w,nodes)
```

To calculate the value of the fitted spline at you have to call the `evaluate` method with the x value at which you want to evaluate the value

```fortran
value = solver%evaluate(1.2)
```

To calculate the value of the derivative of the fitted spline you have  to call the `evaluate_deriv` method with the x value at which to calculate the derivative and a default kind integer parameter for the order of the derivative to calculate. An order of `0` will return the value of the spline at the location, `1` will return the first derivative etc. Derivatives up to the 4th derivative are supported.


### Current state

The library has been completely converted to the new interface, but the documentation is still being converted. In particular the FORD documentation in the source code has only been partly converted.



## See also
 * [The original modernised splpak](https://jacobwilliams.github.io/splpak/) This version retains the interface of the Fortran 77 version and is a near drop in replacement
 * [The NCAR Command Language ](https://github.com/NCAR/ncl) (specificially, the [csagrid](https://github.com/NCAR/ncl/tree/develop/ngmath/src/lib/gridpack/csagrid) directory)
 * [bspline](https://github.com/NCAR/bspline) - Cubic B-Spline implementation in C++ templates. Also has a copy of [splpak.f](https://github.com/NCAR/bspline/tree/master/Tests/Fortran)
 * [Ngmath Library Overview](https://ngwww.ucar.edu/ngmath/)
 * [bspline-fortran](https://github.com/jacobwilliams/bspline-fortran) Multidimensional B-Spline Interpolation of Data on a Regular Grid
 * [regridpack](https://github.com/jacobwilliams/regridpack) Linear or cubic interpolation for 1D-4D grids
 * [finterp](https://github.com/jacobwilliams/finterp) 1D-6D linear or nearest-neighbor interpolation
