using VoronoiCells
using Test


@testset "Sort points" begin
    @testset "Average point" begin
        points = [
            GeometryBasics.Point2(1.0, 1.0),
            GeometryBasics.Point2(3.0, 3.0)
        ]

        avg_point = VoronoiCells.mean(points)

        @test VoronoiCells.mean(points) == GeometryBasics.Point2(2.0, 2.0)
    end

    @testset "Sorting points is independent of translation" begin
        radians = range(0, stop = 2π, length = 10)
        points = [GeometryBasics.Point2(cos(θ), sin(θ)) for θ in radians]
        translated_points = [GeometryBasics.Point2(1, 1) + point for point in points]

        @test sortperm(points) == sortperm(translated_points)
    end
end

