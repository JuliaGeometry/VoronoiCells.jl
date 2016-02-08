typealias Points2D Array{VoronoiDelaunay.Point2D,1}
# Hash table of Voronoi cells indexed by their generators
typealias VoronoiCorners Dict{Point2D, Points2D}

# Edges of the bounding box
const left = VoronoiDelaunay.min_coord
const right = VoronoiDelaunay.max_coord
const lower = VoronoiDelaunay.min_coord
const upper = VoronoiDelaunay.max_coord

# Corners of the bounding box
const lowerleft  = Point2D( VoronoiDelaunay.min_coord, VoronoiDelaunay.min_coord )
const lowerright = Point2D( VoronoiDelaunay.max_coord, VoronoiDelaunay.min_coord )
const upperright = Point2D( VoronoiDelaunay.max_coord, VoronoiDelaunay.max_coord )
const upperleft  = Point2D( VoronoiDelaunay.min_coord, VoronoiDelaunay.max_coord )


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

Test if the point `p` is in the list of points `P`.
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
	corners(generators::Points2D) -> VoronoiCorners

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
		#= if !is_bounding_corner(generator) =#
			newcorner!(corners, generator, geta(edge))
			newcorner!(corners, generator, getb(edge))
		#= end =#

		generator = getgenb(edge)
		#= if !is_bounding_corner(generator) =#
			newcorner!(corners, generator, geta(edge))
			newcorner!(corners, generator, getb(edge))
		#= end =#
	end

	# TODO: Orientation of the polygons/cells
	return corners
end

@doc """
	is_bounding_corner(p::Point2D) -> Bool

Test if `p` is a corner in the bounding box.
"""->
function is_bounding_corner(p::Point2D)
	# TODO: test == or isapprox?
	isapprox(p, lowerleft) || isapprox(p, lowerright) || isapprox(p, upperleft) || isapprox(p, upperright)
end

@doc """
	isvertical(gena::Point2D, genb::Point2D)

Test if line segment with endpoints `gena` and `genb` is vertical.
"""->
function isvertical(gena::Point2D, genb::Point2D)
	isapprox( getx(gena), getx(genb) )
end

@doc """
	ishorizontal(gena::Point2D, genb::Point2D)

Test if line segment with endpoints `gena` and `genb` is horizontal.
"""->
function ishorizontal(gena::Point2D, genb::Point2D)
	isapprox( gety(gena), gety(genb) )
end

@doc """
	intersection(edge::Symbol, gena::Point2D, genb::Point2D) -> Point2D

Compute the intersection point between a line of the boundary box and the line segment with endpoints `gena` and `genb`.

`edge` can be `:left`, `:right`, `:lower` or `:upper`.
"""->
function intersection(edge::Symbol, gena::Point2D, genb::Point2D)
	if edge == :lower
		yvalue = VoronoiDelaunay.min_coord
		xvalue = xintersection(yvalue, gena, genb)
	elseif edge == :upper
		yvalue = VoronoiDelaunay.max_coord
		xvalue = xintersection(yvalue, gena, genb)
	elseif edge == :left
		xvalue = VoronoiDelaunay.min_coord
		yvalue = yintersection(xvalue, gena, genb)
	elseif edge == :right
		xvalue = VoronoiDelaunay.max_coord
		yvalue = yintersection(xvalue, gena, genb)
	else
		error("Edge must be :left, :right, :lower or :upper")
	end

	return Point2D(xvalue,yvalue)
end

@doc """
	xintersection(yvalue::Float64, gena::Point2D, genb::Point2D) -> x

Compute the `x`-value of the intersection between the horizontal line `y=yvalue` and the straight line through `gena` and `genb`.
"""->
function xintersection(yvalue::Float64, gena::Point2D, genb::Point2D)
	if isvertical(gena,genb)
		# @assert !isapprox(gena,genb) "Supply two different points"
		xvalue = getx(gena)
	else
		slope, intersect = line(gena,genb)
		xvalue = (yvalue - intersect)/slope
	end

	return xvalue
end

@doc """
	yintersection(xvalue::Float64, gena::Point2D, genb::Point2D) -> y

Compute the `y`-value of the intersection between the vertical line `x=xvalue` and the (non-vertical) straight line through `gena` and `genb`.
"""->
function yintersection(xvalue::Float64, gena::Point2D, genb::Point2D)
	slope, intersect = line(gena,genb)
	return xvalue*slope + intersect
end

@doc """
	line(gena::Point2D, genb::Point2D) -> (slope,intersect)

Compute the slope and intersection of the straight line that goes through `gena` and `genb`.
"""->
function line(gena::Point2D, genb::Point2D)
	@assert !isapprox(gena,genb) "Supply two different points"
	@assert !isvertical(gena,genb) "Line segment is vertical"

	ax = getx(gena)
	ay = gety(gena)
	slope = (ay - gety(genb)) / (ax - getx(genb))
	intersect = ay - slope*ax
	return (slope,intersect)
end

@doc """
	isinside(corner::Point2D)

Test if `corner` is inside the bounding box.
"""->
function isinside(corner::Point2D)
	left <= getx(corner) <= right && lower <= gety(corner) <= upper
end

