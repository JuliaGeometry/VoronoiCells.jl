function corner_coordinates(tess::Tessellation)
    # Each cell needs the number of points + line from last to first point + NaN
    n_points = mapreduce(x -> length(x) + 2, +, tess.Cells)
    p = Vector{eltype(tess)}(undef, n_points)

    count = 0
    for cell in tess.Cells
        for corner in cell
            count += 1
            p[count] = corner
        end

        count += 1
        p[count] = cell[1]
        
        count += 1
        p[count] = GeometryBasics.Point2(NaN, NaN)
    end

    return p
end


@recipe function plot(tess::Tessellation)
    @series begin
        xlims --> (left(tess.EnclosingRectangle), right(tess.EnclosingRectangle))
        ylims --> (lower(tess.EnclosingRectangle), upper(tess.EnclosingRectangle))
        seriestype --> :path
        label --> "Voronoi cells"
  
        corner_coordinates(tess)
    end

    # @series begin
    #     xlims --> (left(tess.EnclosingRectangle), right(tess.EnclosingRectangle))
    #     ylims --> (lower(tess.EnclosingRectangle), upper(tess.EnclosingRectangle))
    #     markershape --> :circle
    #     markersize --> 6
    #     seriestype --> :scatter
    #     label --> "generators"

    #     tess.Generators
    # end
end

