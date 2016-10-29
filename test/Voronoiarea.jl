using VoronoiCells
import VoronoiCells: LEFT, RIGHT, LOWER, UPPER
using Deldir

if VERSION >= v"0.5.0"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

@testset "Area of Voronoi cells" begin
	N = 100
	x = 1.0 + rand(N)
	y = 1.0 + rand(N)

	A = VoronoiCells.voronoiarea(x, y, [LEFT; RIGHT; LOWER; UPPER])
	# For most realizations |sum(A) - 1| is approx 10^{-15} and easily
	# passing the test. Occasionally it fails with sum(A) = 0.999x, where x != 9
	@test abs(sum(A) - 1) < 1e-4


	# ------------------------------------------------------------
	# Compare with Deldir
	A2 = Deldir.voronoiarea(x, y; rw=[LEFT; RIGHT; LOWER; UPPER])
	@test_approx_eq A A2
end

