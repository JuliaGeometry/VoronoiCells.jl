import VoronoiCells: LEFT, RIGHT, LOWER, UPPER
using VoronoiDelaunay

@testset "Clipping lines" begin
	# ------------------------------------------------------------
	# Points inside the bounding box are untouched by clip

	A = Point2D(LEFT+rand(), LOWER+rand())
	B = Point2D(LEFT+rand(), LOWER+rand())
	C, D = clip(A, B)

	@test A == C
	@test B == D


	# ------------------------------------------------------------
	# With one point on the boundary and the other outside (in the correct
	# direction), clip should return two identical points

	A = Point2D(LEFT, LOWER+rand())
	B = Point2D(LEFT-0.5, LOWER+rand())
	C, D = clip(A, B)
	@test C == D

	A = Point2D(LEFT+rand(), UPPER)
	B = Point2D(LEFT+rand(), UPPER+0.5)
	C, D = clip(A, B)
	@test C == D


	# ------------------------------------------------------------
	# When clipping off part of a line segment the slope should not change

	A = Point2D(LEFT+rand(), LOWER+rand())
	B = Point2D(LEFT+rand(), UPPER+rand())
	C, D = clip(A, B)

	slope1 = (gety(A)-gety(B)) / (getx(A)-getx(B))
	slope2 = (gety(C)-gety(D)) / (getx(C)-getx(D))

	@test slope1 ≈ slope2
end

