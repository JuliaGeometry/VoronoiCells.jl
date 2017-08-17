struct IndexablePoint2D <: AbstractPoint2D
    _x::Float64
    _y::Float64
    _index::Int64
end
IndexablePoint2D(x::Float64, y::Float64) = IndexablePoint2D(x, y, -1)

getx(p::IndexablePoint2D) = p._x
gety(p::IndexablePoint2D) = p._y
Base.getindex(p::IndexablePoint2D) = p._index

const AbstractPoints2D = Vector{AbstractPoint2D}
const IndexablePoints2D = Vector{IndexablePoint2D}
const Points2D = Vector{Point2D}
const Tessellation = Dict{Int64, Points2D}

# Edges of the bounding box
const LEFT = VoronoiDelaunay.min_coord
const RIGHT = VoronoiDelaunay.max_coord
const LOWER = VoronoiDelaunay.min_coord
const UPPER = VoronoiDelaunay.max_coord

const MIDDLEy = 0.5*(LOWER + UPPER)
const MIDDLEx = 0.5*(LEFT + RIGHT)

const LL = Point2D(LEFT, LOWER)
const RL = Point2D(RIGHT, LOWER)
const RU = Point2D(RIGHT, UPPER)
const LU = Point2D(LEFT, UPPER)

# Corners of the bounding box ordered by quadrant
const BoxCorners = [RU; LU; LL; RL]

