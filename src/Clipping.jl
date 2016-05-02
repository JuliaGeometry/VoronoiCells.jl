@doc """
	clip(A::Point2D, B::Point2D) -> C, D

Clip the line segment with endpoints `A` and `B` to the bounding box.
The returned points `C` and `D` are the endpoints of the intersection.

If the line segment is not intersecting the bounding box, both `C` and
`D` are `NaN` points.
"""->
function clip(A::Point2D, B::Point2D)
	if isinside(A) && isinside(B)
		return A, B
	end

	t0 = 0.0
	t1 = 1.0
	D = B - A
	# left, right, bottom, top
	# Parametrization of line segment from A to B
	p = [-getx(D) ; getx(D) ; -gety(D) ; gety(D)]
	q = [getx(A)-LEFT ; RIGHT-getx(A) ; gety(A)-LOWER ; UPPER-gety(A)]
	for k in 1:4
		if p[k] == 0.0
			# Line parallel with k'th edge
			if q[k] < 0.0
				return Point2D(NaN,NaN), Point2D(NaN,NaN)
			end
		elseif p[k] < 0.0
			# Outside to inside
			u = q[k] / p[k]
			if u > t1
				return Point2D(NaN,NaN), Point2D(NaN,NaN)
			end
			t0 = max( u, t0 )
		else # p[k] > 0.0
			# Inside to outside
			u = q[k] / p[k]
			if u < t0
				return Point2D(NaN,NaN), Point2D(NaN,NaN)
			end
			t1 = min( u, t1 )
		end
	end

	return A + t0*D, A + t1*D
end


@doc """
	isinside(p::Point2D) -> Bool

Test if the point `p` is inside the bounding box.
"""->
function isinside(p::Point2D)
	LEFT <= getx(p) <= RIGHT && LOWER <= gety(p) <= UPPER
end

function Base.isnan(p::AbstractPoint2D)
	isnan(getx(p)) || isnan(gety(p))
end

