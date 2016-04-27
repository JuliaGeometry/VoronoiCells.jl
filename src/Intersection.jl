@doc """
	is_bounding_corner(p::Point2D) -> Bool

Test if `p` is a corner in the bounding box.
"""->
function is_bounding_corner(p::Point2D)
	# TODO: test == or isapprox?
	isapprox(p, LOWERLEFT) || isapprox(p, LOWERRIGHT) || isapprox(p, UPPERLEFT) || isapprox(p, PPERRIGHT)
end

@doc """
	isvertical(gena::Point2D, genb::Point2D)

Test if a line segment with endpoints `gena` and `genb` is vertical.
"""->
function isvertical(gena::Point2D, genb::Point2D)
	isapprox( getx(gena), getx(genb) )
end

@doc """
	ishorizontal(gena::Point2D, genb::Point2D)

Test if a line segment with endpoints `gena` and `genb` is horizontal.
"""->
function ishorizontal(gena::Point2D, genb::Point2D)
	isapprox( gety(gena), gety(genb) )
end

@doc """
	bounding_intersect(edge::VoronoiEdge) -> Point2D

Restrict a line segment to the bounding box.

	bounding_intersect(gena::Point2D, genb::Point2D) -> Point2D

Restrict a line segment with endpoints `gena` and `genb` to the bounding box.
"""->
function bounding_intersect(A::Point2D, B::Point2D)

	while !isinside(A)
		if getx(A) < LEFT
			edge = :left
		elseif getx(A) > RIGHT
			edge = :right
		elseif gety(A) < LOWER
			edge = :lower
		elseif gety(A) > UPPER
			edge = :upper
		end
		A = intersection(edge, A, B)
	end

	while !isinside(B)
		if getx(B) < LEFT
			edge = :left
		elseif getx(B) > RIGHT
			edge = :right
		elseif gety(B) < LOWER
			edge = :lower
		elseif gety(B) > UPPER
			edge = :upper
		end
		B = intersection(edge, A, B)
	end

	return A, B
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

	return slope, intersect
end

@doc """
	isinside(p::Point2D) -> Bool

Test if the point `p` is inside the bounding box.
"""->
function isinside(p::Point2D)
	LEFT <= getx(p) <= RIGHT && LOWER <= gety(p) <= UPPER
end

