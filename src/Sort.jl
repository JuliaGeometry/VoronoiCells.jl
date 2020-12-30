function mean(pts::Vector{GeometryBasics.Point2})
	ax = 0.0
	ay = 0.0

	@simd for p in pts
		ax += getx(p)
		ay += gety(p)
	end

	Np = length(pts)
	GeometryBasics.Point2(ax/Np, ay/Np)
end


for name in [:sort!, :issorted]
	@eval begin
		function Base.$name(pts::Vector{GeometryBasics.Point2})
			center = mean(pts)
			centralize = p -> p - center
			$name(pts, by = centralize)
		end
	end
end


# http://stackoverflow.com/questions/6989100/sort-points-in-clockwise-order
function Base.isless(p::GeometryBasics.Point2, q::GeometryBasics.Point2)
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
	origin = GeometryBasics.Point2(0.0, 0.0)
	abs2(p, origin) > abs2(q, origin)
end
