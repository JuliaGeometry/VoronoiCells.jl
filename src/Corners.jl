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
	quadrant(edge::VoronoiDelaunay.VoronoiEdge{IndexablePoint2D})

Get the quadrant number of the generators of `edge`.

The quadrants are numbered in the usual way, starting with 1 in the upper 
right and consecutively with positive orientation:

- 1 is the upper right
- 2 is the upper left
- 3 is the lower left
- 4 is the lower right
"""->
function quadrant(p::AbstractPoint2D)
	# TODO: Save as a const
	islow = gety(p) < 0.5*(LOWER+UPPER)
	isleft = getx(p) < 0.5*(LEFT+RIGHT)

	if !islow && !isleft
		Q = 1
	elseif !islow && isleft
		Q = 2
	elseif islow && isleft
		Q = 3
	elseif islow && !isleft
		Q = 4
	end

	return Q
end

@doc """
"""->
function newneighbor!(NB::Neighbors, gen::Integer, p::Integer)
	if haskey( NB, gen )
		# Add p to the list of neighbors, if it isn't there already
		if findfirst( NB[gen], p ) == 0
			push!( NB[gen], p )
		end
	else
		NB[gen] = [p]
	end
end

@doc """
Update neighbors of `gena` with `genb`.
"""->
function newneighbor!(NB::Neighbors, edge::VoronoiDelaunay.VoronoiEdge{IndexablePoint2D})
	if isoutside(edge)
		return nothing
	end

	# Window corners
	gena = getgena(edge)
	gena_index = getindex(gena)
	if gena_index == -1
		gena_index = -quadrant(gena)
	end

	genb = getgenb(edge)
	genb_index = getindex(genb)
	if genb_index == -1
		genb_index = -quadrant(genb)
	end

	newneighbor!(NB, gena_index, genb_index)
	newneighbor!(NB, genb_index, gena_index)
end

@doc """
	newedge!(corners::Tessellation, edge::VoronoiEdge)

Update `corners` with the corners of `edge`.
See also `newcorner!`.
"""->
function newedge!(corners::Tessellation, edge::VoronoiDelaunay.VoronoiEdge{IndexablePoint2D})
	# TODO: Import edge type?

	# Clip edge to bounding box
	A = geta(edge)
	B = getb(edge)
	if !isinside(A) || !isinside(B)
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
	# VoronoiDelaunay data structure
	Ngen = length(generators)
	tess = DelaunayTessellation2D{IndexablePoint2D}(Ngen)
	push!(tess, generators)

	# Initialize output
	corners = Tessellation()
	sizehint!(corners, Ngen+1)
	neighbors = Neighbors()
	sizehint!(neighbors, Ngen+4)

	for edge in voronoiedges(tess)
		newedge!(corners, edge)
		newneighbor!(neighbors, edge)
	end

	return corners, neighbors
end

@doc """
Remove the bounding window corners and update the bordering cells in `corners`.
"""->
function removecorner!(corners::Tessellation, neighbors::Neighbors)
	pop!(corners, -1)
end

#=
Find the new tesselation for corners and the generators bordering them.
This gives new corners for the border cells. Simply add these
corners to the bordering cells and update the cells afterwards:
If two points (in a sorted cell) lie on a straight line, then remove the
middle point. 3 points are on a straight line if there is equality in
the triangle inequality.
=#

