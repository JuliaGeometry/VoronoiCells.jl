using VoronoiCells
using Base.Test

# Corners of the unit square
x = [1.0 ; 0.0 ; 0.0 ; 1.0]
y = [1.0 ; 1.0 ; 0.0 ; 0.0]

@test_approx_eq density(x, y) sqrt(2)/2

