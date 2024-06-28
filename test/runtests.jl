using SafeTestsets
using Test

@safetestset "Code quality (Aqua.jl)" begin
    using Aqua, GridapMUMPS
    Aqua.test_all(GridapMUMPS; ambiguities = false)
end

@safetestset "Static Poisson equation" begin
    include("static_poisson.jl")
end

@safetestset "Transient vector heat equation" begin
    include("heat_equation_vector.jl")
end
