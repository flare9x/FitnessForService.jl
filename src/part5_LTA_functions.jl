# Functions for the Part 5 LTA assessment

@doc """
    Part5LTAFlawSizeLimitCriteria(equipment_group::String,units::String,Rt::Float64,D::Float64,tc::Float64,tmm::Float64,FCAml::Float64)::Array{Int64}

Determine if the flaw is acceptable per level 1 criteria
    """ ->
function Part5LTAFlawSizeLimitCriteria(equipment_group::String,units::String,Rt::Float64,D::Float64,tc::Float64,tmm::Float64,FCAml::Float64)::Array{Int64}
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

@doc """
    Part5LTAFlawSizeLevel1Acceptance(x::Array{Int64},equipment_group::String)::Int64

Determine if the limiting flaw size criteria has met the level 1 requirments
""" ->
function Part5LTAFlawSizeLevel1Acceptance(x::Array{Int64},equipment_group::String)::Int64
    @assert any(equipment_group .== ["piping","vessel","tank"]) "Invalid input - select either: 'piping' or 'vessel' or 'tank'"
    let level_1_satisfied = 0
    # level 1
    if (sum([x[1],x[2],x[3],x[4]]) == 3)
        print("The criteria for level 1 assessment has been satisfied - proceed to STEP 6\n")
        level_1_satisfied = 1
    end
    if (sum([x[1],x[2],x[3],x[4]]) != 3)
        print("The criteria for level 1 assessment has not been satisfied - level 1 assessment failed\n")
        level_1_satisfied = 0
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

