@testset "Density" begin
	# Corners of the unit square
	x = [1.0 ; 0.0 ; 0.0 ; 1.0]
	y = [1.0 ; 1.0 ; 0.0 ; 0.0]

	@test density(x, y) ≈ sqrt(2)/2
end

