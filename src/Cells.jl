struct PointCollection
    OriginalPoints::Vector{GeometryBasics.Point{2,Float64}}
    EnclosingRectangle::Rectangle
    ComputationRectangle::Rectangle
    TransformedPoints::Vector{IndexablePoint2D}
end


function PointCollection(points::Vector{GeometryBasics.Point{2,Float64}}, rect)
    computation_rect = Rectangle(
        # ComputationRectangleCorners[1],
        # ComputationRectangleCorners[4],
        GeometryBasics.Point2(1.26, 1.26),
        GeometryBasics.Point2(1.74, 1.74)
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


function raw_tesselation(pc::PointCollection)
    n_points = length(pc.OriginalPoints)

    generators = VoronoiDelaunay.DelaunayTessellation2D{IndexablePoint2D}(n_points)
    # Note that the elements of pc.TransformedPoints are reordered by VoronoiDelaunay
    push!(generators, pc.TransformedPoints)

    voronoi_cells = Dict(1:n_points .=> [Vector{VoronoiDelaunay.Point2D}(undef, 0) for _ in 1:n_points])
    quadrant_neighbors = Dict(1:4 .=> [Vector{Int64}(undef, 0) for _ in 1:4])
    all_quadrant_dist = [Inf for _ in 1:4]

    for edge in VoronoiDelaunay.voronoiedges(generators)
        l = clip(edge, pc.ComputationRectangle)
        if isnothing(l)
            # # One generator is a "ghost point"
            # generator_indices = getindex.(
            #     [VoronoiDelaunay.getgena(edge), VoronoiDelaunay.getgenb(edge)]
            # )
            
            # if generator_indices[1] < 0
            #     quadrant_index = -generator_indices[1]
            #     generator = getgenb(edge)
            #     generator_index = generator_indices[2]
            # elseif generator_indices[2] < 0
            #     quadrant_index = -generator_indices[2]
            #     generator_index = generator_indices[1]
            #     generator = getgena(edge)
            # else
            #     continue
            # end

            # quadrant_dist = abs2(generator, BoundingBoxCorners[quadrant_index]) 

            # # Multiple points may be equally close to a ghost point
            # if quadrant_dist == all_quadrant_dist[quadrant_index]
            #     push!(quadrant_neighbors[quadrant_index], generator_index)
            # elseif quadrant_dist < all_quadrant_dist[quadrant_index]
            #     push!(quadrant_neighbors[quadrant_index], generator_index)
            #     # quadrant_neighbors[quadrant_index] = [generator_index]
            # end

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

struct Tessellation
    Generators::Vector{GeometryBasics.Point{2,Float64}}
    EnclosingRectangle::Rectangle
    Cells::Vector{Vector{GeometryBasics.Point{2,Float64}}}
end

function voronoicells(pc::PointCollection)
    rt = raw_tesselation(pc)

    for n in 1:4
        nn = nearest_neighbor(ComputationRectangleCorners[n], pc.TransformedPoints)
        for m in nn
            tp_index = getindex(pc.TransformedPoints[m])
            push!(rt.VoronoiCells[tp_index], ComputationRectangleCorners[n])
        end
    end

    n_cells = length(rt.VoronoiCells)
    cells = [Vector{GeometryBasics.Point2{Float64}}(undef, 0) for _ in 1:n_cells]
    for n in 1:n_cells
        cell_corners = unique(rt.VoronoiCells[n])

        cells[n] = map_rectangle(cell_corners, rt.ComputationRectangle, rt.EnclosingRectangle)
    end

    Tessellation(pc.OriginalPoints, pc.EnclosingRectangle, cells)
end



# function quadrant_neighbors(points::Vector{T}) where T <: VoronoiDelaunay.AbstractPoint2D
function quadrant_neighbors(pc::PointCollection)
    points = pc.TransformedPoints
    qn = Dict(1:4 .=> [Vector{Int64}(undef, 0) for _ in 1:4])
    quadrant_dists = [Inf for _ in 1:4]
    for (index, point) in enumerate(points)
            # @show point
        for n in 1:4
            # @show dist_to_corner = abs2(point, pc.ComputationRectangle[n])
            dist_to_corner = abs2(point, ComputationRectangleCorners[n])
            if dist_to_corner == quadrant_dists[n]
                push!(qn[n], index)
            elseif dist_to_corner < quadrant_dists[n]
                qn[n] = [index]
                # push!(qn[n], index)
                quadrant_dists[n] = dist_to_corner
            end
        end
    end

    return qn
end