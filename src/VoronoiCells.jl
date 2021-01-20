module VoronoiCells

import GeometryBasics
import VoronoiDelaunay
import VoronoiDelaunay: getx, gety

using RecipesBase

export
    IndexablePoint2D,
    PointCollection,
    Rectangle,
    Tessellation,

    left,
    lower,
    right,
    upper,
    map_rectangle,
    voronoiarea,
    voronoicells


include("Points.jl")
include("Rectangle.jl")
include("Clipping.jl")
include("Sort.jl")
include("Cells.jl")
include("Plot.jl")
include("Area.jl")


const BoundingBox = Rectangle(
    VoronoiDelaunay.Point2D(VoronoiDelaunay.min_coord, VoronoiDelaunay.min_coord),
    VoronoiDelaunay.Point2D(VoronoiDelaunay.max_coord, VoronoiDelaunay.max_coord)
)

end # module
