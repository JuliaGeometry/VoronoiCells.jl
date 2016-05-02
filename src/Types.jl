immutable IndexablePoint2D <: AbstractPoint2D
    _x::Float64
    _y::Float64
    index::Int64
end
IndexablePoint2D(x::Float64,y::Float64) = IndexablePoint2D(x,y,-1)

getx(p::IndexablePoint2D) = p._x
gety(p::IndexablePoint2D) = p._y
Base.getindex(p::IndexablePoint2D) = p.index

typealias AbstractPoints2D Vector{AbstractPoint2D}
typealias IndexablePoints2D Vector{IndexablePoint2D}
typealias Points2D Vector{Point2D}
typealias IndexedPolygons Dict{Int, Points2D}

# Edges of the bounding box
const LEFT = VoronoiDelaunay.min_coord
const RIGHT = VoronoiDelaunay.max_coord
const LOWER = VoronoiDelaunay.min_coord
const UPPER = VoronoiDelaunay.max_coord

