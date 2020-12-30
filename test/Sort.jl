using VoronoiCells


@testset "Sort points" begin
    @testset "Average point" begin
        points = [
            GeometryBasics.Point2(1.0, 1.0),
            GeometryBasics.Point2(3.0, 3.0)
        ]

        avg_point = VoronoiCells.mean(points)

        @test VoronoiCells.mean(points) == GeometryBasics.Point2(2.0, 2.0)
    end

    @testset "Sort points in clockwise order" begin
        # It is simpler when all points are in the same quadrant
        points = [GeometryBasics.Point2(cos(θ), sin(θ)) for θ in 1.5:-0.5:0]

        @test VoronoiCells.issorted(points)
    end
end

