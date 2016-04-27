@doc """
	isapprox(a::AbstractPoint2D, b::AbstractPoint2D) -> Bool

Test if the two points `a` and `b` are approximately equal in the `l1`-norm.
"""->
function Base.isapprox(a::AbstractPoint2D, b::AbstractPoint2D)
	isapprox(getx(a), getx(b)) && isapprox(gety(a), gety(b))
end

@doc """
	contains(p::AbstractPoint2D, Pts::AbstractPoint2D) -> Bool

Test if the point `p` is in the list of points `Pts`.
"""->
function contains{T<:AbstractPoint2D}(p::AbstractPoint2D, Pts::Vector{T})
#= function contains(p::AbstractPoint2D, Pts::AbstractPoints2D) =#
	for element in Pts
		if isapprox(p, element)
			return true
		end
	end
	return false
end

@doc """
	newcorner!(corners::VoronoiCorners, generator::Point2D, corner::Point2D)

Update `corners` with a new `corner` of the cell belonging to a particular `generator`.
If `generator` is already in `VoronoiCorners`, the entry in `corners` is updated with `corner` and otherwise a new cell is added.
"""->
function newcorner!(corners::VoronoiCorners, generator::IndexablePoint, corner::AbstractPoint2D)
	index = getindex(generator)

	if haskey( corners, index )
		if !contains(corner, corners[index])
			push!( corners[index], corner )
		end
	else
		corners[index] = [ corner ]
	end
end

@doc """
	newedge!(corners::VoronoiCorners, edge::VoronoiEdge)

Update `corners` with the corners of `edge`.
See also `newcorner!`.
"""->
function newedge!(corners::VoronoiCorners, edge::VoronoiDelaunay.VoronoiEdge{IndexablePoint})
	# TODO: Import edge type?

	# Make sure edge is inside the bounding box
	A = geta(edge)
	B = getb(edge)
	if !isinside(A) || !isinside(B)
		A, B = bounding_intersect(A, B)
	end

	generator = getgena(edge)
	newcorner!(corners, generator, A)
	newcorner!(corners, generator, B)

	generator = getgenb(edge)
	newcorner!(corners, generator, A)
	newcorner!(corners, generator, B)
end

@doc """
	corners(generators::IndexablePoints2D) -> VoronoiCorners

Collect the Voronoi cells from a set of `generators`.
"""->
function corners(generators::IndexablePoints2D)
	# VoronoiDelaunay data structure
	Ngen = length(generators)
	tess = DelaunayTessellation2D{IndexablePoint}(Ngen)
	push!(tess, generators)

	# Initialize output
	# TODO: In separate function
	corners = VoronoiCorners()
	sizehint!(corners, Ngen)

	for edge in voronoiedges(tess)
		# TODO: Leave out the corners of the bounding box
		newedge!(corners, edge)
	end

	return corners
end

