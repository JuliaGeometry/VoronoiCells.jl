module VoronoiCells

using VoronoiDelaunay
import VoronoiDelaunay: getx, gety, getgena, getgenb

export
	# Types
	IndexablePoint2D,
	Tessellation,

	# Functions
	vcorners,
	voronoiarea,
	polyarea,
	clip,
	density,
	large2small,
	small2large

include("Types.jl")
include("Clipping.jl")
include("Corners.jl")
include("Area.jl")
include("Misc.jl")
include("Density.jl")

end # module
