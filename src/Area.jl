@doc """
	voronoiarea(C::VoronoiCorners) -> Vector

Compute the area of each of the Voronoi cells in `C`.

Note that if the polygons of `C` are not ordered, they will be changed in-place.
"""->
function voronoiarea(C::VoronoiCorners)
	# TODO: The dreaded corners are indexed by -1. When they are
	# removed, remember to change NC 
	NC = length(C) - 1
	A = Array{Float64}(NC)

	for n in 1:NC
		A[n] = polyarea( C[n] )
	end

	return A
end

@doc """
	polyarea(p::AbstractPoints2D)

Compute the area of the polygon with vertices `p` using the shoelace formula.

If the points in `p` are not sorted, they will be sorted **in-place**.
"""->
function polyarea{T<:AbstractPoint2D}(p::Vector{T})
	issorted(p) || sort!(p)

	Np = length(p)
	A = getx(p[1])*( gety(p[2]) - gety(p[Np]) ) + getx(p[Np])*( gety(p[1]) - gety(p[Np-1]) )

	for n in 2:Np-1
		A += getx(p[n])*( gety(p[n+1]) - gety(p[n-1]) )
	end

	return 0.5*abs(A)
end

function Base.(:-)(p::AbstractPoint2D, q::AbstractPoint2D)
	Point2D( getx(p)-getx(q), gety(p)-gety(q) )
end

# Compute the average point of pts
function Base.mean{T<:AbstractPoint2D}(pts::Vector{T})
	# Average point
	ax = 0.0
	ay = 0.0

	for p in pts
		ax += getx(p)
		ay += gety(p)
	end

	Np = length(pts)
	Point2D(ax/Np, ay/Np)
end

function Base.issorted(pts::AbstractPoints2D)
	center = mean(pts)
	centralize = p -> p - center
	issorted( pts, by=centralize )
end

# http://stackoverflow.com/questions/6989100/sort-points-in-clockwise-order
function Base.isless(p::AbstractPoint2D, q::AbstractPoint2D)
	if getx(p) >= 0.0 && getx(q) < 0.0
		return true
	elseif getx(p) < 0.0 && getx(q) >= 0.0
		return false
	elseif getx(p) == getx(q) == 0.0
		if gety(p) >= 0.0 || gety(q) >= 0.0
			return gety(p) > gety(q)
		else
			return gety(p) < gety(q)
		end
	end

	det = getx(p)*gety(q) - getx(q)*gety(p)
	if det < 0.0
		return true
	elseif det > 0.0
		return false
	end

	# p and q are on the same line from the center; check which one is
	# closer to the origin
	origin = Point2D(0.0, 0.0)
	dist_squared(p,origin) > dist_squared(q,origin)
end

# Sorting by polar angle around the origin.
# http://gamedev.stackexchange.com/questions/13229/sorting-array-of-points-in-clockwise-order/
# The sign of atan2 makes this comparison inadequate for issorted, but
# fine for sort
function isless_angle(p::AbstractPoint2D, q::AbstractPoint2D)
	atan2(gety(p), getx(p)) > atan2(gety(q), getx(q))
end

