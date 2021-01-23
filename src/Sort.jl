const PointTypes = Union{VoronoiDelaunay.AbstractPoint2D, GeometryBasics.Point2}

function mean(pts::Vector{T}) where T <: PointTypes
	ax = 0.0
	ay = 0.0

	@simd for p in pts
		ax += getx(p)
		ay += gety(p)
	end

	Np = length(pts)
	T(ax/Np, ay/Np)
end


for name in [:sort, :sort!, :issorted, :sortperm]
	@eval begin
		function Base.$name(pts::Vector{T}) where T <: PointTypes
			center = mean(pts)
			$name(pts, by = p -> p - center, rev = true)
		end
	end
end


# http://stackoverflow.com/questions/6989100/sort-points-in-clockwise-order
function Base.isless(p::T, q::T) where T <: PointTypes
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
	origin = T(0.0, 0.0)
	abs2(p, origin) > abs2(q, origin)
end
