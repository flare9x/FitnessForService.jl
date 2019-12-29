VERSION >= v"0.0.2" && __precompile__(true)

module FitnessForService

export
    DesignCodeCriteria, MaterialToughness, CyclicService, Part5ComponentTypeAssessmentApplicability

    include("applicability.jl")
    include("part5_local_metal_loss.jl")

end
