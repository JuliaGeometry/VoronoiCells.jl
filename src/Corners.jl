@doc """
	isapprox(a::AbstractPoint2D, b::AbstractPoint2D) -> Bool

Test if the two points `a` and `b` are approximately equal in the `l1`-norm.
"""->
function Base.isapprox(a::AbstractPoint2D, b::AbstractPoint2D)
	isapprox(getx(a), getx(b)) && isapprox(gety(a), gety(b))
end

@doc """
	contains(p::AbstractPoint2D, pts::AbstractPoint2D) -> Bool

Test if the point `p` is in the list of points `pts`.
"""->
function Base.contains{T<:AbstractPoint2D}(pts::Vector{T}, p::AbstractPoint2D)
	for element in pts
		if isapprox(p, element)
			return true
		end
	end
	return false
end

@doc """
	newcorner!(polygon::Tessellation, generator::IndexablePoint2D, corner::Point2D)

Update `polygon` with a new `corner` of the cell belonging to a particular `generator`.
If `generator` is already in `polygon`, the entry in `polygon` is updated with `corner` and otherwise a new cell is added.
"""->
function newcorner!(polygon::Tessellation, generator::IndexablePoint2D, corner::AbstractPoint2D)
	index = getindex(generator)

	if haskey( polygon, index )
		if !contains(polygon[index], corner)
			push!( polygon[index], corner )
		end
	else
		polygon[index] = [ corner ]
	end
end

@doc """
	newedge!(corners::Tessellation, edge::VoronoiEdge)

Update `corners` with the corners of `edge`.
See also `newcorner!`.
"""->
function newedge!(corners::Tessellation, edge::VoronoiDelaunay.VoronoiEdge{IndexablePoint2D})
	# TODO: Import edge type?

	# Clip edge to bounding box
	A = small2large(geta(edge))
	B = small2large(getb(edge))
	if !isinside(A) || !isinside(B)
		# TODO: Use isoutside
		A, B = clip(A, B)
		if isa(A,Void) || isa(B,Void)
			return nothing
		end
	end

	generator = getgena(edge)
	newcorner!(corners, generator, A)
	newcorner!(corners, generator, B)

	generator = getgenb(edge)
	newcorner!(corners, generator, A)
	newcorner!(corners, generator, B)
end

@doc """
	corners(generators::IndexablePoints2D) -> Tessellation

Collect the Voronoi cells from a set of `generators`.
"""->
function corners(generators::IndexablePoints2D)
	# Transform points to the middle square
	tgen = large2small(generators)

	# VoronoiDelaunay data structure
	Ngen = length(tgen)
	tess = DelaunayTessellation2D{IndexablePoint2D}(Ngen)
	push!(tess, tgen)

	# Initialize output
	corn = Tessellation()
	sizehint!(corn, Ngen)

	Q = Dict{Int64, Vector{Int64}}(1=>[],2=>[],3=>[],4=>[])

	for edge in voronoiedges(tess)
		newedge!(corn, edge)

		quadrant!(Q, edge)
	end

	# Add corners of bounding box
	sort!(generators, by=getindex)
	for q in 1:4
		D = Inf
		BCidx = -1
		for idx in Q[q]
			DD = dist_squared(BC[q], generators[idx])
			if DD < D
				D = DD
				BCidx = idx
			end
		end
		newcorner!(corn, generators[BCidx], BC[q])
	end

	return corn, Q
end

@doc """
Find the indices of the points whose cell border a spurious corner cell.

This function may include too many points, but it is not of importance for the performance.
"""->
function quadrant!{T<:AbstractPoint2D}(Q::Dict{Int64, Vector{Int64}}, edge::VoronoiDelaunay.VoronoiEdge{T})
	if isoutside(edge)
		return nothing
	end

	gena = getgena(edge)
	genb = getgenb(edge)
	if getindex(gena) == -1
		q = quadrant(gena)
		push!(Q[q], getindex(genb))
	end
	if getindex(genb) == -1
		q = quadrant(genb)
		push!(Q[q], getindex(gena))
	end
end


function large2small(p::IndexablePoint2D)
	IndexablePoint2D( 0.5*getx(p)+0.75, 0.5*gety(p)+0.75, getindex(p) )
end

function large2small(pts::Vector{IndexablePoint2D})
	[large2small(p) for p in pts]
end

function small2large(p::Point2D)
	Point2D( 2.0*getx(p)-1.5, 2.0*gety(p)-1.5 )
end

#= function small2large(pts::Vector{Point2D}) =#
#= 	[small2large(p) for p in pts] =#
#= end =#

