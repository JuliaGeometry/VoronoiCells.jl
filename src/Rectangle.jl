# GeometryBasics' HyperRectangle seems cumbersome to index for specific points.
struct Rectangle
    Left::Float64
    Right::Float64
    Lower::Float64
    Upper::Float64

    Center::GeometryBasics.Point2{Float64}

    UpperRightCorner::GeometryBasics.Point2{Float64}
    UpperLeftCorner::GeometryBasics.Point2{Float64}
    LowerLeftCorner::GeometryBasics.Point2{Float64}
    LowerRightCorner::GeometryBasics.Point2{Float64}

    function Rectangle(left, right, lower, upper)
        if left >= right || lower >= upper
            throw(ArgumentError("Empty rectangle"))
        end

        center = GeometryBasics.Point2(0.5*(left + right), 0.5*(lower + upper))

        ur = GeometryBasics.Point2(right, upper)
        ul = GeometryBasics.Point2(left, upper)
        ll = GeometryBasics.Point2(left, lower)
        lr = GeometryBasics.Point2(right, lower)

        new(left, right, lower, upper, center, ur, ul, ll, lr)
    end
end


function Rectangle(p1::GeometryBasics.Point2, p2::GeometryBasics.Point2)
    left, right = minmax(p1[1], p2[1])
    lower, upper = minmax(p1[2], p2[2])

    Rectangle(left, right, lower, upper)
end


left(rect::Rectangle) = rect.Left
right(rect::Rectangle) = rect.Right
lower(rect::Rectangle) = rect.Lower
upper(rect::Rectangle) = rect.Upper

center(rect::Rectangle) = rect.Center

upper_right(rect::Rectangle) = rect.UpperRightCorner
upper_left(rect::Rectangle) = rect.UpperLeftCorner
lower_right(rect::Rectangle) = rect.LowerRightCorner
lower_left(rect::Rectangle) = rect.LowerLeftCorner


# function nearest_corner(point, rect)
#     rect_center = center(rect)

#     if getx(point) >= getx(rect_center)
#         if gety(point) >= gety(rect_center)
#             return 1
#         else
#             return 4
#         end
#     else
#         if gety(point) >= gety(rect_center)
#             return 2
#         else
#             return 3
#         end
#     end
# end


function corner_nearest_neighbor(points::Vector{T}, rect::Rectangle) where T <: GeometryBasics.Point2
    rect_corners = corners(rect)
    neighbors = Dict(1:4 .=> [Vector{Int64}(undef, 0)])
    corner_distances = [Inf for _ in 1:4]

    for (index, point) in enumerate(points)
        for corner_index in 1:4
            corner_dist = abs2(point, rect_corners[corner_index])

            if corner_dist ≈ corner_distances[corner_index]
                push!(neighbors[corner_index], index)
            elseif corner_dist < corner_distances[corner_index]
                corner_distances[corner_index] = corner_dist
                neighbors[corner_index] = [index]
            end
        end

    end

    return neighbors
end

function corners(rect::Rectangle)
    [upper_right(rect), upper_left(rect), lower_left(rect), lower_right(rect)]
end


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


# TODO: Obsolete with the method below for AbstractPoint2D?
function map_rectangle(points::Vector{IndexablePoint2D}, from::Rectangle, to::Rectangle)
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


function map_rectangle(points::Vector{T}, from::Rectangle, to::Rectangle) where T <: VoronoiDelaunay.AbstractPoint2D
    offsetx_from = left(from)
    offsety_from = lower(from)

    offsetx_to = left(to)
    offsety_to = lower(to)

    slopex = (right(to) - left(to)) / (right(from) - left(from))
    slopey = (upper(to) - lower(to)) / (upper(from) - lower(from))

    no_points = length(points)
    transformed_points = Vector{GeometryBasics.Point2{Float64}}(undef, no_points)
    for (index, point) in enumerate(points)
        if !isinside(point, from)
            throw(error("Point is not inside rectangle"))
        end

        transformed_points[index] = GeometryBasics.Point2(
            offsetx_to + (getx(point) - offsetx_from) * slopex,
            offsety_to + (gety(point) - offsety_from) * slopey
        )
    end

    return transformed_points
end
