using VoronoiCells
using GeometryBasics


@testset "Construct Rectangles" begin
    @testset "Valid Rectangles" begin
        rect1 = Rectangle(0, 1, 0, 1)
        rect2 = Rectangle(GeometryBasics.Point2(0, 0), GeometryBasics.Point2(1, 1))
        @test rect1 == rect2

        rect3 = Rectangle(GeometryBasics.Point2(1, 1), GeometryBasics.Point2(0, 0))
        @test rect1 == rect3
    end

    @testset "Invalid Rectangles" begin
        @test_throws ErrorException Rectangle(1, 0, 0, 1)
    end
end
