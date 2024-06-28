"""
    struct MUMPSSolver <: LinearSolver end

Wrapper of the MUMPS solver provided by MUMPS.jl
"""
mutable struct MUMPSSolver <: Gridap.Algebra.LinearSolver
    args::Tuple
    function MUMPSSolver(args...)
        return new(args)
    end
end

mutable struct MUMPSSymbolicSetup <: Gridap.Algebra.SymbolicSetup 
    args::Tuple
    function MUMPSSymbolicSetup(::AbstractMatrix, args...)
        return new(args)
    end
end

mutable struct MUMPSNumericalSetup{M} <: Gridap.Algebra.NumericalSetup
    mumps::M
    args::Tuple
end

function MUMPSNumericalSetup(mss::MUMPSSymbolicSetup, mat::AbstractMatrix)
    mumps = MUMPS.Mumps{eltype(mat)}(mss.args...)
    MUMPS.associate_matrix!(mumps, mat)
    MUMPS.factorize!(mumps)
    return MUMPSNumericalSetup{typeof(mumps)}(mumps, mss.args)
end

function Gridap.Algebra.symbolic_setup(ms::MUMPSSolver, mat::AbstractMatrix)
    MUMPSSymbolicSetup(mat, ms.args...)
end

function Gridap.Algebra.numerical_setup(mss::MUMPSSymbolicSetup, mat::AbstractMatrix)
    MUMPSNumericalSetup(mss, mat)
end

function Gridap.Algebra.numerical_setup!(ns::MUMPSNumericalSetup, mat::AbstractMatrix)
    MUMPS.finalize(ns.mumps)
    ns.mumps = MUMPS.Mumps{eltype(mat)}(ns.args...)
    MUMPS.associate_matrix!(ns.mumps, mat)
    MUMPS.factorize!(ns.mumps)
    ns
end

function Gridap.Algebra.solve!(
        x::AbstractVector, ns::MUMPSNumericalSetup, b::AbstractVector)
    MUMPS.associate_rhs!(ns.mumps, b)
    MUMPS.solve!(ns.mumps)
    x .= MUMPS.get_solution(ns.mumps)
    x
end