@doc """
	dist_squared(p, q) -> Real

The `l2` distance squared between the points `p` and `q`.
"""->
function dist_squared(p::AbstractPoint2D, q::AbstractPoint2D)
	(getx(p)-getx(q))^2 + (gety(p)-gety(q))^2 
end


@doc """
	density(pts::AbstractPoints2D) -> Real

Here density is defined as the minimum radius of a covering of
the GeometricalPredicates region with equal-sized balls centered at the 
points in `pts`.

By definition of the Voronoi tesselation this radius is the maximum
distance from a Voronoi cell vertix to its generator.
"""->
function density{T<:AbstractPoint2D}(pts::Vector{T})
	Ngen = length(pts)
	tess = DelaunayTessellation2D{T}(Ngen)
	push!(tess, pts)

	dens = 0.0
	for edge in voronoiedges(tess)
		# End points of edge (intersected with bounding box)
		A = geta(edge)
		B = getb(edge)
		if !isinside(A) || !isinside(B)
			A, B = clip(A, B)
		end

		P = getgena(edge)
		dens = max( dens, dist_squared(A,P), dist_squared(B,P) )
	end

	return sqrt(dens)
end

@doc """
	density(x::Vector, y::Vector; rw) -> Real

Compute the density for points with coordinates `x` and `y` in the window `rw`.

The vector `rw` specifies the boundary rectangle as `[xmin, xmax, ymin, ymax]`.
By default, `rw` is the unit rectangle.
"""->
function density{T<:Real}(x::AbstractVector{T}, y::AbstractVector{T}; rw::Vector{Float64}=[0.0;1.0;0.0;1.0])
	@assert (N = length(x)) == length(y)

	# TODO: The same scaling as in area
	p = [IndexablePoint2D(x[n], y[n], n) for n=1:N]
	density(p)
end

