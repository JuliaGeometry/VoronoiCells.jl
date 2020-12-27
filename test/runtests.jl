using Deldir
using Test

import DataFrames


@testset "Deldir output are expected dataframes" begin
    N = rand(5:15)
    x = rand(N)
    y = rand(N)
    del, vor, summ = deldir(x, y)

    @test DataFrames.names(del) == ["x1", "y1", "x2", "y2", "ind1", "ind2"]

    @test DataFrames.names(vor) == ["x1", "y1", "x2", "y2", "ind1", "ind2", "bp1", "bp2", "thirdv1", "thirdv2"]

    @test DataFrames.names(summ) == ["x", "y", "ntri", "del_area", "n_tside", "nbpt", "vor_area"]
    @test DataFrames.nrow(summ) == N

    @test summ[!, :x] == x
    @test summ[!, :y] == y
end


@testset "Delaunay triangle corners are indexed correctly" begin
    N = rand(5:15)
    x = rand(N)
    y = rand(N)
    del = deldir(x, y)[1]

    @test del[!, :x1] == x[del[!, :ind1]]
    @test del[!, :x2] == x[del[!, :ind2]]

    @test del[!, :y1] == y[del[!, :ind1]]
    @test del[!, :y2] == y[del[!, :ind2]]
end


@testset "Line segments of Voronoi cells are within window" begin
    N = rand(5:15)
    x = rand(N)
    y = rand(N)
    vor = deldir(x, y)[2]

    @test all(0 .<= vor[!, :x1] .<= 1)
    @test all(0 .<= vor[!, :y1] .<= 1)
    @test all(0 .<= vor[!, :x2] .<= 1)
    @test all(0 .<= vor[!, :y2] .<= 1)
end


@testset "Area of Voronoi cells sum to area of window" begin
    N = rand(5:15)
    x = rand(N)
    y = rand(N)
    A = voronoiarea(x, y)

    @test sum(A) ≈ 1 atol = 0.001

    rw = [-rand(); 1 + rand(); -rand(); 1 + rand()]
    rw_area = (rw[2] - rw[1])*(rw[4] - rw[3])

    A = voronoiarea(x, y, rw)

    @test sum(A) ≈ rw_area atol = 0.001
end


@testset "Particular outputs" begin
    @testset "Simple point pattern" begin
        x = [0.25; 0.25; 0.75; 0.75]
        y = [0.25; 0.75; 0.25; 0.75]

        del, vor, summ = deldir(x, y)

        # Expected output is from R's deldir
        expected_del = DataFrames.DataFrame(
            x1 = [0.75; 0.75; 0.75; 0.25; 0.25],
            y1 = [0.25; 0.75; 0.75; 0.75; 0.75],
            x2 = [0.25; 0.25; 0.75; 0.25; 0.75],
            y2 = [0.25; 0.25; 0.25; 0.25; 0.75],
            ind1 = [3; 4; 4; 2; 2],
            ind2 = [1; 1; 3; 1; 4]
        )

        @test del == expected_del

        expected_vor = DataFrames.DataFrame(
            x1 = [0.5; 0.5; 0.5; 0.0; 0.5],
            y1 = [0.5; 0.5; 0.5; 0.5; 0.5],
            x2 = [0.5; 0.5; 1.0; 0.5; 0.5],
            y2 = [0.0; 0.5; 0.5; 0.5; 1.0],
            ind1 = [3; 4; 4; 2; 2],
            ind2 = [1; 1; 3; 1; 4],
            bp1 = [false; false; false; true; false],
            bp2 = [true; false; true; false; true],
            thirdv1 = [4; 2; 1; -2; 1],
            thirdv2 = [-1; 3; -4; 4; -3]
        )

        # There is no ≈ for DataFrames
        @test vor[!, "x1"] ≈ [0.5; 0.5; 0.5; 0.0; 0.5]
        @test vor[!, "y1"] ≈ [0.5; 0.5; 0.5; 0.5; 0.5]
        @test vor[!, "x2"] ≈ [0.5; 0.5; 1.0; 0.5; 0.5]
        @test vor[!, "y2"] ≈ [0.0; 0.5; 0.5; 0.5; 1.0]

        @test vor[!, ["ind1", "ind2", "bp1", "bp2", "thirdv1", "thirdv2"]] ==
            expected_vor[!, ["ind1", "ind2", "bp1", "bp2", "thirdv1", "thirdv2"]]

        expected_summ = DataFrames.DataFrame(
            x = [0.25; 0.25; 0.75; 0.75],
            y = [0.25; 0.75; 0.25; 0.75],
            ntri = [2; 1; 1; 2],
            del_area = [0.08333; 0.04166; 0.04166; 0.08333],
            n_tside = [3; 2; 2; 3],
            nbpt = [2; 2; 2; 2],
            vor_area = [0.25; 0.25; 0.25; 0.25]
        )

        # There is no ≈ for DataFrames
        @test summ[!, "del_area"] ≈ [0.08333; 0.04166; 0.04166; 0.08333] atol = 0.001
        @test summ[!, "vor_area"] ≈ [0.25; 0.25; 0.25; 0.25]
        @test summ[!, ["ntri", "n_tside", "nbpt"]] == expected_summ[!, ["ntri", "n_tside", "nbpt"]]
    end

    @testset "voronoiarea and deldir gives the same Voronoi area" begin
        # Points that are *not* sorted. From R documentation
        x = [2.3, 3.0, 7.0, 1.0, 3.0, 8.0]
        y = [2.3, 3.0, 2.0, 5.0, 8.0, 9.0]

        rw = [0.0; 10; 0; 10]
        A = voronoiarea(x, y, rw)

        @test A ≈ [11.737; 10.739; 26.839; 9.503; 21.306; 19.877] atol = 0.001

        summary = deldir(x, y, rw)[3]
        @test summary[!, "vor_area"] == A
    end

    @testset "Edges for plotting" begin
        x = [0.25; 0.75; 0.5]
        y = [0.25; 0.25; 0.75]

        del, vor, _ = deldir(x, y)

        Dx, Dy = edges(del)

        @test filter(!isnan, Dx) == [0.75; 0.25; 0.5; 0.25; 0.5; 0.75]
        @test filter(!isnan, Dy) == [0.25; 0.25; 0.75; 0.25; 0.75; 0.25]

        Vx, Vy = edges(vor)

        @test filter(!isnan, Vx) == [0.5; 0.5; 0.0; 0.5; 0.5; 1.0]
        @test filter(!isnan, Vy) ≈ [0.4375; 0.0; 0.6875; 0.4375; 0.4375; 0.6875] atol = 0.001
    end
