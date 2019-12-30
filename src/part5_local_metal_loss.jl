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
cylic = CyclicService(170, "Meets Part 14")
x = Part5ComponentType("Straight Section of Piping, Eblow or Bend - No Structural Attachments", vessel_orientation="horizontal", material="Carbon and Low Alloy Steels", D=144.0,Lss=96.0,H=1440.0, NPS=3.0, design_temperature=100.0, units="lbs-in-psi")
part5_applicability = Part5AsessmentApplicability(x,design,toughness,cylic)

# Level 1 fit for service
# Data collection and requirments
units = "lbs-in-psi" # "lbs-in-psi" or "nmm-mm-mpa"
# Input Data
equipment_group = "piping" # "vessel", "tank"
flaw_location = "External" # "External","Internal"
Do = 3.5 # Outside Diameter
tnom = .3 # nominal or furnished thickness of the component adjusted for mill undertolerance as applicable.
trd = .3 # uniform thickness away from the local metal loss location established by thickness measurements at the time of the assessment.
D = Do - 2*(tnom) # inside diameter of the vessel.
FCAml = .05 # Future Corrosion Allowance applied to the region of metal loss.
FCA = .05 # Future Corrosion Allowance applied to the region away from the metal loss (see Annex 2C, paragraph 2C.2.8).
LOSS = 0 #the amount of uniform metal loss away from the local metal loss location at the time of the assessment.

# Adjust the FCA by internal and external as below
FCA_string = "Internal"  # "External","Internal"
if (FCA_string == "Internal")
Dml = D + (2*FCAml) # inside diameter of the shell corrected for ml FCA , as applicable.
elseif (FCA_string == "External")
    Dml = D # inside diameter of the shell corrected for ml FCA , as applicable.
end

# STEP 1 – Determine the CTP (see paragraph 5.3.3.2).
spacings = 0.5
# Flaw dimensions
s = 5.5 # longitudinal extent or length of the region of local metal loss based on future corroded thickness,
c = 1.5 # circumferential extent or length of the region of local metal loss (see Figure 5.2 and Figure 5.10), based on future corroded thickness, tc .
s2 = (s * 2) / spacings # maximum inspection boundary - longitudinal direction
c2 = (c * 2) / spacings # minimum inspection boundary - circumferential  direction
# Data grid
M1 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M2 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.100, 0.220, 0.280, 0.250, 0.240, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M3 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.215, 0.255, 0.215, 0.145, 0.275, 0.170, 0.240, 0.250, 0.250, 0.280, 0.290, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M4 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.170, 0.270, 0.190, 0.190, 0.285, 0.250, 0.225, 0.275, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M5 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M6 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
CTPGrid = hcat(M6,M5,M4,M3,M2,M1) # build in descending order
CTPGrid = rotl90(CTPGrid) # rotate to correct orientation
# Flaw-To-Major Structural Discontinuity Spacing
L1msd = [12.0]
L2msd = [12.0]
L3msd = [12.0]
L4msd = [12.0]
L5msd = [12.0]
Lmsd = minimum([L1msd,L2msd,L3msd,L4msd,L5msd])

@doc """
    CTP_Grid(CTPGrid::Array{Float64,2})
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
# STEP 2 – Determine the wall thickness to be used in the assessment using Equation (5.3) or Equation (5.4), as applicable.
tc = trd - LOSS - FCA # wall thickness away from the damaged area adjusted for LOSS and FCA , as applicable. # eq (5.3)
tc = trd - FCA # wall thickness away from the damaged area adjusted for LOSS and FCA , as applicable. # eq (5.4)
tc = .3
# STEP 3 – Determine the minimum measured thickness in the LTA, tmm , and the dimensions, s and c (see paragraph 5.3.3.2.b) for the CTP.
# s and c cetermined above
tmm = CTP_Grid(CTPGrid) # minimum measured thickness determined at the time of the inspection.

# STEP 4 – Determine the remaining thickness ratio using Equation (5.5) and the longitudinal flaw length parameter using Equation (5.6).
Rt = (tmm-FCA) / tc # remaining thickness ratio. # (5.5)
lambda = (1.285*s)/(sqrt(D*tc))

# STEP 5 – Check the limiting flaw size criteria; if the following requirements are satisfied, proceed to STEP 6; otherwise, the flaw is not acceptable per the Level 1 Assessment procedure.
@doc """
FlawSizeLimitCriteria(equipment_group::String,units::String)::Array{Int64}

