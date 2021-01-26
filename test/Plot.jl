using VoronoiCells
using GeometryBasics
using Test


@testset "Plotting" begin
    @testset "Edges for plotting" begin
        points = [Point2(0.25, 0.25), Point2(0.75, 0.25), Point2(0.5, 0.75)]
        rect = Rectangle(Point2(0, 0), Point2(1, 1))
        tess = voronoicells(points, rect)

        p = VoronoiCells.corner_coordinates(tess)

        @test length(filter(isnan, p)) == length(points)

        expected_corners = [
            [0.0, 0.6875],
            [0.0, 0.0],
            [0.5, 0.0],
            [0.5, 0.4375],
            [0.0, 0.6875],
            [0.5, 0.4375],
            [0.5, 0.0],
            [1.0, 0.0],
            [1.0, 0.6875],
            [0.5, 0.4375],
            [0.0, 1.0],
            [0.0, 0.6875],
            [0.5, 0.4375],
            [1.0, 0.6875],
            [1.0, 1.0],
            [0.0, 1.0]
        ]

        @test filter(!isnan, p) ≈ expected_corners atol = 1e-4
    end
end
