# VoronoiCorners

[![Build Status](https://travis-ci.org/robertdj/VoronoiCorners.jl.svg?branch=master)](https://travis-ci.org/robertdj/VoronoiCorners.jl)

*VoronoiCorners* use the [VoronoiDelaunay](https://github.com/JuliaGeometry/VoronoiDelaunay.jl) package to compute the vertices of the Voronoi cells in a tessellation.
Furthermore, it gives access to the area of the individual Voronoi cells in the same order as the input points.


## Usage

To be able to tie the vertices of a cell to its generator point, a new 2D point type is introduced with an index: `IndexablePoint2D`.
(This type *may* be included in VoronoiDelaunay, cf. [#15](https://github.com/JuliaGeometry/VoronoiDelaunay.jl/issues/15))

For convenience, plural versions of different 2D point types are also introduced (`AbstractPoints2D`, `IndexablePoints2D` and `Points2D`).

The main function is `corners` that returns the corners of the Voronoi cells for a vector of `IndexablePoint2D`s:

```julia
pts = [IndexablePoint2D(min_coord+rand(), min_coord+rand(), n) for n=1:10]
C = corners(pts)
```

The output `C` is a `Dict` with integer keys, referring to the indices in `pts`, i.e., the corners of the n'th point in `pts` is accessed as `C[n]`.

**Note**:
For technical reasons `VoronoiDelaunay` includes the corner points of its allowed region in the set of generators.
This creates unexpected edges in the Voronoi tessellation and the neighboring cells are *not* correct.
To deal with these corner points, `C` contains the key -1 which holds the vertices of all corner cells.

A couple of functions are available for computing areas:

- `polyarea` which computes the area of a polygon from its vertices using the [shoelace formula](https://en.wikipedia.org/wiki/Shoelace_formula)
- `voronoiarea` for a `Dict` of vertices as the output from `corners`.
- `voronoiarea(x,y)` for vectors `x` and `y`.

The latter `voronoiarea` is to allow general point configurations instead of only those in `[1,2] x [1,2]`.

**Note**: Due to the issue with the boundary corners mentioned above, `voronoiarea` does not yield correct areas for cells that border the corners.


## Installation

*VoronoiCorners* is not registered (yet), so install using 

```julia
Pkg.clone("https://github.com/robertdj/VoronoiCorners.jl")
```

