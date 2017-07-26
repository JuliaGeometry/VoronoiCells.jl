"""
	density(pts::IndexablePoints2D) -> Real

Here density is defined as the minimum radius of a covering of
the GeometricalPredicates region with equal-sized balls centered at the 
points in `pts`.

By definition of the Voronoi tesselation this radius is the maximum
distance from a Voronoi cell vertix to its generator.
"""
function density(generators::IndexablePoints2D)
	corn = voronoicells(generators)
	density(generators, corn)
end

function density(generators::IndexablePoints2D, corners::Tessellation)
	sort!(generators, by=getindex)
	dens = 0.0

	for idx in keys(corners)
		gen = generators[idx]
		for C in corners[idx]
			dens = max(dens, dist_squared(gen,C))
		end
	end

	return sqrt(dens)
end

"""
	density(x::Vector, y::Vector; rw) -> Real

Compute the density for points with coordinates `x` and `y` in the window `rw`.

The vector `rw` specifies the boundary rectangle as `[xmin, xmax, ymin, ymax]`.
By default, `rw` is the unit rectangle.
"""
function density(x::AbstractVector{<:Real}, 
				 y::AbstractVector{<:Real}, 
				 rw::Vector{Float64}=[0.0;1.0;0.0;1.0])
	pts, SCALEX, SCALEY = fit2boundingbox(x, y, rw)

	density(pts) * sqrt(SCALEX*SCALEY)
end

