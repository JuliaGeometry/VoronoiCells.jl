using VoronoiCells
using GeometryBasics
import VoronoiDelaunay
using Test


@testset "Points" begin
    @testset "Arithmetic with points" begin
        p = VoronoiCells.IndexablePoint2D(1.0, 1.0)
        q = VoronoiCells.IndexablePoint2D(1.1, 1.1)

        @test p + q == VoronoiDelaunay.Point2D(2.1, 2.1)
        @test q - p ≈ VoronoiDelaunay.Point2D(0.1, 0.1)
        @test 1.5 * p == VoronoiDelaunay.Point2D(1.5, 1.5)
    end

    @testset "Distance between points" begin
        p = VoronoiCells.IndexablePoint2D(1.0, 1.0)
        q = VoronoiCells.IndexablePoint2D(3.0, 2.0)
        
        @test abs2(p, q) == 5
    end
end
