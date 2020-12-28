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


@testset "Is point in rectangle" begin
    @testset "Point is in rectangle" begin
        point = GeometryBasics.Point2(1, 1)
        rect = Rectangle(0, 2, 0, 2)

        @test VoronoiCells.isinside(point, rect)
    end

    @testset "Point is not in rectangle" begin
        point = GeometryBasics.Point2(-1, 1)
        rect = Rectangle(0, 2, 0, 2)

        @test !VoronoiCells.isinside(point, rect)
    end
end


@testset "Map points between recangles of the same size" begin
    points = [GeometryBasics.Point2(rand(), rand()) for _ in 1:2]
    from_rect = Rectangle(0, 1, 0, 1)
    to_rect = Rectangle(1, 2, 1, 2)

    transformed_points = map_rectangle(points, from_rect, to_rect)

    @testset "Output has expected type" begin
        @test isa(transformed_points, Vector{VoronoiCells.IndexablePoint2D})

        @test getindex(transformed_points[1]) == 1
        @test getindex(transformed_points[2]) == 2
    end

    @testset "Output has expected values" begin
        from_x = points[1][1]
        to_x = VoronoiCells.getx(transformed_points[1])
        @test to_x == from_x + 1

        from_y = points[1][2]
        to_y = VoronoiCells.gety(transformed_points[1])
        @test to_y == from_y + 1
    end
end


@testset "Map points between scaled recangles" begin
    points = [
        GeometryBasics.Point2(0, 0),
        GeometryBasics.Point2(0.5, 0.5),
        GeometryBasics.Point2(1, 1)
    ]

    from_rect = Rectangle(0, 1, 0, 1)
    to_rect = Rectangle(0, 2, 0, 2)

    transformed_points = map_rectangle(points, from_rect, to_rect)

    @testset "Output has expected values" begin
        @test transformed_points[1] == VoronoiCells.IndexablePoint2D(0.0, 0.0, 1)
        @test transformed_points[2] == VoronoiCells.IndexablePoint2D(1.0, 1.0, 2)
        @test transformed_points[3] == VoronoiCells.IndexablePoint2D(2.0, 2.0, 3)
    end
end


@testset "Error mapping points outside rectangle" begin
    points = [GeometryBasics.Point2(-1, 0)]

    from_rect = Rectangle(0, 1, 0, 1)
    to_rect = Rectangle(0, 2, 0, 2)

    @test_throws ErrorException map_rectangle(points, from_rect, to_rect)
end
