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

# For all assessments - determine the inspection data grid
M1 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M2 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.100, 0.220, 0.280, 0.250, 0.240, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M3 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.215, 0.255, 0.215, 0.145, 0.275, 0.170, 0.240, 0.250, 0.250, 0.280, 0.290, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M4 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.170, 0.270, 0.190, 0.190, 0.285, 0.250, 0.225, 0.275, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M5 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M6 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
CTPGrid = hcat(M6,M5,M4,M3,M2,M1) # build in descending order
CTPGrid = rotl90(CTPGrid) # rotate to correct orientation

# Level 1 fit for service
@doc """
Part5LTALevel1(x::Array{Int64};equipment_group::String="",component_type::String="",flaw_location::String="",metal_loss_categorization::String="",units::String="",tnom::Float64=0.0,
    trd::Float64=0.0,FCA::Float64=0.0,FCAml::Float64=0.0,LOSS::Float64=0.0,Do::Float64=0.0,Do::Float64=0.0,P::Float64=0.0,S::Float64=0.0,E::Float64=0.0,MA::Float64=0.0,Yb31::Float64=0.0,
    tsl::Float64=0.0,spacings::Float64=0.0,L1msd::Float64=0.0,L2msd::Float64=0.0,L3msd::Float64=0.0,L4msd::Float64=0.0,L5msd::Float64=0.0,s::Float64=0.0,c::Float64=0.0)

    Variables\n
    equipment_group = "piping" # "vessel", "tank"\n
    component_type = "cylindrical shells" # "cylindrical shells", "conical shells", "pipe elbows", for anything other enter ""\n
    flaw_location = "external" # "External","Internal"\n
    metal_loss_categorization = "groove" # "LTA" or "groove"\n
    units = "lbs-in-psi" # "lbs-in-psi" or "nmm-mm-mpa"\n
    tnom = .3 # nominal or furnished thickness of the component adjusted for mill undertolerance as applicable.\n
    trd = .3 # uniform thickness away from the local metal loss location established by thickness measurements at the time of the assessment.\n
    FCAml = .05 # Future Corrosion Allowance applied to the region of metal loss.\n
    FCA = .05 # Future Corrosion Allowance applied to the region away from the metal loss (see Annex 2C, paragraph 2C.2.8).\n
    LOSS = 0 #the amount of uniform metal loss away from the local metal loss location at the time of the assessment.\n
    Do = 3.5 # Outside Diameter
    P = 1480 # internal design pressure.
    S = 20000 # allowable stress.
    E = 1.0 # weld joint efficiency or quality factor from the original construction code, if unknown use 0.7.
    MA = 0 # mechanical allowances (thread or groove depth); for threaded components, the nominal thread depth (dimension h of ASME B.1.20.1) shall apply.
    Yb31 = 0.4 # coefficient from ASME B31 Piping codes used for determining the pipe wall thickness, the coefficient can be determined from the following table that is valid for tmin < Do / 6 Annex 2C .
    t = trd # thickness of the shell or pipe adjusted for mill tolerance, LOSS and FCA , or cylinder thickness at a conical transition for a junction reinforcement calculation adjusted for mill tolerance, LOSS and FCA , as applicable.
    tsl = 0 # supplemental thickness for mechanical loads other than pressure that result in longitudinal stress; this thickness is usually obtained from the results of a weight case in a stress analysis of the piping system (see paragraph 2C.2.7).
    spacings = 0.5 # spacings determine by visual inspection to adequately ccategorizse the corrosion
    L1msd = [12.0] # distance to the nearest major structural discontinuity.
    L2msd = [12.0] # distance to the nearest major structural discontinuity.
    L3msd = [12.0] # distance to the nearest major structural discontinuity.
    L4msd = [12.0] # distance to the nearest major structural discontinuity.
    L5msd = [12.0] # distance to the nearest major structural discontinuity.
    # Flaw dimensions
    s = 5.5 # longitudinal extent or length of the region of local metal loss based on future corroded thickness,
    c = 1.5 # circumferential extent or length of the region of local metal loss (see Figure 5.2 and Figure 5.10), based on future corroded thickness, tc .

"""->
equipment_group = "piping" # "vessel", "tank"
component_type = "cylindrical shells" # "cylindrical shells", "conical shells", "pipe elbows", for anything other enter ""
flaw_location = "external" # "External","Internal"
metal_loss_categorization = "LTA" # "LTA" or "groove"
units = "lbs-in-psi" # "lbs-in-psi" or "nmm-mm-mpa"
tnom = .3 # nominal or furnished thickness of the component adjusted for mill undertolerance as applicable.
trd = .3 # uniform thickness away from the local metal loss location established by thickness measurements at the time of the assessment.
FCAml = .05 # Future Corrosion Allowance applied to the region of metal loss.
FCA = .05 # Future Corrosion Allowance applied to the region away from the metal loss (see Annex 2C, paragraph 2C.2.8).
LOSS = 0.0 #the amount of uniform metal loss away from the local metal loss location at the time of the assessment.
Do = 3.5 # Outside Diameter
P = 1480.0 # internal design pressure.
S = 20000.0 # allowable stress.
E = 1.0 # weld joint efficiency or quality factor from the original construction code, if unknown use 0.7.
MA = 0.0 # mechanical allowances (thread or groove depth); for threaded components, the nominal thread depth (dimension h of ASME B.1.20.1) shall apply.
Yb31 = 0.4 # coefficient from ASME B31 Piping codes used for determining the pipe wall thickness, the coefficient can be determined from the following table that is valid for tmin < Do / 6 Annex 2C .
t = trd # thickness of the shell or pipe adjusted for mill tolerance, LOSS and FCA , or cylinder thickness at a conical transition for a junction reinforcement calculation adjusted for mill tolerance, LOSS and FCA , as applicable.
tsl = 0.0 # supplemental thickness for mechanical loads other than pressure that result in longitudinal stress; this thickness is usually obtained from the results of a weight case in a stress analysis of the piping system (see paragraph 2C.2.7).
spacings = 0.5 # spacings determine by visual inspection to adequately ccategorizse the corrosion
# Flaw dimensions
s = 5.5 # longitudinal extent or length of the region of local metal loss based on future corroded thickness,
c = 1.5 # circumferential extent or length of the region of local metal loss (see Figure 5.2 and Figure 5.10), based on future corroded thickness, tc .

