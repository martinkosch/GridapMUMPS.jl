# GridapMUMPS.jl

<!---[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://martinkosch.github.io/GridapMUMPS.jl/dev/)--->
[![Build Status](https://github.com/martinkosch/GridapMUMPS.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/martinkosch/GridapMUMPS.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/martinkosch/GridapMUMPS.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/martinkosch/GridapMUMPS.jl)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

A tiny extension to the FEM library [Gridap.jl](https://github.com/gridap/Gridap.jl) for using MUMPS as a sparse LU solver. 
Examples of how to use this package can be found in the test folder. 

GridapMUMPS.jl should work out-of-the-box for Linux systems, while additional setup might be needed for other OS (see documentation of [MUMPS.jl](https://github.com/JuliaSmoothOptimizers/MUMPS.jl)).

The package has only be tested for serial problems so far. For distributed problems, [GridapPETSc.jl](https://github.com/gridap/GridapPETSc.jl) or [GridapPardiso.jl](https://github.com/gridap/GridapPardiso.jl) are potentially better suited. 
