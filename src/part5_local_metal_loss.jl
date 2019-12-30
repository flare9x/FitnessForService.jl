# PART 5 – ASSESSMENT OF LOCAL METAL LOSS

# Determine Asessment Applicability
""" Determine the assessment applicability
@doc DesignCodeCriteria
@doc MaterialToughness
@doc CyclicService
@doc Part5ComponentType
"""
design = DesignCodeCriteria("ASME B31.3 Piping Code")
toughness = MaterialToughness("Certain")
cylic = CyclicService(100, "Meets Part 14")
x = Part5ComponentType("Straight Section of Piping, Eblow or Bend - No Structural Attachments", vessel_orientation="horizontal", material="Carbon and Low Alloy Steels", D=144.0,Lss=96.0,H=1440.0, NPS=3.0, design_temperature=100.0, units="lbs-in-psi")
part5_applicability = Part5AsessmentApplicability(x,design,toughness,cylic)

# Level 1 fit for service
# Data collection and requirments

# CTP Grid
spacings = 0.5
s = 5.5 # longitudinal extent or length of the region of local metal loss based on future corroded thickness,
c = 1.5 # circumferential extent or length of the region of local metal loss (see Figure 5.2 and Figure 5.10), based on future corroded thickness, tc .
s2 = (s * 2) / spacings # maximum inspection boundary - longitudinal direction
c2 = (c * 2) / spacings # minimum inspection boundary - circumferential  direction
M1 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M2 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.100, 0.220, 0.280, 0.250, 0.240, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M3 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.215, 0.255, 0.215, 0.145, 0.275, 0.170, 0.240, 0.250, 0.250, 0.280, 0.290, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M4 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.170, 0.270, 0.190, 0.190, 0.285, 0.250, 0.225, 0.275, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M5 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M6 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
CTPGrid = hcat(M6,M5,M4,M3,M2,M1) # build in descending order
CTPGrid = rotl90(CTPGrid) # rotate to correct orientation

@doc """
    CTP_Grid(CTP_grid::Matrix{T})where {T<:Real}
"""
function CTP_Grid(CTPGrid::Array{Float64,2})
# Labels for plotting
#=circumferential_plane_index = Int64.(collect(1:1:s2)) # collect auto rounds - no need to write code to correct
circ_label = fill("C",length(circumferential_plane_index))
circ_index_labels = map(string, circ_label, circumferential_plane_index) # join integer and string to string
circ_spacing_index = collect(0:0.5:(length(circumferential_plane_index)/2)-spacings)
longitudinal_plane_index = Int64.(collect(1:1:c2)) # collect auto rounds - no need to write code to correct
long_label = fill("M",length(longitudinal_plane_index))
long_index_labels = map(string, long_label, longitudinal_plane_index) # join integer and string to string
long_spacing_index = collect(0:0.5:(length(longitudinal_plane_index)/2)-spacings)
=#

# Determine CTPs (Critical Thickness Profiles)
Circumferential_CTP = zeros(size(CTPGrid,1)) # initialize output
Longitudinal_CTP = zeros(size(CTPGrid,2)) # initialize output
col_index = [1:size(CTPGrid,2);]
row_index = [1:size(CTPGrid,1);]
@inbounds for i in 1:size(CTPGrid,1)
    Circumferential_CTP[i] = minimum(CTPGrid[row_index[i],1:size(CTPGrid,2)])
end
@inbounds for i in 1:size(CTPGrid,2)
    Longitudinal_CTP[i] = minimum(CTPGrid[1:size(CTPGrid,1),col_index[i]:size(CTPGrid,2)])
end

# find tmm
minC_CTP = minimum(Circumferential_CTP)
minL_CTP = minimum(Longitudinal_CTP)
tmm = minimum([minC_CTP,minL_CTP]) # minimum measured thickness determined at the time of the inspection.
return tmm
end


tmm = CTP_Grid(CTPGrid)

