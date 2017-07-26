using VoronoiCells
import VoronoiCells: LEFT, RIGHT, LOWER, UPPER
using VoronoiDelaunay
using Base.Test

@testset "Area of polygons" begin
	# Area of square
	S = [Point2D(LEFT,LOWER) ; Point2D(RIGHT,LOWER) ; Point2D(RIGHT,UPPER) ; Point2D(LEFT,UPPER)]
	@test polyarea(S) ≈ 1.0

	# Area of triangle
	T1 = [Point2D(LEFT,LOWER) ; Point2D(RIGHT,LOWER) ; 0.5*(Point2D(RIGHT,UPPER) + Point2D(LEFT,UPPER))]
	@test polyarea(T1) ≈ 0.5

	T2 = [Point2D(LEFT,LOWER) ; Point2D(LEFT+0.5,LOWER) ;
	Point2D(LEFT,LOWER+0.5)]
	@test polyarea(T2) ≈ 0.5^3
end

