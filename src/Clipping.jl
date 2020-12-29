function clip(l::VoronoiDelaunay.VoronoiEdge, rect::Rectangle)
    A = VoronoiDelaunay.geta(l)
    B = VoronoiDelaunay.getb(l)

    clip(A, B, rect)
end


function clip(A::VoronoiDelaunay.AbstractPoint2D, B::VoronoiDelaunay.AbstractPoint2D, rect::Rectangle)
    if isinside(A, rect) && isinside(B, rect)
        VoronoiDelaunay.Line(A, B)
        # GeometryBasics.Line(A, B)
	end

	t0 = 0.0
	t1 = 1.0
	D = B - A
	# left, right, bottom, top
	# Parametrization of line segment from A to B
	p = [-getx(D) ; getx(D) ; -gety(D) ; gety(D)]
	q = [getx(A) - left(rect) ; right(rect) - getx(A) ; gety(A) - lower(rect) ; upper(rect) - gety(A)]
	for k in 1:4
		if p[k] == 0.0
			# Line parallel with k'th edge
			if q[k] < 0.0
				return nothing
			end
		elseif p[k] < 0.0
			# Outside to inside
			u = q[k] / p[k]
			if u > t1
				return nothing
			end
			t0 = max(u, t0)
		else # p[k] > 0.0
			# Inside to outside
			u = q[k] / p[k]
			if u < t0
				return nothing
			end
			t1 = min(u, t1)
		end
	end

	return VoronoiDelaunay.Line(A + t0*D, A + t1*D)
end
