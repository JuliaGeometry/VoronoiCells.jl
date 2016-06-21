@doc """
	isapprox(a::AbstractPoint2D, b::AbstractPoint2D) -> Bool

Test if the two points `a` and `b` are approximately equal in the `l1`-norm.
"""->
function Base.isapprox(a::AbstractPoint2D, b::AbstractPoint2D)
	isapprox(getx(a), getx(b)) && isapprox(gety(a), gety(b))
end

@doc """
	contains(pts::AbstractPoints2D, p::AbstractPoint2D) -> Bool

Test if the point `p` is in the vector of points `pts`.
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
	dist_squared(p, q) -> Real

The `l2` distance squared between the points `p` and `q`.
"""->
function dist_squared(p::AbstractPoint2D, q::AbstractPoint2D)
	(getx(p)-getx(q))^2 + (gety(p)-gety(q))^2 
end

@doc """
	quadrant(p::AbstractPoint2D)

Get the quadrant number of `p`.

The quadrants are numbered in the usual way, starting with 1 in the upper 
right and consecutively with positive orientation:

* 1 is the upper right
* 2 is the upper left
* 3 is the lower left
* 4 is the lower right
"""->
function quadrant(p::AbstractPoint2D)
	isleft = getx(p) < MIDDLEx
	islow = gety(p) < MIDDLEy

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

