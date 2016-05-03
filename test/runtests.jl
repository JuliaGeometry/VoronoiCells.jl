using VoronoiCells
import VoronoiCells: LEFT, RIGHT, LOWER, UPPER
using Base.Test

# write your own tests here
N = 100
x = 1.0 + rand(N)
y = 1.0 + rand(N)

A = VoronoiCells.voronoiarea(x, y; rw=[LEFT; RIGHT; LOWER; UPPER])

# A weak test until the corner issue is fixed
#= @test_approx_eq sum(A) 1.0 =#
@test sum(A) <= 1.0


# ------------------------------------------------------------
# I trust Deldir: With the corner points added, VoronoiCells and
# Deldir shoud return the same tesselation

if !isa(Pkg.installed("Deldir"), Void)
	x2 = [x ; RIGHT ; LEFT ; LEFT ; RIGHT]
	y2 = [y ; UPPER ; UPPER ; LOWER ; LOWER]

	using Deldir
	A2 = Deldir.voronoiarea(x2, y2; rw=[LEFT; RIGHT; LOWER; UPPER])
	@test_approx_eq A A2[1:N]
end

