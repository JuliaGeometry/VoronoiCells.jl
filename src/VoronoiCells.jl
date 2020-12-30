module VoronoiCells

import GeometryBasics
import VoronoiDelaunay
import VoronoiDelaunay: getx, gety, geta, getb, getgena, getgenb

export
    PointCollection,
    Rectangle,

    map_rectangle,
    voronoicells


include("Rectangle.jl")
include("Points.jl")
include("Clipping.jl")
include("Sort.jl")
include("Cells.jl")

end # module
