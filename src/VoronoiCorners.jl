module VoronoiCorners

using VoronoiDelaunay
import VoronoiDelaunay: getx, gety, getgena, getgenb

export
	# Types
	IndexablePoint2D,
	IndexedPolygon,

	# Functions
	corners,
	voronoiarea,
	polyarea,
	density

include("Types.jl")
include("Clipping.jl")
include("Corners.jl")
include("Area.jl")
#include("Density.jl")

end # module
