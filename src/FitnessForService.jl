VERSION >= v"0.0.2" && __precompile__(true)

module FitnessForService

export
    DesignCodeCriteria, MaterialToughness, CyclicService, Part5ComponentType, Part5AsessmentApplicability

    include("part5_LTA_functions.jl")
    include("applicability.jl")
    include("data_grid_functions.jl")
    include("thickness_MAWP_stress_equations_for_FFS.jl")
    include("part5_local_metal_loss_assessment.jl")

end
