typealias Points2D Array{GeometricalPredicates.Point2D,1}
# Hash table of Voronoi cells indexed by their generators
typealias VoronoiCorners Dict{Point2D, Points2D}

function Base.show(io::IO, C::VoronoiCorners)
	println("Generator    Corners")
	println("---------------------")

	for key in keys(C)
		@printf(io, "(%2.2f,%2.2f)  ", getx(key), gety(key) )

		for corner in C[key]
			@printf(io, "(%2.2f,%2.2f), ", getx(corner), gety(corner) )
		end
		println("\b")
	end
end


@doc """
	isapprox(a::Point2D, b::Point2D) -> Bool

Test if the two points `a` and `b` are approximately equal in the `l1`-norm.
"""->
function Base.isapprox(a::Point2D, b::Point2D)
	isapprox(getx(a), getx(b)) && isapprox(gety(a), gety(b))
end

@doc """
	contains(p::Point2D, P::Points2D) -> Bool

Test if `p` is in `P`.
"""->
function contains(p::Point2D, P::Points2D)
	for element in P
		if isapprox(p, element)
			return true
		end
	end
	return false
end

@doc """
	contains(p::Point2D, C::VoronoiCorners) -> Bool, Point2D

Test if `p` is a generator in `C`.
"""->
function contains(p::Point2D, C::VoronoiCorners)
	for key in keys(C)
		if isapprox(p, key)
			return true, key
		end
	end
	return false, p
end

@doc """
	newcorner!(corners::VoronoiCorners, generator::Point2D, corner::Point2D)

Update `corners` with a new `corner` of the cell belonging to a particular `generator`.
If `generator` is already in `VoronoiCorners`, the entry in `corners` is updated with `corner` and otherwise a new cell is added.
"""->
function newcorner!(corners::VoronoiCorners, generator::Point2D, corner::Point2D)
	# TODO: Allocate VoronoiCorners with all keys and make this check
	# obsolete
	match, key = contains( generator, corners )

	if match
		if !contains(corner, corners[key])
			push!( corners[key], corner )
		end
	else
		corners[key] = [ corner ]
	end
end

@doc """
Collect the Voronoi cells from set of `generators`.
"""->
function corners(generators::Points2D)
	Ngen = length(generators)

	# VoronoiDelaunay data structure
	tess = DelaunayTessellation(Ngen)
	push!(tess, generators)

	# Initialize output
	corners = VoronoiCorners()
	sizehint!(corners, Ngen)

	for edge in voronoiedges(tess)
		# TODO: Leave out the corners of the bounding box
		generator = getgena(edge)
		newcorner!(corners, generator, geta(edge))
		newcorner!(corners, generator, getb(edge))

		generator = getgenb(edge)
		newcorner!(corners, generator, geta(edge))
		newcorner!(corners, generator, getb(edge))
	end

	# TODO: Orientation of the polygons/cells
	return corners
end

