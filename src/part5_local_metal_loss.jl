# PART 5 – ASSESSMENT OF LOCAL METAL LOSS

# Determine Asessment Applicability
""" Determine the assessment applicability
@doc DesignCodeCriteria
@doc MaterialToughness
@doc CyclicService
@doc Part5ComponentTypeAssessmentApplicability
"""
design = DesignCodeCriteria("ASME B31.3 Piping Code")
toughness = MaterialToughness("Certain")
cylic = CyclicService(100, "Meets Part 14")
x = Part5ComponentTypeAssessmentApplicability("Cylindrical Vessel", vessel_orientation="vertical", material="Carbon and Low Alloy Steels", D=144.0,Lss=96.0,H=1440.0, NPS=0.0, design_temperature=0.0, units="lbs-in-psi")
part5_applicability = Part5Level1Level2Applicability(x,design,toughness,cylic)
