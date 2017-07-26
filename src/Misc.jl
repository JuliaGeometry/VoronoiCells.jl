"""
	isapprox(a::AbstractPoint2D, b::AbstractPoint2D) -> Bool

Test if the two points `a` and `b` are approximately equal in the `l1`-norm.
"""
function Base.isapprox(a::AbstractPoint2D, b::AbstractPoint2D)
	isapprox(getx(a), getx(b)) && isapprox(gety(a), gety(b))
end

"""
	contains(pts::AbstractPoints2D, p::AbstractPoint2D) -> Bool

Test if the point `p` is in the vector of points `pts`.
"""
function Base.contains(pts::Vector{<:AbstractPoint2D}, p::AbstractPoint2D)
	for element in pts
		if isapprox(p, element)
			return true
		end
	end
	return false
end

"""
	dist_squared(p, q) -> Real

The `l2` distance squared between the points `p` and `q`.
"""
function dist_squared(p::AbstractPoint2D, q::AbstractPoint2D)
	(getx(p)-getx(q))^2 + (gety(p)-gety(q))^2 
end

"""
	quadrant(p::AbstractPoint2D)

Get the quadrant number of `p`.

The quadrants are numbered in the usual way, starting with 1 in the upper 
right and consecutively with positive orientation:

* 1 is the upper right
* 2 is the upper left
* 3 is the lower left
* 4 is the lower right
"""
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

"""
	fit2boundingbox(x::Vector, y::Vector; ...) -> Points2D, Float, Float

Scale `x` and `y` to be in the GeometricalPredicates window [1,2]x[1,2].
Return a vector of `Point2D`'s and the scaling factors applied in each
dimension.

As an optional argument the bounding box of `x` and `y` can be changed
from the unit square.
"""
function fit2boundingbox(x::AbstractVector{Float64}, y::AbstractVector{Float64}, rw::Vector{Float64}=[0.0;1.0;0.0;1.0])
	(N = length(x)) == length(y) || throw(DimensionMismatch())

	RW_LEFT = rw[1]
	RW_LOWER = rw[3]
	minimum(x) >= RW_LEFT && maximum(x) <= rw[2] && minimum(y) >= RW_LOWER && maximum(y) <= rw[4] || throw(DomainError())

	SCALEX = rw[2] - RW_LEFT
	SCALEY = rw[4] - RW_LOWER

	pts = [IndexablePoint2D( LEFT + (x[n]-RW_LEFT)/SCALEX, LOWER + (y[n]-RW_LOWER)/SCALEY, n) for n = 1:N]

	return pts, SCALEX, SCALEY
end

