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