@doc """
Part5LTALevel1(x::Array{Int64};equipment_group::String="",flaw_location::String="",metal_loss_categorization::String="",units::String="",tnom::Float64=0.0,
    trd::Float64=0.0,FCA::Float64=0.0,FCAml::Float64=0.0,LOSS::Float64=0.0,Do::Float64=0.0,Do::Float64=0.0,P::Float64=0.0,S::Float64=0.0,E::Float64=0.0,MA::Float64=0.0,Yb31::Float64=0.0,
    tsl::Float64=0.0,spacings::Float64=0.0,L1msd::Float64=0.0,L2msd::Float64=0.0,L3msd::Float64=0.0,L4msd::Float64=0.0,L5msd::Float64=0.0,s::Float64=0.0,c::Float64=0.0)

    Variables\n
    equipment_group = "piping" # "vessel", "tank"\n
    annex2c_tmin_category = "Straight Pipes Subject To Internal Pressure" # ["Cylindrical Shell","Spherical Shell","Hemispherical Head","Elliptical Head","Torispherical Head","Conical Shell","Toriconical Head","Conical Transition","Nozzles Connections in Shells",
    # "Junction Reinforcement Requirements at Conical Transitions","Tubesheets","Flat head to cylinder connections","Bolted Flanges","Straight Pipes Subject To Internal Pressure","Boiler Tubes","Pipe Bends Subject To Internal Pressure",
    # "MAWP for External Pressure","Branch Connections","API 650 Storage Tanks"]\n
    flaw_location = "external" # "External","Internal"\n
    metal_loss_categorization = "groove" # "LTA" or "groove"\n
    units = "lbs-in-psi" # "lbs-in-psi" or "nmm-mm-mpa"\n
    tnom = .3 # nominal or furnished thickness of the component adjusted for mill undertolerance as applicable.\n
    trd = .3 # uniform thickness away from the local metal loss location established by thickness measurements at the time of the assessment.\n
    FCAml = .05 # Future Corrosion Allowance applied to the region of metal loss.\n
    FCA = .05 # Future Corrosion Allowance applied to the region away from the metal loss (see Annex 2C, paragraph 2C.2.8).\n
    LOSS = 0 #the amount of uniform metal loss away from the local metal loss location at the time of the assessment.\n
    Do = 3.5 # Outside Diameter\n
    D =  # inside diameter of the shell corrected for FCAml , as applicable\n
    P = 1480 # internal design pressure.\n
    S = 20000 # allowable stress.\n
    E = 1.0 # weld joint efficiency or quality factor from the original construction code, if unknown use 0.7.\n
    MA = 0 # mechanical allowances (thread or groove depth); for threaded components, the nominal thread depth (dimension h of ASME B.1.20.1) shall apply.\n
    Yb31 = 0.4 # coefficient from ASME B31 Piping codes used for determining the pipe wall thickness, the coefficient can be determined from the following table that is valid for tmin < Do / 6 Annex 2C .\n
    t = trd # thickness of the shell or pipe adjusted for mill tolerance, LOSS and FCA , or cylinder thickness at a conical transition for a junction reinforcement calculation adjusted for mill tolerance, LOSS and FCA , as applicable.\n
    tsl = 0 # supplemental thickness for mechanical loads other than pressure that result in longitudinal stress; this thickness is usually obtained from the results of a weight case in a stress analysis of the piping system (see paragraph 2C.2.7).\n
    spacings = 0.5 # spacings determine by visual inspection to adequately ccategorizse the corrosion\n
    # Flaw dimensions\n
    s = 5.5 # longitudinal extent or length of the region of local metal loss based on future corroded thickness,\n
    c = 1.5 # circumferential extent or length of the region of local metal loss (see Figure 5.2 and Figure 5.10), based on future corroded thickness, tc .\n
    Ec = 1.0 circumferential weld joint efficiency. note if damage on weld see # 2C.2.5 Treatment of Weld and Riveted Joint Efficiency, and Ligament Efficiency\n
    El = 1.0 longitudinal weld joint efficiency. note if damage on weld see # 2C.2.5 Treatment of Weld and Riveted Joint Efficiency, and Ligament Efficiency\n

"""->
function Part5LTALevel1(annex2c_tmin_category::String; equipment_group::String="piping",flaw_location::String="external",metal_loss_categorization::String="LTA",units::String="lbs-in-psi",tnom::Float64=0.0,
    trd::Float64=0.0,FCA::Float64=0.0,FCAml::Float64=0.0,LOSS::Float64=0.0,Do::Float64=0.0,D::Float64=0.0,P::Float64=0.0,S::Float64=0.0,E::Float64=0.0,MA::Float64=0.0,Yb31::Float64=0.0,
    tsl::Float64=0.0,spacings::Float64=0.0,s::Float64=0.0,c::Float64=0.0,El::Float64=0.0,Ec::Float64=0.0, RSFa::Float64=0.9)
    @assert any(annex2c_tmin_category .== ["Cylindrical Shell","Spherical Shell","Hemispherical Head","Elliptical Head","Torispherical Head","Conical Shell","Toriconical Head","Conical Transition","Nozzles Connections in Shells",
    "Junction Reinforcement Requirements at Conical Transitions","Tubesheets","Flat head to cylinder connections","Bolted Flanges","Straight Pipes Subject To Internal Pressure","Boiler Tubes","Pipe Bends Subject To Internal Pressure",
    "MAWP for External Pressure","Branch Connections","API 650 Storage Tanks"]) "Invalid entry must be any of the following tmin groups: 'Cylindrical Shell','Spherical Shell','Hemispherical Head','Elliptical Head','Torispherical Head','Conical Shell','Toriconical Head','Conical Transition','Nozzles Connections in Shells',
    'Junction Reinforcement Requirements at Conical Transitions','Tubesheets','Flat head to cylinder connections','Bolted Flanges','Straight Pipes Subject To Internal Pressure','Boiler Tubes','Pipe Bends Subject To Internal Pressure',
    'MAWP for External Pressure','Branch Connections','API 650 Storage Tanks' "
    @assert any(equipment_group .== ["piping", "vessel", "tank"]) "Invalid input: please enter either: 'piping','vessel','tank' "
    @assert any(flaw_location .== ["external", "internal"]) "Invalid input: please enter either: 'external shells', 'internal shells' "
    @assert any(metal_loss_categorization .== ["LTA", "groove"]) "Invalid input: please enter either: 'LTA', 'groove' "
    @assert any(units .== ["lbs-in-psi", "nmm-mm-mpa"]) "Invalid input: please enter either: 'lbs-in-psi', 'nmm-mm-mpa' "

print("Begin -- Level 1 Assessment - API 579 June 2016 Edition\n")
# Adjust the FCA by internal and external as below
FCA_string = "internal"  # "External","Internal"
if (FCA_string == "internal")
Dml = D + (2*FCAml) # inside diameter of the shell corrected for ml FCA , as applicable.
elseif (FCA_string == "external")
    Dml = D # inside diameter of the shell corrected for FCAml , as applicable.
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
x = Part5LTAFlawSizeLimitCriteria(equipment_group,units,Rt,D,tc,tm,FCAml)
flaw_size_accept = Part5LTAFlawSizeLevel1Acceptance(x,equipment_group)

