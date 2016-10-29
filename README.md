# VoronoiCells

[![Build Status](https://travis-ci.org/JuliaGeometry/VoronoiCells.jl.svg?branch=master)](https://travis-ci.org/JuliaGeometry/VoronoiCells.jl)
[![codecov.io](https://codecov.io/github/JuliaGeometry/VoronoiCells.jl/coverage.svg?branch=master)](https://codecov.io/github/JuliaGeometry/VoronoiCells.jl?branch=master)

*VoronoiCells* use the [VoronoiDelaunay](https://github.com/JuliaGeometry/VoronoiDelaunay.jl) package to compute the vertices and areas of the Voronoi cells in a tessellation.


## Installation

In Julia, run

```julia
Pkg.add("VoronoiCells")
```


## Usage

The two main functions of *VoronoiCells* are `voronoicells` and `voronoiarea`.
Both functions have a method where the input is a vector of `IndexablePoint2D`'s -- a subtype of the `AbstractPoint2D` from the [GeometricalPredicates](https://github.com/JuliaGeometry/GeometricalPredicates.jl) package.
Such a vector can be created with e.g.

```julia
using VoronoiCells
pts = [IndexablePoint2D(1+rand(), 1+rand(), n) for n in 1:10]
```

Note that an `AbstractPoint2D` must be in [1,2]x[1,2].
The last entry in an `IndexablePoint2D` is used to associate it with the corners of its Voronoi cells in the output from `voronoicells`:

```julia
C = voronoicells(pts)
```

`C` is a Dict where the keys are integers representing the indices of the generator points in `pts` and `C[n]` is a vector with the corners of the `n`'th Voronoi cell.

The function `voronoiarea` computes the areas of a point set *in the same order as the input*. 
I.e., in

```julia
A = voronoiarea(C)
```

`A[n]` is the area of the `IndexablePoint2D` with index `n`.
There is also a method of `voronoiarea` that accepts two vectors with `x` and `y` coordinates, respectively.
If `x` and `y` have entries that are *not* in the unit square a suitable bounding box must be specified.

```julia
x = rand(10)
y = rand(10)
A = voronoiarea(x,y)
```

The window is specified as a vector with `[xmin, xmax, ymin, ymax]`.
Consider e.g. points in the rectangle [0,1]x[-1,1]:

```julia
x = rand(10)
y = 2*rand(10) - 1
A = voronoiarea(x, y, [0.0, 1.0, -1.0, 1.0])
```

A third function is `density`.
If one wish to cover the bounding box with cirlces of equal radii and centers specified by vectors `x` and `y`, `density(x,y)` returns the minimum such radius.
Just as in `voronoiarea` the default bounding box is the unit square and a different box can be specified as a third argument.


## Note

For technical reasons (that I don't fully understand) VoronoiDelaunay includes the corner points of the default bounding box, i.e., (1,1), (2,1), (2,2) and (1,2) in the set of generators.
This means that these corners also get their own Voronoi cell and the cells of the generators closest to the corners are a priori *incorrect*.

The way *VoronoiCells* removes the corner cells and update the affected neighbor cells are explained in the [attached document](doc/remove_bounding_box.md).
The `doc` folder also includes the script `plots.jl` used to make the plots in the document.

