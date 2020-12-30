using VoronoiCells
using GeometryBasics
import Random

@testset "Rectangles" begin
    @testset "Construct Rectangles" begin
        @testset "Construct with canonical constructor" begin
            rect = Rectangle(0, 1, 0, 1)
            @test isa(rect, Rectangle)
        end
    
        @testset "Construct with Points" begin
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
    
    
    @testset "Map points between recangles" begin
        Random.seed!(1337)
        points = [GeometryBasics.Point2(rand(), rand()) for _ in 1:3]
    
        from_rect = Rectangle(0, 1, 0, 1)
        to_rect = Rectangle(0, 2, 0, 2)
    
        transformed_points = map_rectangle(points, from_rect, to_rect)
        double_transformed_points = map_rectangle(transformed_points, to_rect, from_rect)
    
        @test all(points .== double_transformed_points)
    end
    
    
    @testset "Error mapping points outside rectangle" begin
        points = [GeometryBasics.Point2(-1, 0)]
    
        from_rect = Rectangle(0, 1, 0, 1)
        to_rect = Rectangle(0, 2, 0, 2)
    
        @test_throws ErrorException map_rectangle(points, from_rect, to_rect)
    end
end