# STEP 6 – If the region of metal loss is categorized as an LTA (i.e. the LTA is not a groove), then proceed to STEP 7. If the region of metal loss is categorized as a groove and Equation (5.11) is satisfied,
# then proceed to STEP 7. Otherwise, the Level 1 assessment is not satisfied and proceed to paragraph 5.4.2.3.
if (flaw_size_accept == 1) # begin Step 6 - Flaw size criteria met
    if (metal_loss_categorization == "groove" && (gr/(1-Rt)*tc) >= 0.5)
         print("Groove meets equation 5.11 - Proceed to STEP 7\n")
         step6_satisfied = 1
     elseif (metal_loss_categorization == "LTA")
         print("LTA - Proceed to STEP 7\n")
         step6_satisfied = 1
     end
 elseif (flaw_size_accept == 0)
     print("Assessment stopped as Step 5 Failed\n")
 end

# STEP 7 – Determine the MAWP for the component (see Annex 2C, paragraph 2C.2) using the thickness from STEP 2.
# Annex2c
if (step6_satisfied == 1) # begin step 7
if (annex2c_tmin_category == "Cylindrical Shell")
    #tmin here
elseif (annex2c_tmin_category == "Spherical Shell")
    #tmin here
elseif (annex2c_tmin_category == "Hemispherical Head")
    #tmin here
elseif (annex2c_tmin_category == "Elliptical Head")
    #tmin here
elseif (annex2c_tmin_category == "Torispherical Head")
    #tmin here
elseif (annex2c_tmin_category == "Conical Shell")
    #tmin here
elseif (annex2c_tmin_category == "Toriconical Head")
    #tmin here
elseif (annex2c_tmin_category == "Conical Transition")
    #tmin here
elseif (annex2c_tmin_category == "Nozzles Connections in Shells")
    #tmin here
elseif (annex2c_tmin_category == "Junction Reinforcement Requirements at Conical Transitions")
    #tmin here
elseif (annex2c_tmin_category == "Tubesheets")
    #tmin here
elseif (annex2c_tmin_category == "Flat head to cylinder connections")
    #tmin here
elseif (annex2c_tmin_category == "Bolted Flanges")
    #tmin here
elseif (annex2c_tmin_category == "Straight Pipes Subject To Internal Pressure")
MAWPc = PipingMAWPc(S, E=E, t=t, MA=MA, Do=Do, Yb31=Yb31) # eq (2C.147)
print("Piping MAWPc = ",round(MAWPc, digits=3),"psi\n")
MAWPl = PipingMAWPl(S; E=E, t=t, tsl=tsl, MA=MA, Do=Do, Yb31=Yb31) # eq (2C.150)
print("Piping MAWPl = ",round(MAWPl, digits=3),"psi\n")
MAWP = minimum([MAWPc,MAWPl])
print("Final MAWP = ",round(MAWP, digits=3),"psi\n")
elseif (annex2c_tmin_category == "Boiler Tubes")
    #tmin here
elseif (annex2c_tmin_category == "Pipe Bends Subject To Internal Pressure")
    #tmin here
elseif (annex2c_tmin_category == "MAWP for External Pressure")
    #tmin here
elseif (annex2c_tmin_category == "Branch Connections")
    #tmin here
elseif (annex2c_tmin_category == "API 650 Storage Tanks")
    #tmin here
end # end equations
elseif (step6_satisfied == 0)
    print("Step 7 Not Conducted Step 6 not satisfied")
end

# STEP 8 – Enter Figure 5.6 for a cylindrical shell or Figure 5.7 for a spherical shell with the calculated
#  values of λ and Rt . If the point defined by the intersection of these values is on or above the curve, then
# the longitudinal extent (circumferential or meridional extent for spherical shells and formed heads) of the
# flaw is acceptable for operation at the MAWP determined in STEP 7.

