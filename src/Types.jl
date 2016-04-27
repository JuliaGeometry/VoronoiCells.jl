immutable IndexablePoint <: AbstractPoint2D
    _x::Float64
    _y::Float64
    index::Int64
end
IndexablePoint(x::Float64,y::Float64) = IndexablePoint(x,y,-1)

getx(p::IndexablePoint) = p._x
gety(p::IndexablePoint) = p._y
Base.getindex(p::IndexablePoint) = p.index

typealias AbstractPoints2D Vector{AbstractPoint2D}
typealias IndexablePoints2D Vector{IndexablePoint}
typealias Points2D Vector{Point2D}
typealias IndexedPolygons Dict{Int, Points2D}

# Edges of the bounding box
const LEFT = VoronoiDelaunay.min_coord
const RIGHT = VoronoiDelaunay.max_coord
const LOWER = VoronoiDelaunay.min_coord
const UPPER = VoronoiDelaunay.max_coord

# Corners of the bounding box
const LOWERLEFT  = Point2D( LEFT, LOWER )
const LOWERRIGHT = Point2D( RIGHT, LOWER )
const UPPERRIGHT = Point2D( RIGHT, UPPER )
const UPPERLEFT  = Point2D( LEFT, UPPER )

