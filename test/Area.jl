using VoronoiCells
using GeometryBasics
import Deldir
using Test


@testset "Area" begin
    Random.seed!(1)
    points = [Point2(rand(), rand()) for _ in 1:5]

    @testset "Area of Voronoi cells sum to area of window" begin
        @testset "Unit rectangle" begin
            rect = Rectangle(Point2(0, 0), Point2(1, 1))
            tess = voronoicells(points, rect)

            cell_area = voronoiarea(tess)

            @test sum(cell_area) ≈ 1
        end

        @testset "Random rectangle" begin
            rect = Rectangle(Point2(-rand(), -rand()), Point2(1 + rand(), 1 + rand()))
            tess = voronoicells(points, rect)

            cell_area = voronoiarea(tess)

            @test sum(cell_area) ≈ VoronoiCells.area(rect)
        end
    end

    @testset "Area of Voronoi cells are the same as in Deldir" begin
        rect = Rectangle(Point2(0, 0), Point2(1, 1))
        tess = voronoicells(points, rect)

        cell_area1 = VoronoiCells.voronoiarea(tess)

        x = map(getx, points)
        y = map(gety, points)
        rw = [left(rect), right(rect), lower(rect), upper(rect)]
        cell_area2 = Deldir.voronoiarea(x, y, rw)

        @test cell_area1 ≈ cell_area2
    end
end