# Calculate the Rt cut off curves
# Table 5.2 – Folias Factor, Mt, Based on the Longitudinal or Meridional Flaw Parameter, λ, for Cylindrical, Conical and Spherical Shells
if (annex2c_tmin_category == "Cylindrical Shell" || annex2c_tmin_category == "Conical Shell" || annex2c_tmin_category == "Straight Pipes Subject To Internal Pressure" || annex2c_tmin_category == "Pipe Bends Subject To Internal Pressure" ||
    annex2c_tmin_category == "API 650 Storage Tanks" || annex2c_tmin_category == "MAWP for External Pressure" || annex2c_tmin_category == "Hemispherical Head" || annex2c_tmin_category == "Elliptical Head" || annex2c_tmin_category == "Torispherical Head" ||
    annex2c_tmin_category == "Toriconical Head")
    # calculate Mt for Cylindrical Shell & Conical Shell
    lambda_values = collect(0:0.5:20.0)
    Mt_Cylindrical_or_Conical_Shell = zeros(size(lambda_values,1))
        @inbounds for i = 1:size(lambda_values,1)
        Mt_Cylindrical_or_Conical_Shell[i] = round((1.001 - 0.014195*lambda_values[i] + 0.2909* (lambda_values[i]^2) - 0.09642*(lambda_values[i]^3) + 0.02089* (lambda_values[i]^4) - 0.003054 * (lambda_values[i] ^5) + 2.957*(10^-4)*(lambda_values[i]^6) - 1.8462*(10^-5)*(lambda_values[i]^7) + (7.1553*(10^-7))*(lambda_values[i]^8)-1.5631*(10^-8)*(lambda_values[i]^9)+1.4656*(10^-10)*(lambda_values[i]^10)),digits=3)
    end # end loop
    # calculate Rt for Cylindrical Shell & Conical Shell
    Rt_Cylindrical_or_Conical_Shell = zeros(size(lambda_values,1))
    i=1
        @inbounds for i = 1:size(Rt_Cylindrical_or_Conical_Shell,1)
            if (lambda_values[i] <= 0.354)
            Rt_Cylindrical_or_Conical_Shell[i] = 0.2
        elseif (0.354 < lambda_values[i] < 20.0)
            Rt_Cylindrical_or_Conical_Shell[i] = ((RSFa-(RSFa/Mt_Cylindrical_or_Conical_Shell[i]))*(1-(RSFa/Mt_Cylindrical_or_Conical_Shell[i]))^-1)
        elseif (lambda_values[i] >= 20.0)
            Rt_Cylindrical_or_Conical_Shell[i] = 0.9
        end
    end # end loop
elseif (annex2c_tmin_category == "Spherical Shell") # begin spherical shell
    lambda_values = collect(0:0.5:20.0)
    Mt_Spherical_Shell = zeros(size(lambda_values,1))
    @inbounds for i = 1:size(lambda_values,1)
    Mt_Spherical_Shell[i] = round((1.0005 + 0.49001*lambda_values[i] + 0.32409*(lambda_values[i])^2) / (1.0 + 0.50144*(lambda_values[i]) - 0.011067*(lambda_values[i])^2),digits=3)
end # loop end
# calculate Rt for Spherical Shell
Rt_Spherical_Shell = zeros(size(lambda_values,1))
i=1
    @inbounds for i = 1:size(Rt_Spherical_Shell ,1)
        if (lambda_values[i] <= 0.330)
        Rt_Spherical_Shell[i] = 0.2
    elseif (0.330 < lambda_values[i] < 20.0)
        Rt_Spherical_Shell[i] = ((RSFa-(RSFa/Mt_Spherical_Shell[i]))*(1-(RSFa/Mt_Spherical_Shell[i]))^-1)
    elseif (lambda_values[i] >= 20.0)
        Rt_Spherical_Shell[i] = 0.9
        end
    end # end loop
end # end Rt cut off curve

