using VoronoiCells
using GeometryBasics
import Random

@testset "Rectangles" begin
    @testset "Construct Rectangles" begin
        @testset "Construct with with GeometryBasics integer points" begin
            rect = Rectangle(Point2(0, 0), Point2(1, 1))
            @test isa(rect, Rectangle{GeometryBasics.Point{2, Float64}})
        end
    
        @testset "Construct with with GeometryBasics floating points" begin
            rect = Rectangle(Point2(0.0, 0.0), Point2(1.0, 1.0))
            @test isa(rect, Rectangle{Point{2, Float64}})
        end
    
        @testset "Construct with with VoronoiDelaunay points" begin
            rect = Rectangle(VoronoiDelaunay.Point2D(1.1, 1.1), VoronoiDelaunay.Point2D(1.6, 1.7))
            @test isa(rect, Rectangle{VoronoiDelaunay.Point2D})
        end
    
        @testset "Invalid Rectangles" begin
            p1 = GeometryBasics.Point2(0.0, 0.0)
            p2 = GeometryBasics.Point2(0.0, 1.0)

            @test_throws ArgumentError Rectangle(p1, p2)
        end
    end
    
    
    @testset "Is point in rectangle?" begin
        @testset "Point is in rectangle" begin
            point = GeometryBasics.Point2(1, 1)
            rect = Rectangle(GeometryBasics.Point2(0, 0), GeometryBasics.Point2(2, 2))
    
            @test VoronoiCells.isinside(point, rect)
        end
    
        @testset "Point is not in rectangle" begin
            point = GeometryBasics.Point2(-1, 1)
            rect = Rectangle(GeometryBasics.Point2(0, 0), GeometryBasics.Point2(2, 2))
    
            @test !VoronoiCells.isinside(point, rect)
        end
    end
    
    
    @testset "Map points between recangles" begin
        Random.seed!(1337)
        points = [GeometryBasics.Point2(rand(), rand()) for _ in 1:3]
    
        from_rect = Rectangle(GeometryBasics.Point2(0, 0), GeometryBasics.Point2(1, 1))
        to_rect = Rectangle(GeometryBasics.Point2(0, 0), GeometryBasics.Point2(2, 2))
    
        transformed_points = VoronoiCells.map_rectangle(points, from_rect, to_rect)
        double_transformed_points = VoronoiCells.map_rectangle(transformed_points, to_rect, from_rect)
    
        @test all(points .== double_transformed_points)
    end
    
    
    @testset "Error mapping points outside rectangle" begin
        points = [GeometryBasics.Point2(-1, 0)]
    
        from_rect = Rectangle(GeometryBasics.Point2(0, 0), GeometryBasics.Point2(1, 1))
        to_rect = Rectangle(GeometryBasics.Point2(0, 0), GeometryBasics.Point2(2, 2))
    
        @test_throws ErrorException VoronoiCells.map_rectangle(points, from_rect, to_rect)
    end

    @testset "Find points nearest to each rectangle corner" begin
        rect = Rectangle(GeometryBasics.Point2(0, 0), GeometryBasics.Point2(1, 1))

        @testset "Unique nearest neighbors" begin
            Random.seed!(1)
            points = [Point2(rand(), rand()) for _ in 1:5]

            corner_neighbors = VoronoiCells.corner_nearest_neighbor(points, rect)

            expected_neighbors = Dict(
                1 => [4], 2 => [5], 3 => [2], 4 => [3]
            )

            @test corner_neighbors == expected_neighbors
        end

        @testset "Multiple corners with the same nearest neighbors" begin
            points = [Point2(0.75, 0.5), Point2(0.25, 0.75), Point2(0.25, 0.25)]
            corner_neighbors = VoronoiCells.corner_nearest_neighbor(points, rect)

            expected_neighbors = Dict(
                1 => [1], 2 => [2], 3 => [3], 4 => [1]
            )

            @test corner_neighbors == expected_neighbors
        end

        @testset "Corners with multiple nearest neighbors" begin
            points = [Point2(0.75, 0.5), Point2(0.5, 0.75), Point2(0.5, 0.5)]
            corner_neighbors = VoronoiCells.corner_nearest_neighbor(points, rect)

            expected_neighbors = Dict(
                1 => [1, 2], 2 => [2], 3 => [3], 4 => [1]
            )

            @test corner_neighbors == expected_neighbors
        end
    end
end
