using VoronoiCells
using GeometryBasics
using Random


@testset "Cells" begin
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
        Random.seed!(1)
        points = [Point2(rand(), rand()) for _ in 1:5]

        rect = Rectangle(Point2(0, 0), Point2(1, 1))

        tess = voronoicells(points, rect)

        @test tess.Cells[1] ≈ [
            Point2(0.0, 0.6725450778852001), Point2(0.0, 0.11508534727601377), Point2(0.3124658667523724, 0.18583946121540876), Point2(0.5662413641793917, 0.6587206568255465),
        ]
        @test tess.Cells[2] ≈ [
         Point2(0.0, 0.11508534727601377), Point2(0.0, 0.0), Point2(0.5269917482938533, 0.0), Point2(0.3124658667523724, 0.18583946121540876)
        ]
        @test tess.Cells[3] ≈ [
             Point2(0.6078737825539366, 0.6714380112301491), Point2(0.5662413641793917, 0.6587206568255465), Point2(0.3124658667523724, 0.18583946121540876), Point2(0.5269917482938533, 0.0), Point2(1.0, 0.0), Point2(1.0, 0.44116160397565385)
        ]
        @test tess.Cells[4] ≈ [
             Point2(0.601662324178269, 1.0), Point2(0.6078737825539366, 0.6714380112301491), Point2(1.0, 0.44116160397565385), Point2(1.0, 1.0)
        ]
        @test tess.Cells[5] ≈ [
             Point2(0.0, 1.0), Point2(0.0, 0.6725450778852001), Point2(0.5662413641793917, 0.6587206568255465), Point2(0.6078737825539366, 0.6714380112301491), Point2(0.601662324178269, 1.0)
        ]
    end
end

