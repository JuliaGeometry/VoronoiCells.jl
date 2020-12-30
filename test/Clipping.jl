using VoronoiCells
using VoronoiDelaunay

@testset "Clipping" begin
    rect = Rectangle(1, 2, 1, 2)

    @testset "Lines wholly within the rectangle are not modified" begin
        l = VoronoiDelaunay.Line(
            VoronoiDelaunay.Point2D(1.3, 1.5),
            VoronoiDelaunay.Point2D(1.7, 1.5)
        )

        @test l == VoronoiCells.clip(l, rect)
    end

    @testset "Clip line with one endpoint outside rectangle" begin
        l = VoronoiDelaunay.Line(
            VoronoiDelaunay.Point2D(1.3, 1.5),
            VoronoiDelaunay.Point2D(2.7, 1.5)
        )

        expected_line = VoronoiDelaunay.Line(
            VoronoiDelaunay.Point2D(1.3, 1.5),
            VoronoiDelaunay.Point2D(2.0, 1.5)
        )

        @test VoronoiCells.clip(l, rect) == expected_line
    end

    @testset "Clip line with both endpoints outside rectangle" begin
        l = VoronoiDelaunay.Line(
            VoronoiDelaunay.Point2D(0.3, 1.5),
            VoronoiDelaunay.Point2D(2.7, 1.5)
        )

        expected_line = VoronoiDelaunay.Line(
            VoronoiDelaunay.Point2D(1.0, 1.5),
            VoronoiDelaunay.Point2D(2.0, 1.5)
        )

        @test VoronoiCells.clip(l, rect) == expected_line
    end

    @testset "Line does not intersect rectangle" begin
        l = VoronoiDelaunay.Line(
            VoronoiDelaunay.Point2D(1.3, 0.5),
            VoronoiDelaunay.Point2D(1.7, 0.5)
        )

        @test isnothing(VoronoiCells.clip(l, rect))
    end

    @testset "Clip line whose intersection with rectangle is one point on boundary" begin
        l = VoronoiDelaunay.Line(
            VoronoiDelaunay.Point2D(2.0, 1.5),
            VoronoiDelaunay.Point2D(2.7, 1.5)
        )

        expected_line = VoronoiDelaunay.Line(
            VoronoiDelaunay.Point2D(2.0, 1.5),
            VoronoiDelaunay.Point2D(2.0, 1.5)
        )

        @test VoronoiCells.clip(l, rect) == expected_line
    end
end
