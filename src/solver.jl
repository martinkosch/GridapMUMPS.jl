"""
    struct MUMPSSolver <: LinearSolver end

Wrapper of the MUMPS solver provided by MUMPS.jl
"""
struct MUMPSSolver <: Gridap.Algebra.LinearSolver
    args::Tuple
    function MUMPSSolver(args...)
        return new(args)
    end
end

mutable struct MUMPSSymbolicSetup{M} <: Gridap.Algebra.SymbolicSetup
    mumps::M

    function MUMPSSymbolicSetup(mat::AbstractMatrix, args...; finalize_MPI::Bool = false)
        MPI.Init()
        mumps = MUMPS.Mumps{eltype(mat)}(args...)
        ret = new{typeof(mumps)}(mumps)
        finalizer((args...) -> release_handle(args...; finalize_MPI), ret)
        return ret
    end
end

function release_handle(mss::MUMPSSymbolicSetup; finalize_MPI::Bool = false)
    MUMPS.finalize(mss.mumps)
    finalize_MPI && MPI.Finalize()
    return nothing
end

mutable struct MUMPSNumericalSetup{M} <: Gridap.Algebra.NumericalSetup
    mumps::M
end

function MUMPSNumericalSetup(mss::MUMPSSymbolicSetup, mat::AbstractMatrix)
    mumps = mss.mumps
    MUMPS.associate_matrix!(mumps, mat)
    MUMPS.factorize!(mumps)
    return MUMPSNumericalSetup{typeof(mumps)}(mumps)
end

function Gridap.Algebra.symbolic_setup(ms::MUMPSSolver, mat::AbstractMatrix)
    MUMPSSymbolicSetup(mat, ms.args...)
end

function Gridap.Algebra.numerical_setup(mss::MUMPSSymbolicSetup, mat::AbstractMatrix)
    MUMPSNumericalSetup(mss, mat)
end

function Gridap.Algebra.numerical_setup!(ns::MUMPSNumericalSetup, mat::AbstractMatrix)
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