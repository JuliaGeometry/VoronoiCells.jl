struct PointCollection
    OriginalPoints::Vector{GeometryBasics.Point{2,Float64}}
    EnclosingRectangle::Rectangle
    ComputationRectangle::Rectangle
    TransformedPoints::Vector{IndexablePoint2D}
end


function PointCollection(points::Vector{GeometryBasics.Point{2,Float64}}, rect)
    computation_rect = Rectangle(
        GeometryBasics.Point2(1.25, 1.25),
        GeometryBasics.Point2(1.75, 1.75)
    )

    transformed_points = map_rectangle(points, rect, computation_rect)

    PointCollection(points, rect, computation_rect, transformed_points)
end


struct RawTessellation
    # Generators::Vector{IndexablePoint2D}
    EnclosingRectangle::Rectangle
    ComputationRectangle::Rectangle
    VoronoiCells::Dict{Int64, Vector{VoronoiDelaunay.Point2D}}
    QuadrantNeighbors::Dict{Int64, Vector{Int64}}
end


function voronoicells(pc::PointCollection)
    n_points = length(pc.OriginalPoints)

    generators = VoronoiDelaunay.DelaunayTessellation2D{IndexablePoint2D}(n_points)
    push!(generators, pc.TransformedPoints)

    voronoi_cells = Dict(1:n_points .=> [Vector{VoronoiDelaunay.Point2D}(undef, 0) for _ in 1:n_points])
    quadrant_neighbors = Dict(-4:-1 .=> [Vector{Int64}(undef, 0) for _ in 1:4])

    for edge in VoronoiDelaunay.voronoiedges(generators)
        l = clip(edge, pc.ComputationRectangle)
        if isnothing(l)
            # One generator is a "ghost point"
            generator_a = VoronoiDelaunay.getgena(edge) |> getindex
            generator_b = VoronoiDelaunay.getgenb(edge) |> getindex

            if generator_a < 0
                push!(quadrant_neighbors[generator_a], generator_b)
            end

            if generator_b < 0
                push!(quadrant_neighbors[generator_b], generator_a)
            end

            continue
        end

        # TODO: We *can* get edges with ghost endpoint. Make smaller computation_rect?
        generator_a = VoronoiDelaunay.getgena(edge) |> getindex
        generator_b = VoronoiDelaunay.getgenb(edge) |> getindex

        push!(voronoi_cells[generator_a], geta(l))
        push!(voronoi_cells[generator_a], getb(l))

        push!(voronoi_cells[generator_b], geta(l))
        push!(voronoi_cells[generator_b], getb(l))
    end

    RawTessellation(
        pc.EnclosingRectangle, pc.ComputationRectangle, voronoi_cells, quadrant_neighbors
    )
end