function Part5LTALevel1(x::Array{Int64};equipment_group::String="piping",component_type::String="",flaw_location::String="",metal_loss_categorization::String="",units::String="",tnom::Float64=0.0,
    trd::Float64=0.0,FCA::Float64=0.0,FCAml::Float64=0.0,LOSS::Float64=0.0,Do::Float64=0.0,Do::Float64=0.0,P::Float64=0.0,S::Float64=0.0,E::Float64=0.0,MA::Float64=0.0,Yb31::Float64=0.0,
    tsl::Float64=0.0,spacings::Float64=0.0,L1msd::Float64=0.0,L2msd::Float64=0.0,L3msd::Float64=0.0,L4msd::Float64=0.0,L5msd::Float64=0.0,s::Float64=0.0,c::Float64=0.0)
    @assert any(equipment_group .== ["piping", "vessel", "tank"]) "Invalid input: please enter either: 'piping','vessel','tank' "
    @assert any(component_type .== ["cylindrical shell", "conical shell", "pipe elbow",""]) "Invalid input: please enter either: 'cylindrical shells', 'conical shell', 'pipe elbow', for anything other than enter '' "
    @assert any(flaw_location .== ["external", "internal"]) "Invalid input: please enter either: 'external shells', 'internal shells' "
    @assert any(metal_loss_categorization .== ["LTA", "groove"]) "Invalid input: please enter either: 'LTA', 'groove' "
    @assert any(metal_loss_categorization .== ["lbs-in-psi", "nmm-mm-mpa"]) "Invalid input: please enter either: 'lbs-in-psi', 'nmm-mm-mpa' "

# Flaw-To-Major Structural Discontinuity Spacing
Lmsd = minimum([L1msd,L2msd,L3msd,L4msd,L5msd])

# Adjust the FCA by internal and external as below
FCA_string = "internal"  # "External","Internal"
if (FCA_string == "internal")
Dml = D + (2*FCAml) # inside diameter of the shell corrected for ml FCA , as applicable.
elseif (FCA_string == "external")
    Dml = D # inside diameter of the shell corrected for ml FCA , as applicable.
end

# STEP 1 – Determine the CTP (see paragraph 5.3.3.2).
# Grid is the same for level 1,2,3 therefore used as input for a function - data grid function returns tmm see data_grids.jl
# Flaw dimensions
#=
s = 5.5 # longitudinal extent or length of the region of local metal loss based on future corroded thickness,
c = 1.5 # circumferential extent or length of the region of local metal loss (see Figure 5.2 and Figure 5.10), based on future corroded thickness, tc .
s2 = (s * 2) / spacings # maximum inspection boundary - longitudinal direction
c2 = (c * 2) / spacings # minimum inspection boundary - circumferential  direction
=#

# STEP 2 – Determine the wall thickness to be used in the assessment using Equation (5.3) or Equation (5.4), as applicable.
tc = trd - LOSS - FCA # wall thickness away from the damaged area adjusted for LOSS and FCA , as applicable. # eq (5.3)
tc = trd - FCA # wall thickness away from the damaged area adjusted for LOSS and FCA , as applicable. # eq (5.4)

# STEP 3 – Determine the minimum measured thickness in the LTA, tmm , and the dimensions, s and c (see paragraph 5.3.3.2.b) for the CTP.
# s and c cetermined above
tmm = CTP_Grid(CTPGrid) # minimum measured thickness determined at the time of the inspection.

# STEP 4 – Determine the remaining thickness ratio using Equation (5.5) and the longitudinal flaw length parameter using Equation (5.6).
Rt = (tmm-FCA) / tc # remaining thickness ratio. # (5.5)
lambda = (1.285*s)/(sqrt(D*tc)) # longitudinal flaw length parameter eq (5.6)

