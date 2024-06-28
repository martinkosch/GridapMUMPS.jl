module GridapMUMPS

using MUMPS
import MPI
import SparseArrays

import Gridap

export MUMPSSolver

# Re-export MUMPS keywords
export mumps_unsymmetric
export mumps_definite	
export mumps_symmetric	
export default_icntl	
export default_cntl32	
export default_cntl64

function __init__()
    MPI.Init()
end

include("solver.jl")

end
