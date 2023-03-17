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


function raw_tesselation(pc::PointCollection; edges=nothing, rng = Xoshiro())
    n_points = length(pc.OriginalPoints)

    generators = VoronoiDelaunay.DelaunayTessellation2D{IndexablePoint2D}(n_points)
    # Note that, without a seeded RNG, the elements of pc.TransformedPoints are reordered by VoronoiDelaunay
    push!(generators, pc.TransformedPoints, rng)

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

    if edges !== nothing 
        for edge in VoronoiDelaunay.delaunayedges(generators)
            src = VoronoiDelaunay.geta(edge) |> getindex
            dst = VoronoiDelaunay.getb(edge) |> getindex
            if src > dst # order 
                src,dst = dst,src
            end   
            push!(edges, (src,dst))
        end
    end 

    voronoi_cells
end


struct Tessellation{T}
    Generators::Vector{T}
    EnclosingRectangle::Rectangle{T}
    Cells::Vector{Vector{T}}
end


Base.eltype(::Tessellation{T}) where T = T


function voronoicells(pc::PointCollection{T}; edges=nothing, rng = Xoshiro()) where T
    rt = raw_tesselation(pc; edges, rng)

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
    voronoicells(points, rect; [edges]) -> Tessellation

Compute the Voronoi cells with the vector of generators `points` in the rectangle `rect`.

The optional `edges` input allows one to record the Delaunay edges of the tesselation. 
Each edge of the Delaunay graph is pushed onto the edge list using: 
    `push!(edges, (src,dst))` 
so the type must be able to support this operation, such as `Vector{Tuple{Int,Int}}()`. 
This edge set may show additional edges due to boundary effects. 
"""
function voronoicells(points, rect; kwargs...)
    pc = PointCollection(points, rect)
    voronoicells(pc; kwargs...)
end


function voronoicells(x::Vector, y::Vector, rect; kwargs...)
    n = length(x)
    if n != length(y)
        throw(ArgumentError("x and y must have equal length"))
    end

    points = [GeometryBasics.Point2(x[i], y[i]) for i in 1:n]
    voronoicells(points, rect; kwargs...)
end
