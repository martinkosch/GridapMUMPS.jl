using SafeTestsets
using Test
using MPI 

@safetestset "Static Poisson equation" begin
    include("static_poisson.jl")
end

@safetestset "Transient vector heat equation" begin
    include("heat_equation_vector.jl")
end

@safetestset "Code quality (Aqua.jl)" begin
    using Aqua, GridapMUMPS
    Aqua.test_all(GridapMUMPS; ambiguities = false)
end

MPI.Finalize()