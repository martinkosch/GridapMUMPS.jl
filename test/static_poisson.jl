# Example adapted from https://github.com/gridap/Gridap.jl/blob/master/test/GridapTests/PoissonTests.jl for Gridap 18.02

using Test
using Gridap
import Gridap: ∇
using GridapMUMPS

domain = (0, 1, 0, 1)
partition = (4, 4)
model = CartesianDiscreteModel(domain, partition)
order = 2

const h = (domain[2] - domain[1]) / partition[1]
const γ = 10

labels = get_face_labeling(model)
add_tag_from_tags!(labels, "dirichlet", [1, 2, 5])
add_tag_from_tags!(labels, "neumann", [7, 8])
add_tag_from_tags!(labels, "nitsche", 6)

Ω = Triangulation(model)
Γn = BoundaryTriangulation(model, labels, tags = "neumann")
Γd = BoundaryTriangulation(model, labels, tags = "nitsche")

degree = order
dΩ = Measure(Ω, degree)
dΓn = Measure(Γn, degree)
dΓd = Measure(Γd, degree)

nn = get_normal_vector(Γn)
nd = get_normal_vector(Γd)

# Using automatic differentiation
u_scal(x) = x[1]^2 + x[2]
f_scal(x) = -Δ(u_scal)(x)

scalar_data = Dict{Symbol, Any}()
scalar_data[:valuetype] = Float64
scalar_data[:u] = u_scal
scalar_data[:f] = f_scal

# Using automatic differentiation
u_vec(x) = VectorValue(x[1]^2 + x[2], 4 * x[1] - x[2]^2)
f_vec(x) = -Δ(u_vec)(x)

vector_data = Dict{Symbol, Any}()
vector_data[:valuetype] = VectorValue{2, Float64}
vector_data[:u] = u_vec
vector_data[:f] = f_vec

for data in [vector_data, scalar_data]
    T = data[:valuetype]
    u = data[:u]
    f = data[:f]

    for domain_style in (ReferenceDomain(), PhysicalDomain())
        cell_fe = FiniteElements(domain_style, model, lagrangian, T, order)
        V = TestFESpace(Ω, cell_fe, dirichlet_tags = "dirichlet", labels = labels)
        U = TrialFESpace(V, u)

        uh = interpolate(u, U)

        function a(u, v)
            ∫(∇(v) ⊙ ∇(u)) * dΩ +
            ∫((γ / h) * v ⊙ u - v ⊙ (nd ⋅ ∇(u)) - (nd ⋅ ∇(v)) ⊙ u) * dΓd
        end

        function l(v)
            ∫(v ⊙ f) * dΩ +
            ∫(v ⊙ (nn ⋅ ∇(uh))) * dΓn +
            ∫((γ / h) * v ⊙ uh - (nd ⋅ ∇(v)) ⊙ u) * dΓd
        end

        op = AffineFEOperator(a, l, U, V)

        all_ls = [MUMPSSolver(mumps_unsymmetric, default_icntl, default_cntl64), LUSolver()]

        for ls in all_ls
            solver = LinearFESolver(ls)
            uh = solve(solver, op)

            e = u - uh

            l2(u) = sqrt(sum(∫(u ⊙ u) * dΩ))
            h1(u) = sqrt(sum(∫(u ⊙ u + ∇(u) ⊙ ∇(u)) * dΩ))

            el2 = l2(e)
            eh1 = h1(e)
            ul2 = l2(uh)
            uh1 = h1(uh)

            @test el2 / ul2 < 1.e-8
            @test eh1 / uh1 < 1.e-7
        end
    end
end