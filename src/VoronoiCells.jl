module VoronoiCells

import VoronoiDelaunay
import VoronoiDelaunay: getx, gety, geta, getb, getgena, getgenb

export
	# Types
	IndexablePoint2D,
	Tessellation,

	# Functions
	voronoicells,
	voronoiarea,
	polyarea,
	clip,
	density,
	large2small,
	small2large

include("Types.jl")
include("Area.jl")
include("Clipping.jl")
include("Corners.jl")
include("Density.jl")
include("Misc.jl")

end # module
