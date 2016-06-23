using VoronoiCells
import VoronoiCells: LEFT, RIGHT, LOWER, UPPER
using Base.Test

N = 100
x = 1.0 + rand(N)
y = 1.0 + rand(N)

A = VoronoiCells.voronoiarea(x, y, [LEFT; RIGHT; LOWER; UPPER])
@test_approx_eq sum(A) 1.0
#= @test sum(A) <= 1.0 =#


# ------------------------------------------------------------
# Compare with Deldir

if !isa(Pkg.installed("Deldir"), Void)
	using Deldir
	A2 = Deldir.voronoiarea(x, y; rw=[LEFT; RIGHT; LOWER; UPPER])
	@test_approx_eq A A2
end

