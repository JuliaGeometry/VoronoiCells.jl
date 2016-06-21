@doc """
	dist_squared(p, q) -> Real

The `l2` distance squared between the points `p` and `q`.
"""->
function dist_squared(p::AbstractPoint2D, q::AbstractPoint2D)
	(getx(p)-getx(q))^2 + (gety(p)-gety(q))^2 
end

@doc """
	quadrant(edge::VoronoiDelaunay.VoronoiEdge{IndexablePoint2D})

Get the quadrant number of the generators of `edge`.

The quadrants are numbered in the usual way, starting with 1 in the upper 
right and consecutively with positive orientation:

* 1 is the upper right
* 2 is the upper left
* 3 is the lower left
* 4 is the lower right
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

