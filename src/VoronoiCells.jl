module VoronoiCells

import GeometryBasics
import VoronoiDelaunay
import VoronoiDelaunay: getx, gety, geta, getb, getgena, getgenb

using RecipesBase

export
    IndexablePoint2D,
    PointCollection,
    Rectangle,

    map_rectangle,
    voronoicells


include("Points.jl")
include("Rectangle.jl")
include("Clipping.jl")
include("Sort.jl")
include("Cells.jl")
include("Plot.jl")

end # module
