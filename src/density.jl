@doc """
"""->
function dist_squared(p::AbstractPoint2D, q::AbstractPoint2D)
#= function dist_squared(A::Point2D, B::Point2D) =#
	(getx(p)-getx(q))^2 + (gety(p)-gety(q))^2 
end


@doc """
"""->
function density(generators::IndexablePoints2D)
	Ngen = length(generators)
	tess = DelaunayTessellation2D{IndexablePoint}(Ngen)
	#= tess = DelaunayTessellation2D(Ngen) =#
	push!(tess, generators)

	dens = 0.0
	for edge in voronoiedges(tess)
		# End points of edge (intersected with bounding box)
		A = geta(edge)
		B = getb(edge)
		if !isinside(A) || !isinside(B)
			A, B = bounding_intersect(A, B)
		end

		P = getgena(edge)
		#= dist1 = dist( A, P ) =#
		#= dist2 = dist( B, P ) =#
		#= dens = max( dens, dist1, dist2 ) =#

		#= dens = max( dens, dist_squared(A,P) ) =#
		#= dens = max( dens, dist_squared(B,P) ) =#

		#= @show dist_squared(A,P) =#
		#= @show dist_squared(B,P) =#
		dens = max( dens, dist_squared(A,P), dist_squared(B,P) )
	end

	return sqrt(dens)
end

function density(x::Vector, y::Vector)
	@assert (N = length(x)) == length(y)

	p = [IndexablePoint(x[n], y[n], n) for n=1:N]
	density(p)
end

