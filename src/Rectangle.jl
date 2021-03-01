# GeometryBasics' HyperRectangle seems cumbersome to index for specific points.
# And I also need to handle points from VoronoiDelaunay
struct Rectangle{T}
    LowerLeft::T
    UpperRight::T

    function Rectangle(p1::T, p2::T) where T
        left, right = minmax(getx(p1), getx(p2))
        lower, upper = minmax(gety(p1), gety(p2))

        if left >= right || lower >= upper
            throw(ArgumentError("Empty rectangle"))
        end

        lower_left = T(left, lower)
        upper_right = T(right, upper)

        new{T}(lower_left, upper_right)
    end
end


function Rectangle(p1::GeometryBasics.Point2{T}, p2::GeometryBasics.Point2{T}) where T <: Integer
    Rectangle(float.(p1), float.(p2))
end


Base.eltype(::Rectangle{T}) where T = T


left(rect::Rectangle) = getx(rect.LowerLeft)
right(rect::Rectangle) = getx(rect.UpperRight)
lower(rect::Rectangle) = gety(rect.LowerLeft)
upper(rect::Rectangle) = gety(rect.UpperRight)


upper_right(rect::Rectangle{T}) where T = rect.UpperRight
upper_left(rect::Rectangle{T}) where T = T(left(rect), upper(rect))
lower_right(rect::Rectangle{T}) where T = T(right(rect), lower(rect))
lower_left(rect::Rectangle{T}) where T = rect.LowerLeft


function area(rect::Rectangle)
    (right(rect) - left(rect)) * (upper(rect) - lower(rect))
end


"""
    corner_nearest_neighbor(points, rect)

For each corner in the rectangle `rect`, find the point(s) in `points` that are closest.
The result is a `Dict` where keys are `rect`'s corners and the values are the nearest neighbors.
"""
function corner_nearest_neighbor(points, rect)
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


function corners(rect)
    [upper_right(rect), upper_left(rect), lower_left(rect), lower_right(rect)]
end


@inline function isinside(point, rect)
    isinside_x = left(rect) <= getx(point) <= right(rect)
    isinside_y = lower(rect) <= gety(point) <= upper(rect)

    isinside_x && isinside_y
end


function map_to_computation_rectangle(points::Vector{T}, from::Rectangle{T}, to::Rectangle) where T
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
            offsetx_to + (getx(point) - offsetx_from) * slopex,
            offsety_to + (gety(point) - offsety_from) * slopey,
            index
        )
    end

    return transformed_points
end


function map_rectangle(points::Vector{T}, from::Rectangle{T}, to::Rectangle{S}) where T where S
    offsetx_from = left(from)
    offsety_from = lower(from)

    offsetx_to = left(to)
    offsety_to = lower(to)

    slopex = (right(to) - left(to)) / (right(from) - left(from))
    slopey = (upper(to) - lower(to)) / (upper(from) - lower(from))

    no_points = length(points)
    transformed_points = Vector{S}(undef, no_points)
    for (index, point) in enumerate(points)
        if !isinside(point, from)
            throw(error("Point is not inside rectangle"))
        end

        transformed_points[index] = S(
            offsetx_to + (getx(point) - offsetx_from) * slopex,
            offsety_to + (gety(point) - offsety_from) * slopey
        )
    end

    return transformed_points
end