Determine if the flaw is acceptable per level 1 criteria
    """ ->
function FlawSizeLimitCriteria(equipment_group::String,units::String)::Array{Int64}
    let test_1 = 0, test_2 = 0, test_3 =.0, test_4 = 0
        @assert any(equipment_group .== ["piping","vessel","tank"]) "Invalid input - select either: 'piping' or 'vessel' or 'tank'"
if (equipment_group == "piping" || equipment_group == "vessel" || equipment_group == "tank")
    if (Rt >= 0.20)
        print("eq 5.7 is Satisfied\n")
        test_1 = 1
    end
    if (Lmsd[1] >= 1.8*(sqrt(D*tc)))
        print("eq 5.10 is Satisfied\n")
        test_4 = 1
    end
end
if (equipment_group == "vessel" || equipment_group == "tank")
    if (units == "lbs-in-psi")
        if (tmm - FCAml >= 0.10)
            print("eq 5.8 is Satisfied\n")
            test_2 = 1
        end
    elseif (units == "nmm-mm-mpa")
        if (tmm - FCAml >=2.5)
            print("eq 5.8 is Satisfied\n")
            test_2 = 1
        end
    end
end
if (equipment_group == "piping")
    if (units == "lbs-in-psi")
        if (tmm - FCAml >=0.05)
            print("eq 5.9 is Satisfied\n")
            test_3 = 1
        end
    elseif (units == "nmm-mm-mpa")
        if (tmm - FCAml >=1.3)
            print("eq 5.9 is Satisfied\n")
            test_3 = 1
        end
    end
end
return level_1_satisfied = [test_1,test_2,test_3,test_4]
end # let end
end

x = FlawSizeLimitCriteria("vessel","lbs-in-psi")

@doc """
    FlawSizeLevel1Acceptance(x::Array{Int64})::Array{Int64}

Determine if the limiting flaw size criteria has met the level 1 requirments
""" ->
function FlawSizeLevel1Acceptance(x::Array{Int64},equipment_group::String)::Int64
    @assert any(equipment_group .== ["piping","vessel","tank"]) "Invalid input - select either: 'piping' or 'vessel' or 'tank'"
    let level_1_satisfied = 0
    # level 1
    if (sum([x[1],x[2],x[3],x[4]]) == 3)
        print("The criteria for level 1 assessment has been satisfied - proceed to STEP 6\n")
        level_1_satisfied = 1
    end
    if (sum([x[1],x[2],x[3],x[4]]) != 3)
        print("The criteria for level 1 assessment has not been satisfied - level 1 assessment failed\n")
        level_1_satisfied = 1
        if (x[1] == 0)
            print("eq 5.7 has not been Satisfied\n")
        end
        if (x[2] == 0 && (equipment_group == "vessel" || equipment_group == "tank"))
            print("(for vessels & tanks) eq 5.8 has not been Satisfied\n")
        end
        if (x[3] == 0 && equipment_group == "piping")
            print("(for piping)  eq 5.9 has not been Satisfied\n")
        end
        if (x[4] == 0)
            print("eq 5.10 has not been Satisfied\n")
        end
    end # not equal to end
    return level_1_satisfied
end # let end
end # function end



out = FlawSizeLevel1Acceptance(x,"vessel")

# STEP 6 – If the region of metal loss is categorized as an LTA (i.e. the LTA is not a groove), then proceed to STEP 7. If the region of metal loss is categorized as a groove and Equation (5.11) is satisfied,
# then proceed to STEP 7. Otherwise, the Level 1 assessment is not satisfied and proceed to paragraph 5.4.2.3.


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


# Piping
if (part5_applicability[1] == 1) # begin level 1 assessment
    print("Begin part 5 - Level 1 assessment - applicability criteria has been met")





end # end piping level 1
