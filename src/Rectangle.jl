# GeometryBasics' HyperRectangle seems cumbersome to index for specific points.
struct Rectangle{T}
    LowerLeft::T
    UpperRight::T

    function Rectangle(p1::T, p2::T) where T
        left, right = minmax(getx(p1), getx(p2))
        lower, upper = minmax(gety(p1), gety(p2))

        lower_left = T(left, lower)
        upper_right = T(upper, right)

        new{T}(lower_left, upper_right)
    end
end

upper_right(rect::Rectangle{T}) where T = T(getx(rect.UpperRight), gety(rect.UpperRight))
upper_left(rect::Rectangle{T}) where T = T(getx(rect.LowerLeft), gety(rect.UpperRight))
lower_right(rect::Rectangle{T}) where T = T(getx(rect.UpperRight), gety(rect.LowerLeft))
lower_left(rect::Rectangle{T}) where T = T(getx(rect.LowerLeft), gety(rect.LowerLeft))

left(rect::Rectangle) = getx(lower_left(rect))
right(rect::Rectangle) = getx(upper_right(rect))
lower(rect::Rectangle) = gety(lower_left(rect))
upper(rect::Rectangle) = gety(upper_right(rect))

# center(rect::Rectangle) = rect.Center

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


function corner_nearest_neighbor(points::Vector{T}, rect::Rectangle) where T
    # @show rect_corners = corners(rect)
    rect_corners = corners(rect)
    neighbors = Dict(1:4 .=> [Vector{Int64}(undef, 0)])
    corner_distances = [Inf for _ in 1:4]

    for (index, point) in enumerate(points)
        # @show index, point
        for corner_index in 1:4
            # @show corner_dist = abs2(point, rect_corners[corner_index])
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