# Determine Mt based
if (annex2c_tmin_category == "Cylindrical Shell" || annex2c_tmin_category == "Conical Shell" || annex2c_tmin_category == "Straight Pipes Subject To Internal Pressure" || annex2c_tmin_category == "Pipe Bends Subject To Internal Pressure" ||
    annex2c_tmin_category == "API 650 Storage Tanks" || annex2c_tmin_category == "MAWP for External Pressure" || annex2c_tmin_category == "Hemispherical Head" || annex2c_tmin_category == "Elliptical Head" || annex2c_tmin_category == "Torispherical Head" ||
    annex2c_tmin_category == "Toriconical Head")
    Mt =(1.001 - 0.014195*lambda + 0.2909* (lambda^2) - 0.09642*(lambda^3) + 0.02089* (lambda^4) - 0.003054 * (lambda ^5) + 2.957*(10^-4)*(lambda^6) - 1.8462*(10^-5)*(lambda^7) + (7.1553*(10^-7))*(lambda^8)-1.5631*(10^-8)*(lambda^9)+1.4656*(10^-10)*(lambda^10))
elseif (annex2c_tmin_category == "Spherical Shell")
    Mt = (1.0005 + 0.49001*lambda + 0.32409*(lambda)^2) / (1.0 + 0.50144*(lambda) - 0.011067*(lambda)^2) # spheres
end

#+++ to do - add plotting for the Rt cut off curve
# If the point defined by the intersection of these values is on or above the curve, then
# the longitudinal extent (circumferential or meridional extent for spherical shells and formed heads) of the
# flaw is acceptable for operation at the MAWP determined in STEP 7.

RSF = Rt / (1-1/Mt*(1-Rt)) # eq (5.12)
MAWPr = MAWP*(RSF/RSFa)

if (RSF >= RSFa)
    MAWPr = MAWP # (eq (2.3))
    print("Region of metal loss is acceptable at the MAWP from Step 7\n")
else
    MAWPr = MAWP*(RSF/RSFa) # (eq (2.2))
    print("Region of metal loss is acceptable at MAWPr ", round(MAWPr,digits=3),"psi\n")
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

# STEP 9 – Evaluate the longitudinal extent of the flaw for cylindrical and conical shells.
if (annex2c_tmin_category == "Cylindrical Shell" || annex2c_tmin_category == "Conical Shell" || annex2c_tmin_category == "Pipe Bends Subject To Internal Pressure")
    print("The component is a cylindrical shell, conical shell, or elbow\n Begin -- evaluate the circumferential extent\n")
# STEP 9.1 – If Equation (5.13) is satisfied, the circumferential extent is acceptable, and no further evaluation is required. Otherwise, proceed to STEP 9.2.
if (c <= (2*s)*El/Ec) # eq (5.13)
    print("eq 5.13 satisfied - no further evaluation is required\n")
    step_9_satisfied = 1
else
    print("eq 5.13 not satisfied - Proceed to STEP 9.2\n")
    step_9_satisfied = 0
end # end step 9.1
if (step_9_satisfied == 0) # begin 9.2 and 9.3
    #STEP 9.2 – Calculate the minimum thickness required for longitudinal stresses, tlmin , using MAWPr determined in STEP 8.
    tlmin = Pipingtlmin(MAWPr, Do=Do, S=S, E=E, Yb31=Yb31, tsl=tsl, MA=MA) # using MAWPr from STEP 8
    # STEP 9.3 – If Equation (5.14) is satisfied, the circumferential extent is acceptable, and no further evaluation is required. Otherwise, proceed to STEP 9.4.
if (tlmin <= (tmm - FCAml)) # eq (5.14)
    step_9_satisfied = 1
    print("eq 5.14 satisfied - no further evaluation is required\n")
else
    print("eq 5.14 not satisfied - Proceed to STEP 9.4\n")
    step_9_satisfied = 0
end # end step 9.2 and 9.3
end # end conditional step_9_satisfied
if (step_9_satisfied == 0) # begin 9.4
    MAWPr = MAWPr*(((tmm-FCAml)/tlmin))
end # end step 9.4
elseif (annex2c_tmin_category != "Cylindrical Shell" || annex2c_tmin_category != "Conical Shell" || annex2c_tmin_category != "Pipe Bends Subject To Internal Pressure")
    print("The assessment is complete for all component types\n")
end
labels = ["tc", "tm", "Rt", "lambda", "MAWPc", "MAWPl", "MAWP", "Mt", "RSF", "MAWPr", "P"]
part_5_level_1_calculated_parameters = [tc, tmm, Rt, lambda, MAWPc, MAWPl, MAWP, Mt, RSF, MAWPr, P]
out = hcat(labels,part_5_level_1_calculated_parameters)
return out
end # function end