flaw_location = "External" # "External","Internal"
Do = 3.5 # Outside Diameter
tnom = .3 # nominal or furnished thickness of the component adjusted for mill undertolerance as applicable.
trd = .3 # uniform thickness away from the local metal loss location established by thickness measurements at the time of the assessment.
D = Do - 2*(tnom) # inside diameter of the vessel.
FCAml = .05 # Future Corrosion Allowance applied to the region of metal loss.
FCA = .05 # Future Corrosion Allowance applied to the region away from the metal loss (see Annex 2C, paragraph 2C.2.8).

FCA_string = "Internal"  # "External","Internal"
if (FCA_string == "Internal")
Dml = D + (2*FCAml) # inside diameter of the shell corrected for ml FCA , as applicable.
elseif (FCA_string == "External")
    Dml = D # inside diameter of the shell corrected for ml FCA , as applicable.
end

tc = trd - FCA # wall thickness away from the damaged area adjusted for LOSS and FCA , as applicable.
Rt = (tmm-FCA) / tc # remaining thickness ratio.
RSFa = .9 # allowable remaining strength factor (see Part 2).
if (Rt < RSFa)
Q = round(1.123*((((1-Rt)/(1-Rt/RSFa))^2-1)^.5),digits=2) # factor used to determine the length for thickness averaging based on an allowable Remaining Strength Factor (see Part 2) and the remaining thickness ratio, Rt (see Table 4.8).
elseif (Rt >= RSFa)
    Q = 50.0
end
L = Q*(sqrt(Dml*tc)) # length for thickness averaging along the shell.

# If visual inspection or NDE methods are utilized to quantify the metal loss, an alternative spacing can be used as long as the metal loss on the component can be adequately characterized.
if (flaw_location == "Internal")
    Ls = minimum([L,(2*trd)]) # recommended spacing of thickness readings
    print("Recommended spacing of thickness readings = ",Ls)
elseif (flaw_location == "External")
    print("Can Determine alterante spacing providing component can be adequately characterized - Using Spacing = ", spacings)
end

@doc """
    CTP_Grid
"""



# Application Construction Codes
@doc """
    DesignCodeCriteria(x::String)::Int64

Check code meets API 579 construction codes

Choose from: ASME B&PV Code, Section VIII, Division 1,ASME B&PV Code, Section VIII, Division 2,ASME B&PV Code, Section I,ASME B31.1 Piping Code,ASME B31.3 Piping Code,ASME B31.4 Piping Code,
"ASME B31.8 Piping Code,ASME B31.12 Piping Code,API Std 650,API Std 620,API Std 530,Other Recognized Codes and Standards
""" ->
function DesignCodeCriteria(x::String)::Int64
    # reference data
    let codes = ["ASME B&PV Code, Section VIII, Division 1","ASME B&PV Code, Section VIII, Division 2","ASME B&PV Code, Section I","ASME B31.1 Piping Code","ASME B31.3 Piping Code","ASME B31.4 Piping Code",
    "ASME B31.8 Piping Code","ASME B31.12 Piping Code","API Std 650","API Std 620","API Std 530","Other Recognized Codes and Standards"]
    if any(x .== codes[1:length(codes)-1]) == 1
        print("Condition Satisfied - Code = ",x,"\n")
        design_code_criteria = 1
    elseif any(x .== codes) == 0
        print("Condition Not Satisfied\n")
        print("Check spelling else code not applicable, see API 579 2016 1.2 Scope sections 1.2.2 & 1.2.3\n")
        design_code_criteria = 0
    elseif (x == "Other Recognized Codes and Standards")
        print("For Other Recognized Codes and Standards - See conditions stated in API 579 2016 1.2 Scope sections 1.2.2 & 1.2.3.\n")
        design_code_criteria = 0
        end
    return design_code_criteria
end # let end
end




# Piping
if (part5_applicability[1] == 1) # begin level 1 assessment
    print("Begin part 5 - Level 1 assessment - applicability criteria has been met")





end # end piping level 1
