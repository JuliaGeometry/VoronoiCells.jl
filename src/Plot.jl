function sides(tess::Tessellation)
    n_points = mapreduce(length, +, tess.Cells)
    sides = Vector{GeometryBasics.Line}(undef, n_points)

    count = 0
    for cell in tess.Cells
        n_corners = length(cell)
        for n in 2:n_corners
            count += 1
            # Ignore orientation of line
            p1, p2 = minmax(cell[n-1], cell[n])
            sides[count] = GeometryBasics.Line(p1, p2)
        end

        count += 1
        sides[count] = GeometryBasics.Line(cell[n_corners], cell[1])
    end

    unique(sides)
end


function corner_coordinates(tess::Tessellation)
    lines = sides(tess)
    n_sides = length(lines)
    x = Vector{Float64}(undef, 3*n_sides)
    y = similar(x)

    count = 0
    for l in lines
        count += 1
        x[count] = getx(l[1])
        y[count] = gety(l[1])

        count += 1
        x[count] = getx(l[2])
        y[count] = gety(l[2])

        count += 1
        x[count] = NaN
        y[count] = NaN
    end

    return x, y
end


@recipe function plot(tess::Tessellation)
    @series begin
        seriestype --> :path
        # seriescolor --> "blue"
        label --> "Voronoi cells"
  
        corner_coordinates(tess)
    end

    @series begin
        xlims --> (left(tess.EnclosingRectangle), right(tess.EnclosingRectangle))
        ylims --> (lower(tess.EnclosingRectangle), upper(tess.EnclosingRectangle))
        markershape --> :circle
        markersize --> 6
        seriestype --> :scatter
        label --> "generators"

        tess.Generators
    end
end

