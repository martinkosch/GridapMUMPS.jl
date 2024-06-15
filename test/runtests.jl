using GridapMUMPS
using Test
using Aqua

@testset "GridapMUMPS.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(GridapMUMPS)
    end
    # Write your tests here.
end
