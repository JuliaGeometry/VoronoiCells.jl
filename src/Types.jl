immutable IndexablePoint <: AbstractPoint2D
    _x::Float64
    _y::Float64
    index::Int64
end
IndexablePoint(x::Float64,y::Float64) = IndexablePoint(x,y,-1)

getx(p::IndexablePoint) = p._x
gety(p::IndexablePoint) = p._y
getindex(p::IndexablePoint) = p.index

typealias AbstractPoints2D Vector{AbstractPoint2D}
typealias IndexablePoints2D Vector{IndexablePoint}
typealias Points2D Vector{Point2D}
typealias VoronoiCorners Dict{Int, Points2D}

# Edges of the bounding box
# TODO: constants with uppercase
const left = VoronoiDelaunay.min_coord
const right = VoronoiDelaunay.max_coord
const lower = VoronoiDelaunay.min_coord
const upper = VoronoiDelaunay.max_coord

const RANGE = right - left

# Corners of the bounding box
const lowerleft  = Point2D( left, lower )
const lowerright = Point2D( right, lower )
const upperright = Point2D( right, upper )
const upperleft  = Point2D( left, upper )


function Base.show(io::IO, C::VoronoiCorners)
	println("Generator    Corners")
	println("---------------------")

	for key in keys(C)
		#= @printf(io, "(%2.2f,%2.2f)  ", getx(key), gety(key) ) =#
		@printf(io, "%u  ", key)

		for corner in C[key]
			@printf(io, "(%2.2f,%2.2f), ", getx(corner), gety(corner) )
		end
		println("\b")
	end
end

