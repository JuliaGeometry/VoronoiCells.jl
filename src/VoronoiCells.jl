module VoronoiCells

import GeometryBasics
import VoronoiDelaunay
import VoronoiDelaunay: getx, gety, geta, getb, getgena, getgenb

export
    Rectangle,
    PointCollection,

    map_rectangle


include("GeometryTypes.jl")
include("Points.jl")

end # module
