VERSION >= v"0.0.2" && __precompile__(true)

module FitnessForService

export
    DesignCodeCriteria, MaterialToughness, CyclicService, Part5ComponentType, Part5AsessmentApplicability

    include("applicability.jl")
    include("part5_local_metal_loss.jl")

end