# STEP 5 – Check the limiting flaw size criteria; if the following requirements are satisfied, proceed to STEP 6; otherwise, the flaw is not acceptable per the Level 1 Assessment procedure.
x = Part5LTAFlawSizeLimitCriteria(equipment_group,units)
flaw_size_accept = Part5LTAFlawSizeLevel1Acceptance(x,equipment_group)

# STEP 6 – If the region of metal loss is categorized as an LTA (i.e. the LTA is not a groove), then proceed to STEP 7. If the region of metal loss is categorized as a groove and Equation (5.11) is satisfied,
# then proceed to STEP 7. Otherwise, the Level 1 assessment is not satisfied and proceed to paragraph 5.4.2.3.
if (flaw_size_accept == 1) # begin Step 6 - Flaw size criteria met
    if (metal_loss_categorization == "groove" && (gr/(1-Rt)*tc) >= 0.5)
         print("Groove meets equation 5.11 - Proceed to STEP 7")
     elseif (metal_loss_categorization == "LTA")
         print("LTA - Proceed to STEP 7")
     end
 elseif (flaw_size_accept == 0)
     print("Assessment stopped as Step 5 Failed")
 end

# STEP 7 – Determine the MAWP for the component (see Annex 2C, paragraph 2C.2) using the thickness from STEP 2.
# Annex2c
if (equipment_group == "piping")
MAWPc = PipingMAWPc(S, E=E, t=t, MA=MA, Do=Do, Yb31=Yb31) # eq (2C.147)
print("Piping MAWPc = ",round(MAWPc, digits=2),"psi\n")
MAWPl =(4*S*E*(t-tsl-MA))/(Do-(4*Yb31*(t-tsl-MA))) # eq (2C.150)
MAWP = minimum([MAWPc,MAWPl])
elseif (equipment_group)

# Step 8
Mt =(1.001 - 0.014195*lambda + 0.2909* (lambda^2) - 0.09642*(lambda^3) + 0.02089* (lambda^4) - 0.003054 * (lambda ^5) + 2.957*(10^-4)*(lambda^6) - 1.8462*(10^-5)*(lambda^7) + (7.1553*(10^-7))*(lambda^8)-1.5631*(10^-8)*(lambda^9)+1.4656*(10^-10)*(lambda^10))
RSF = Rt / (1-1/Mt*(1-Rt))
RSFa = 0.9
MAWPr = MAWP*(RSF/RSFa)

if (RSF >= RSFa)
    MAWPr = MAWP # (eq (2.3))
    print("Region of metal loss is acceptable at the MAWP from Step 7")

else
    MAWPr = MAWP*(RSF/RSFa) # (eq (2.2))
    print("Region of metal loss is acceptable at MAWPr ", round(MAWPr,digits=2),"psi")
end

# Determing if MAWPr exceeds equipment MAWP or design pressure
if (MAWPr >= P || MAWPr >= MAWP)
    print("Component is acceptable for operating at the equipment design pressure or equipment MAWP\n")
    print("Part 5 level 1 - Satisfies June 2016 API 579-1/ASME FFS-1 Level 1 assessment\n")
    level_1_satisfied = 1
elseif (MAWPr < P || MAWPr < MAWP)
    print("Component is unacceptable for operating at the equipment design pressure or equipment MAWP\n")
    print("Part 5 level 1 - Does not satisfy June 2016 API 579-1/ASME FFS-1 Level 1 assessment\n")
        level_1_satisfied = 0
end

# Step 9 - add when do vessels

# Level 2 Assessment
# STEP 1 – Determine the CTP (see paragraph 5.3.3.2).
# Conducted at the top of the script
# STEP 2 – Determine the wall thickness to be used in the assessment using Equation (5.3) or Equation (5.4), as applicable.
tc = trd - LOSS - FCA # wall thickness away from the damaged area adjusted for LOSS and FCA , as applicable. # eq (5.3)
tc = trd - FCA # wall thickness away from the damaged area adjusted for LOSS and FCA , as applicable. # eq (5.4)
# STEP 3 – Determine the minimum measured thickness, tmm , and the flaw dimensions s and c (see paragraph 5.3.3.2.b).
tmm = CTP_Grid(CTPGrid) # minimum measured thickness determined at the time of the inspection.
# STEP 4 – Determine the remaining thickness ratio, Rt , using Equation (5.5) and the longitudinal flaw length parameter, λ , using Equation (5.6).
Rt = (tmm-FCA) / tc # remaining thickness ratio. # (5.5)
lambda = (1.285*s)/(sqrt(D*tc)) # longitudinal flaw length parameter eq (5.6)
# STEP 5 – Check the limiting flaw size criteria in paragraph 5.4.2.2.e. If all of these requirements are satisfied, then proceed to STEP 6; otherwise, the flaw is not acceptable per the Level 2 Assessment procedure.
x = FlawSizeLimitCriteria("piping","lbs-in-psi")
flaw_size_accept = FlawSizeLevel1Acceptance(x,"piping")






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