end


@testset "Errors with inappropriate input" begin
    @testset "Error when points are outside window" begin
        x = [-rand(); rand()]
        y = rand(2)
    
        @test_throws ErrorException deldir(x, y)
    end
    
    @testset "Error when number of x's and y's are not equal" begin
        x = rand(rand(2:7))
        y = rand(rand(8:12))
    
        @test_throws DimensionMismatch deldir(x, y)
    end
end


@testset "Fortran errors" begin
    @testset "Triangle problems" begin
        # Data extracted from deldir::deldir documentation in R
        # In Fortran code used in Deldir_jll we have error code number 12, but in the current 
        # version in the R package we get a more elaborate error mesage
        x = [0.21543139749966067; 0.18676067638651864; 0.12941923416171849; 0.37808260371144037; 0.08619595005015318; 0.15808995527500894]
        y = [1.0000000000000000; 0.9981701480225297; 0.9945104441215969; 0.4421766790515620; 0.9323236302262247; 0.9963402960710632]

        @test_throws ErrorException deldir(x, y)
    end

    @testset "Error number 4" begin
        # Data from GitHub issue #17
        x = [0.4, 0.3, 0.5, 0.2406, 0.2964, 0.5498, 0.2332, 0.3, 0.5041, 0.0824, 0.0594, 0.0126, 0.4385, 0.3575, 0.7737, 0.1, 0.1997, 0.6806, 0.8219, 0.0098, 0.4568, 0.0136]
        y = [0.3856, 0.5588, 0.0, 0.0725, 0.0433, 0.0025, 0.0771, 0.2124, 0.0, 0.2251, 0.7363, 0.3885, 0.0038, 0.0207, 0.0816, 0.2124, 0.1002, 0.0338, 0.3856, 0.4017, 0.0019, 0.616]

        @test_logs (:info, "Fortran error 4. Increasing madj to 24") deldir(x, y)
    end
end


@testset "Sort points" begin
    # Data extracted from deldir::deldir documentation in R where the points *are* shuffled. 
    # Also used to test errors
    x = [0.21543139749966067; 0.18676067638651864; 0.12941923416171849; 0.37808260371144037; 0.08619595005015318; 0.15808995527500894]
    y = [1.0000000000000000; 0.9981701480225297; 0.9945104441215969; 0.4421766790515620; 0.9323236302262247; 0.9963402960710632]

    x_copy = deepcopy(x)
    y_copy = deepcopy(y)

    rw = [0.0; 1.0; 0.0; 1.0]
    indices, reverse_indices = Deldir.sortperm_points!(x_copy, y_copy, rw)

    @test x == x_copy[indices]
    @test x[reverse_indices] == x_copy

    @test y == y_copy[indices]
    @test y[reverse_indices] == y_copy
end
