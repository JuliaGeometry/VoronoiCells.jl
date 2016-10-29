using VoronoiCells

if VERSION >= v"0.5.0"
	using Base.Test
else
	using BaseTestNext
	const Test = BaseTestNext
end

@testset "Density" begin
	# Corners of the unit square
	x = [1.0 ; 0.0 ; 0.0 ; 1.0]
	y = [1.0 ; 1.0 ; 0.0 ; 0.0]

	@test_approx_eq density(x, y) sqrt(2)/2
end

