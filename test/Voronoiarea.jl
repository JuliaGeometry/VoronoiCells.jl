import VoronoiCells: LEFT, RIGHT, LOWER, UPPER
using Deldir

@testset "Area of Voronoi cells" begin
	N = 100
	x = 1.0 .+ rand(N)
	y = 1.0 .+ rand(N)

	A = VoronoiCells.voronoiarea(x, y, [LEFT; RIGHT; LOWER; UPPER])
	# For most realizations |sum(A) - 1| is approx 10^{-15} and easily
	# passing the test. Occasionally it fails with sum(A) = 0.999x, where x != 9
	@test isapprox(sum(A), 1, atol = 1e-4)


	# ------------------------------------------------------------
	# Compare with Deldir
	A2 = Deldir.voronoiarea(x, y, [LEFT; RIGHT; LOWER; UPPER])
	@test A ≈ A2
end


@testset "Errors with Voronoi cells" begin
	x = RIGHT .+ rand(8)
	y = UPPER .+ rand(8)

	@test_throws DomainError VoronoiCells.voronoiarea(x, y)
end
