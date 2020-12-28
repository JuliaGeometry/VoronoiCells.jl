struct PointCollection
    OriginalPoints::Vector{GeometryBasics.Point{2,Float64}}
    EnclosingRectangle::Rectangle
    ComputationRectangle::Rectangle
    TransformedPoints::Vector{IndexablePoint2D}
    # EnclosingRectangle::GeometryBasics.HyperRectangle{2,Float64}
    # ComputationRectangle::GeometryBasics.HyperRectangle{2,Float64}
    # TransformedPoints::Vector{VoronoiDelaunay.Point2D}
end


function PointCollection(points::Vector{GeometryBasics.Point{2,Float64}}, rect)
    computation_rect = Rectangle(
        GeometryBasics.Point2(1.25, 1.25),
        GeometryBasics.Point2(1.75, 1.75)
    )

    transformed_points = map_rectangle(points, rect, computation_rect)

    PointCollection(points, rect, computation_rect, transformed_points)
end