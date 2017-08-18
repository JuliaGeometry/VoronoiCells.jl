"""
	newcorner!(corners::Tessellation, generator::IndexablePoint2D, corner::Point2D)

Update `corners` with a new `corner` of the cell belonging to a particular `generator`.
If `generator` is already in `corners`, the entry in `corners` is updated with `corner` and otherwise a new cell is added.
"""
function newcorner!(corners::Tessellation, generator::IndexablePoint2D, corner::AbstractPoint2D)
	index = getindex(generator)

	if haskey(corners, index)
		if !contains(corners[index], corner)
			push!(corners[index], corner)
		end
	else
		corners[index] = [ corner ]
	end
end

"""
	newedge!(corners::Tessellation, edge::VoronoiEdge)

Update `corners` with the corners of `edge`.
See also `newcorner!`.
"""
function newedge!(corners::Tessellation, edge::VoronoiDelaunay.VoronoiEdge{IndexablePoint2D})
	# TODO: Import edge type?

	# Clip edge to bounding box
	A = small2large(geta(edge))
	B = small2large(getb(edge))
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

"""
	voronoicells(generators::IndexablePoints2D) -> Tessellation

Collect the Voronoi cells from a set of `generators`.
"""
function voronoicells(generators::IndexablePoints2D)
	# Transform points to the middle square
	tgen = large2small(generators)

	# VoronoiDelaunay data structure
	Ngen = length(tgen)
	tess = DelaunayTessellation2D{IndexablePoint2D}(Ngen)
	push!(tess, tgen)

	# Initialize output
	corn = Tessellation()
	sizehint!(corn, Ngen)

	# Dict for indices of quadrant neighbors
	Q = Dict{Int64, Vector{Int64}}(1=>[], 2=>[], 3=>[], 4=>[])

	for edge in voronoiedges(tess)
		newedge!(corn, edge)
		quadrant!(Q, edge)
	end

	# Add corners of bounding box to corn to cor
	add_bounding_corners!(corn, generators, Q)

	return corn
end

"""
`Q` is a `Dict` with keys 1 through 4 representing the four quadrants of the bounding box.
The points with cells that border quadrant `q` are `Q[q]`.

This function may include too many points, but not so many that it is important for the performance.
"""
function quadrant!(Q::Dict{Int64, Vector{Int64}}, edge::VoronoiDelaunay.VoronoiEdge{T}) where T<:AbstractPoint2D
	# TODO: Should test if edge is outside the middle square/map edge to
	# full square. Mapping takes time and the clip functions needs to be
	# modified to test in the middle square.
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

"""
	add_bounding_corners!(corn, generators, Q)

Adds each of the quadrants to the cell in the tesselation `corn` whose generator is closest.
`Q` holds the indices of the cells that border the bounding box corners (see `quadrant!`).
"""
function add_bounding_corners!(corn::Tessellation, generators::IndexablePoints2D, Q)
	sort!(generators, by=getindex)

	for quad in keys(Q)
		gen_dist = Inf
		neighbor_index = -1
		for idx in Q[quad]
			D = dist_squared(BoxCorners[quad], generators[idx])
			if D < gen_dist
				gen_dist = D
				neighbor_index = idx
			end
		end

		newcorner!(corn, generators[neighbor_index], BoxCorners[quad])
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

