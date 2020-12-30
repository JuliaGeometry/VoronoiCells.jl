struct IndexablePoint2D <: VoronoiDelaunay.AbstractPoint2D
    _x::Float64
    _y::Float64
    _index::Int64
end

function Base.abs2(A, B)
    abs2(getx(A) - getx(B)) + abs2(gety(A) - gety(B))
end

# TODO: We need corners in computation rectangle (as well)
const BoundingBoxCorners = [
    VoronoiDelaunay.Point2D(VoronoiDelaunay.max_coord, VoronoiDelaunay.max_coord)
    VoronoiDelaunay.Point2D(VoronoiDelaunay.min_coord, VoronoiDelaunay.max_coord)
    VoronoiDelaunay.Point2D(VoronoiDelaunay.min_coord, VoronoiDelaunay.min_coord)
    VoronoiDelaunay.Point2D(VoronoiDelaunay.max_coord, VoronoiDelaunay.min_coord)
]

function closest_quadrant(p::VoronoiDelaunay.AbstractPoint2D)
    closest_quadrant = 0
    quadrant_dist = Inf
    for n in 1:4
        dist_to_corner = abs2(p, BoundingBoxCorners[n])
        if dist_to_corner < quadrant_dist
            closest_quadrant = n
            quadrant_dist = min(quadrant_dist, dist_to_corner)
        end
    end

    return closest_quadrant
end

# IndexablePoint2D(x::Float64, y::Float64) = IndexablePoint2D(x, y, -1)
function IndexablePoint2D(x::Float64, y::Float64)
    q = closest_quadrant(VoronoiDelaunay.Point2D(x, y))
    IndexablePoint2D(x, y, -q)
end
getx(p::IndexablePoint2D) = p._x
gety(p::IndexablePoint2D) = p._y
Base.getindex(p::IndexablePoint2D) = p._index
Base.getindex(::VoronoiDelaunay.Point2D) = -1

for op in [:+, :-]
	@eval begin
		Base.$op(p::VoronoiDelaunay.AbstractPoint2D, q::VoronoiDelaunay.AbstractPoint2D) = 
        VoronoiDelaunay.Point2D($op(getx(p), getx(q)), $op(gety(p), gety(q)))
	end
end

function Base.isapprox(p::VoronoiDelaunay.AbstractPoint2D, q::VoronoiDelaunay.AbstractPoint2D)
    isapprox(getx(p), getx(q)) && isapprox(gety(p), gety(q))
end

Base.:*(a::Float64, p::VoronoiDelaunay.AbstractPoint2D) = VoronoiDelaunay.Point2D(a*getx(p), a*gety(p))



function GeometryBasics.Point2(p::VoronoiDelaunay.AbstractPoint2D)
    GeometryBasics.Point(getx(p), gety(p))
end

getx(p::GeometryBasics.Point2) = p[1]
gety(p::GeometryBasics.Point2) = p[2]
