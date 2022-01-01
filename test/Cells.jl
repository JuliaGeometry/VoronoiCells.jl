using VoronoiCells
using GeometryBasics
using Random
using Test


@testset "Cells" begin
    @testset "PointCollection from GeometryBasics" begin
        rng = Random.MersenneTwister(2)
        points = [Point2(rand(rng), rand(rng)) for _ in 1:5]
        rect = Rectangle(Point2(0, 0), Point2(1, 1))

        pc = VoronoiCells.PointCollection(points, rect)

        @test isa(pc, VoronoiCells.PointCollection{GeometryBasics.Point2{Float64}})
    end

    @testset "PointCollection from VoronoiDelaunay" begin
        rng = Random.MersenneTwister(2)
        points = [VoronoiDelaunay.Point2D(1 + rand(rng), 1 + rand(rng)) for _ in 1:5]
        rect = Rectangle(VoronoiDelaunay.Point2D(1.1, 1.1), VoronoiDelaunay.Point2D(1.9, 1.9))

        pc = VoronoiCells.PointCollection(points, rect)

        @test isa(pc, VoronoiCells.PointCollection{VoronoiDelaunay.Point2D})
    end

    @testset "Error making PointCollection with mix of VoronoiDelaunay and GeometryBasics" begin
        rng = Random.MersenneTwister(2)
        points = [VoronoiDelaunay.Point2D(1 + rand(rng), 1 + rand(rng)) for _ in 1:5]
        rect = Rectangle(Point2(1, 1), Point2(2, 2))

        @test_throws MethodError VoronoiCells.PointCollection(points, rect)
    end

    @testset "Simple point set far from corners" begin
        rect = Rectangle(Point2(0, 0), Point2(1, 1))

        points = [
            Point2(0.75, 0.75),
            Point2(0.25, 0.25),
            Point2(0.25, 0.75)
        ]

        tess = voronoicells(points, rect)

        @test tess.Cells[1] == [Point2(0.5, 1.0), Point2(0.5, 0.5), Point2(1.0, 0.0), Point2(1.0, 1.0)]
        @test tess.Cells[2] == [Point2(0.0, 0.5), Point2(0.0, 0.0), Point2(1.0, 0.0), Point2(0.5, 0.5)]
        @test tess.Cells[3] == [Point2(0.0, 1.0), Point2(0.0, 0.5), Point2(0.5, 0.5), Point2(0.5, 1.0)]
    end

    @testset "Point set on corners" begin
        rect = Rectangle(Point2(0, 0), Point2(1, 1))

        points = [
            Point2(0.0, 0.0),
            Point2(1.0, 0.0),
            Point2(1.0, 1.0),
            Point2(0.0, 1.0)
        ]

        tess = voronoicells(points, rect)

        @test tess.Cells[1] == [Point2(0.0, 0.5), Point2(0.0, 0.0), Point2(0.5, 0.0), Point2(0.5, 0.5)]
        @test tess.Cells[2] == [Point2(0.5, 0.5), Point2(0.5, 0.0), Point2(1.0, 0.0), Point2(1.0, 0.5)]
        @test tess.Cells[3] == [Point2(0.5, 1.0), Point2(0.5, 0.5), Point2(1.0, 0.5), Point2(1.0, 1.0)]
        @test tess.Cells[4] == [Point2(0.0, 1.0), Point2(0.0, 0.5), Point2(0.5, 0.5), Point2(0.5, 1.0)]
    end

    @testset "Random point set" begin
        rng = Random.MersenneTwister(1)
        points = [Point2(rand(rng), rand(rng)) for _ in 1:5]

        rect = Rectangle(Point2(0, 0), Point2(1, 1))

        tess = voronoicells(points, rect)

        @test tess.Cells[1] ≈ [
            Point2(0.0, 0.67254), Point2(0.0, 0.11508), Point2(0.31246, 0.18583), Point2(0.56624, 0.65872),
        ] atol = 1e-4
        @test tess.Cells[2] ≈ [
         Point2(0.0, 0.11508), Point2(0.0, 0.0), Point2(0.52699, 0.0), Point2(0.31246, 0.18583)
        ] atol = 1e-4
        @test tess.Cells[3] ≈ [
             Point2(0.60787, 0.67143), Point2(0.56624, 0.65872), Point2(0.31246, 0.18583), Point2(0.52699, 0.0), Point2(1.0, 0.0), Point2(1.0, 0.44116)
        ] atol = 1e-4
        @test tess.Cells[4] ≈ [
             Point2(0.60166, 1.0), Point2(0.60787, 0.67143), Point2(1.0, 0.44116), Point2(1.0, 1.0)
        ] atol = 1e-4
        @test tess.Cells[5] ≈ [
             Point2(0.0, 1.0), Point2(0.0, 0.67254), Point2(0.56624, 0.65872), Point2(0.60787, 0.67143), Point2(0.60166, 1.0)
        ] atol = 1e-4
    end
end

