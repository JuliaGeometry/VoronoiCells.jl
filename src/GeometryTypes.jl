struct IndexablePoint2D <: VoronoiDelaunay.AbstractPoint2D
    _x::Float64
    _y::Float64
    _index::Int64
end

function Base.abs2(A::VoronoiDelaunay.AbstractPoint2D, B::VoronoiDelaunay.AbstractPoint2D)
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

Base.:+(A::VoronoiDelaunay.AbstractPoint2D, B::VoronoiDelaunay.AbstractPoint2D) = VoronoiDelaunay.Point2D(
    getx(A) + getx(B), gety(A) + gety(B)
)
Base.:-(A::VoronoiDelaunay.AbstractPoint2D, B::VoronoiDelaunay.AbstractPoint2D) = VoronoiDelaunay.Point2D(
    getx(A) - getx(B), gety(A) - gety(B)
)
Base.:*(x::Float64, A::VoronoiDelaunay.AbstractPoint2D) = VoronoiDelaunay.Point2D(
    x * getx(A), x*gety(A)
)


function GeometryBasics.Point2(p::VoronoiDelaunay.AbstractPoint2D)
    GeometryBasics.Point(getx(p), gety(p))
end

getx(p::GeometryBasics.Point2) = p[1]
gety(p::GeometryBasics.Point2) = p[2]


# GeometryBasics' HyperRectangle seems cumbersome to index for specific points.
struct Rectangle
    Left::Float64
    Right::Float64
    Lower::Float64
    Upper::Float64

    function Rectangle(left, right, lower, upper)
        if left >= right || lower >= upper
            throw(error("Empty rectangle"))
        end

        new(left, right, lower, upper)
    end
end


function Rectangle(p1::GeometryBasics.Point2, p2::GeometryBasics.Point2)
    left = min(p1[1], p2[1])
    right = max(p1[1], p2[1])

    lower = min(p1[2], p2[2])
    upper = max(p1[2], p2[2])

    Rectangle(left, right, lower, upper)
end


left(rect::Rectangle) = rect.Left
right(rect::Rectangle) = rect.Right
lower(rect::Rectangle) = rect.Lower
upper(rect::Rectangle) = rect.Upper


@inline function isinside(point, rect)
    isinside_x = left(rect) <= getx(point) <= right(rect)
    isinside_y = lower(rect) <= gety(point) <= upper(rect)

    isinside_x && isinside_y
end


function map_rectangle(points::Vector{GeometryBasics.Point2{T}}, from::Rectangle, to::Rectangle) where T
    offsetx_from = left(from)
    offsety_from = lower(from)

    offsetx_to = left(to)
    offsety_to = lower(to)

    slopex = (right(to) - left(to)) / (right(from) - left(from))
    slopey = (upper(to) - lower(to)) / (upper(from) - lower(from))

    no_points = length(points)
    transformed_points = Vector{IndexablePoint2D}(undef, no_points)
    for (index, point) in enumerate(points)
        if !isinside(point, from)
            throw(error("Point is not inside rectangle"))
        end

        transformed_points[index] = IndexablePoint2D(
            offsetx_to + (point[1] - offsetx_from) * slopex,
            offsety_to + (point[2] - offsety_from) * slopey,
            index
        )
    end

    return transformed_points
end


function map_rectangle(points::Vector{IndexablePoint2D}, from::Rectangle, to::Rectangle) where T
    offsetx_from = left(from)
    offsety_from = lower(from)

    offsetx_to = left(to)
    offsety_to = lower(to)

    slopex = (right(to) - left(to)) / (right(from) - left(from))
    slopey = (upper(to) - lower(to)) / (upper(from) - lower(from))

    no_points = length(points)
    transformed_points = Vector{GeometryBasics.Point2{Float64}}(undef, no_points)
    for point in points
        if !isinside(point, from)
            throw(error("Point is not inside rectangle"))
        end

        index = getindex(point)
        transformed_points[index] = GeometryBasics.Point2(
            offsetx_to + (getx(point) - offsetx_from) * slopex,
            offsety_to + (gety(point) - offsety_from) * slopey
        )
    end

    return transformed_points
end
