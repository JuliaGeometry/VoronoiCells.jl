using VoronoiCells
using VoronoiDelaunay
using Test


@testset "Clipping" begin
    rect = VoronoiCells.BoundingBox

    @testset "Lines wholly within the rectangle are not modified" begin
        A = VoronoiDelaunay.Point2D(1.3, 1.5)
        B = VoronoiDelaunay.Point2D(1.7, 1.5)
        l = VoronoiDelaunay.Line(A, B)

        @test l == VoronoiCells.clip(l, rect)
    end

    @testset "Clip line with one endpoint outside rectangle" begin
        A = VoronoiDelaunay.Point2D(1.3, 1.5)
        B = VoronoiDelaunay.Point2D(VoronoiCells.right(rect) + 1, 1.5)
        l = VoronoiDelaunay.Line(A, B)

        expected_B = VoronoiDelaunay.Point2D(VoronoiCells.right(rect), gety(B))
        expected_line = VoronoiDelaunay.Line(A, expected_B)

        @test VoronoiCells.clip(l, rect) == expected_line
    end

    @testset "Clip line with both endpoints outside rectangle" begin
        A = VoronoiDelaunay.Point2D(VoronoiCells.left(rect) - 1, 1.5)
        B = VoronoiDelaunay.Point2D(VoronoiCells.right(rect) + 1, 1.5)
        l = VoronoiDelaunay.Line(A, B)

        expected_A = VoronoiDelaunay.Point2D(VoronoiCells.left(rect), gety(A))
        expected_B = VoronoiDelaunay.Point2D(VoronoiCells.right(rect), gety(B))
        expected_line = VoronoiDelaunay.Line(expected_A, expected_B)

        @test VoronoiCells.clip(l, rect) == expected_line
    end

    @testset "Line does not intersect rectangle" begin
        l = VoronoiDelaunay.Line(
            VoronoiDelaunay.Point2D(1.3, VoronoiCells.lower(rect) - 1),
            VoronoiDelaunay.Point2D(1.7, VoronoiCells.lower(rect) - 1)
        )

        @test isnothing(VoronoiCells.clip(l, rect))
    end

    @testset "Clip line whose intersection with rectangle is one point on boundary" begin
        A = VoronoiDelaunay.Point2D(VoronoiCells.right(rect), 1.5)
        B = VoronoiDelaunay.Point2D(VoronoiCells.right(rect) + 1, 1.5)
        l = VoronoiDelaunay.Line(A, B)

        expected_B = VoronoiDelaunay.Point2D(VoronoiCells.right(rect), gety(B))
        expected_line = VoronoiDelaunay.Line(A, expected_B)

        @test VoronoiCells.clip(l, rect) == expected_line
    end
end
