struct PointCollection{T}
    OriginalPoints::Vector{T}
    EnclosingRectangle::Rectangle{T}
    ComputationRectangle::Rectangle{VoronoiDelaunay.Point2D}
    TransformedPoints::Vector{IndexablePoint2D}
    CornerNeighbors::Dict{Int64, Vector{Int64}}
end


function PointCollection(points, rect)
    corner_neighbors = corner_nearest_neighbor(points, rect)

    rect_width = right(rect) - left(rect)
    rect_height = upper(rect) - lower(rect)

    # Scale height and width such that the maximum is 1
    m = max(rect_width, rect_height)
    scaled_width = rect_width/m
    scaled_height = rect_height/m

    # Keep aspect ratio of original rectangle in the computation rectangle
    computation_rect = Rectangle(
        VoronoiDelaunay.Point2D(1.5 - 1/6*scaled_width, 1.5 - 1/6*scaled_height),
        VoronoiDelaunay.Point2D(1.5 + 1/6*scaled_width, 1.5 + 1/6*scaled_height)
    )

    transformed_points = map_to_computation_rectangle(points, rect, computation_rect)

    PointCollection(points, rect, computation_rect, transformed_points, corner_neighbors)
end


function raw_tesselation(pc::PointCollection)
    n_points = length(pc.OriginalPoints)

    generators = VoronoiDelaunay.DelaunayTessellation2D{IndexablePoint2D}(n_points)
    # Note that the elements of pc.TransformedPoints are reordered by VoronoiDelaunay
    push!(generators, pc.TransformedPoints)

    voronoi_cells = Dict(1:n_points .=> [Vector{VoronoiDelaunay.Point2D}(undef, 0) for _ in 1:n_points])

    for edge in VoronoiDelaunay.voronoiedges(generators)
        l = clip(edge, pc.ComputationRectangle)
        if isnothing(l)
            continue
        end

        generator_a = VoronoiDelaunay.getgena(edge) |> getindex
        generator_b = VoronoiDelaunay.getgenb(edge) |> getindex

        a = VoronoiDelaunay.geta(l)
        b = VoronoiDelaunay.getb(l)

        push!(voronoi_cells[generator_a], a)
        push!(voronoi_cells[generator_a], b)

        push!(voronoi_cells[generator_b], a)
        push!(voronoi_cells[generator_b], b)
    end

    voronoi_cells
end


struct Tessellation{T}
    Generators::Vector{T}
    EnclosingRectangle::Rectangle{T}
    Cells::Vector{Vector{T}}
end


Base.eltype(::Tessellation{T}) where T = T


function voronoicells(pc::PointCollection{T}) where T
    rt = raw_tesselation(pc)

    computation_corners = corners(pc.ComputationRectangle)
    for (corner_index, corner) in enumerate(computation_corners)
        corner_neighbors = pc.CornerNeighbors[corner_index]
        for neighbor_index in corner_neighbors
            push!(rt[neighbor_index], corner)
        end
    end

    n_cells = length(rt)
    cells = [Vector{T}(undef, 0) for _ in 1:n_cells]
    for n in 1:n_cells
        cell_corners = unique(rt[n])

        unsorted_cell_corners = map_rectangle(
            cell_corners, pc.ComputationRectangle, pc.EnclosingRectangle
        )
        cells[n] = sort(unsorted_cell_corners)
    end

    Tessellation(pc.OriginalPoints, pc.EnclosingRectangle, cells)
end


"""
    voronoicells(points, rect) -> Tessellation

Compute the Voronoi cells with the vector of generators `points` in the rectangle `rect`.
"""
function voronoicells(points, rect)
    pc = PointCollection(points, rect)
    voronoicells(pc)
end


function voronoicells(x::Vector, y::Vector, rect)
    n = length(x)
    if n != length(y)
        throw(ArgumentError("x and y must have equal length"))
    end

    points = [GeometryBasics.Point2(x[i], y[i]) for i in 1:n]
    voronoicells(points, rect)
end
