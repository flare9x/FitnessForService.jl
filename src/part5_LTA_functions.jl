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
        print("The criteria for level 1 and 2 assessment has been satisfied - proceed to STEP 6\n")
        level_1_satisfied = 1
    end
    if (sum([x[1],x[2],x[3],x[4]]) != 3)
        print("The criteria for level 1 and 2 assessment has not been satisfied - level 1 assessment failed\n")
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
    sc(metal_loss_categorization::String; annex2c_tmin_category::String, sβ::Float64, cβ::Float64)::Array{Float64}

s and c parameter determination\n
LTA = s and c - see Figure 5.2\n
For groove like flaws::\n
gl = length of the Groove-Like Flaw based on future corroded condition.\n
gw = width of the Groove-Like Flaw based on future corroded condition.\n
β = orientation of the groove-like flaw with respect to the longitudinal axis or a parameter to compute an effective fracture toughness for a groove being evaluated as a crack-like flaw, as applicable\n
    For grooves located on cylinders and cones orientated at an angle to the longitudinal axis (Figure 5.4) - eq (5.1) and eq (5.2) may be used to determine the s and c parameters\n
 """
 function sc(metal_loss_categorization::String; annex2c_tmin_category::String, β::Float64, gl::Float64, gw::Float64)::Array{Float64}
     let s = s, c = c
     @assert (β >=0.0) && (β <=90.0) "Invalid input : Please enter a value between 0 and 90 degrees - see API 579 2016 figure 5"
     if (metal_loss_categorization == "LTA")
         s = s
         c = c
     elseif (metal_loss_categorization == "Groove-Like Flaw" && (annex2c_tmin_category == "Cylindrical Shell" || annex2c_tmin_category == "Conical Shell" ||
         annex2c_tmin_category == "Straight Pipes Subject To Internal Pressure" || annex2c_tmin_category == "API 650 Storage Tanks"|| annex2c_tmin_category == "Pipe Bends Subject To Internal Pressure" ||
         annex2c_tmin_category == "MAWP for External Pressure"))
         # if β is less than 90 degrees, then adjust the longitudinal extent of the flaw - note determine angels based on center line
         s = (gl * cosd(β)) + (gw * sind(β)) # for β < 90 Degrees (5.1)
         # if β is less than 90 degrees, then adjust the circumferential extent of the flaw - note determine angels based on center line
         c = (gl * sind(β)) + (gw * cosd(β)) # for β < 90 Degrees (5.2)
     end
     return s_c =[s,c]
 end # let end
end # function end

@doc """
    Part5LTALevel1(annex2c_tmin_category::String; equipment_group::String="piping",flaw_location::String="external",metal_loss_categorization::String="LTA",units::String="lbs-in-psi",tnom::Float64=0.0,
    trd::Float64=0.0,FCA::Float64=0.0,FCAml::Float64=0.0,LOSS::Float64=0.0,Do::Float64=0.0,D::Float64=0.0,P::Float64=0.0,S::Float64=0.0,E::Float64=0.0,MA::Float64=0.0,Yb31::Float64=0.0,
    tsl::Float64=0.0,spacings::Float64=0.0,s::Float64=0.0,c::Float64=0.0,El::Float64=0.0,Ec::Float64=0.0, RSFa::Float64=0.9, gl::Float64=0.0, gw::Float64=0.0, gr::Float64=0.0, β::Float64=0.0)

    Variables\n
    equipment_group = "piping" # "vessel", "tank"\n
    annex2c_tmin_category = "Straight Pipes Subject To Internal Pressure" # ["Cylindrical Shell","Spherical Shell","Hemispherical Head","Elliptical Head","Torispherical Head","Conical Shell","Toriconical Head","Conical Transition","Nozzles Connections in Shells",
    # "Junction Reinforcement Requirements at Conical Transitions","Tubesheets","Flat head to cylinder connections","Bolted Flanges","Straight Pipes Subject To Internal Pressure","Boiler Tubes","Pipe Bends Subject To Internal Pressure",
    # "MAWP for External Pressure","Branch Connections","API 650 Storage Tanks"]\n
    flaw_location = "external" # "External","Internal"\n
    metal_loss_categorization = "Groove-Like Flaw" # "LTA" or "Groove-Like Flaw"\n
    units = "lbs-in-psi" # "lbs-in-psi" or "nmm-mm-mpa"\n
    tnom = .3 # nominal or furnished thickness of the component adjusted for mill undertolerance as applicable.\n
    trd = .3 # uniform thickness away from the local metal loss location established by thickness measurements at the time of the assessment.\n
    FCAml = .05 # Future Corrosion Allowance applied to the region of metal loss.\n
    FCA = .05 # Future Corrosion Allowance applied to the region away from the metal loss (see Annex 2C, paragraph 2C.2.8).\n
    LOSS = 0 #the amount of uniform metal loss away from the local metal loss location at the time of the assessment.\n
    Do = 3.5 # Outside Diameter\n
    D = Do - 2*(tnom)  # inside diameter of the shell corrected for FCAml , as applicable\n
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
    tsl::Float64=0.0, t::Float64=0.0, spacings::Float64=0.0,s::Float64=0.0,c::Float64=0.0,El::Float64=0.0,Ec::Float64=0.0, RSFa::Float64=0.9, gl::Float64=0.0, gw::Float64=0.0, gr::Float64=0.0, β::Float64=0.0)
    @assert any(annex2c_tmin_category .== ["Cylindrical Shell","Spherical Shell","Hemispherical Head","Elliptical Head","Torispherical Head","Conical Shell","Toriconical Head","Conical Transition","Nozzles Connections in Shells",
    "Junction Reinforcement Requirements at Conical Transitions","Tubesheets","Flat head to cylinder connections","Bolted Flanges","Straight Pipes Subject To Internal Pressure","Boiler Tubes","Pipe Bends Subject To Internal Pressure",
    "MAWP for External Pressure","Branch Connections","API 650 Storage Tanks"]) "Invalid entry must be any of the following tmin groups: 'Cylindrical Shell','Spherical Shell','Hemispherical Head','Elliptical Head','Torispherical Head','Conical Shell','Toriconical Head','Conical Transition','Nozzles Connections in Shells',
    'Junction Reinforcement Requirements at Conical Transitions','Tubesheets','Flat head to cylinder connections','Bolted Flanges','Straight Pipes Subject To Internal Pressure','Boiler Tubes','Pipe Bends Subject To Internal Pressure',
    'MAWP for External Pressure','Branch Connections','API 650 Storage Tanks' "
    @assert any(equipment_group .== ["piping", "vessel", "tank"]) "Invalid input: please enter either: 'piping','vessel','tank' "
    @assert any(flaw_location .== ["external", "internal"]) "Invalid input: please enter either: 'external shells', 'internal shells' "
    @assert any(metal_loss_categorization .== ["LTA", "Groove-Like Flaw"]) "Invalid input: please enter either: 'LTA', 'Groove-Like Flaw' "
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

# STEP 3 – Determine the minimum measured thickness in the LTA, tmm , and the flaw dimensions, s and c (see paragraph 5.3.3.2.b) for the CTP.
# s and c
# User define for LTA and Groove-Like flaw
# For cylinders and cones - if the groove is orientated at an angle to the longitudinal axis, then the groove-like flaw profile can be projected on to the longitudinal and circumferential planes using the following equations to establish the equivalent LTA dimensions
out = sc(metal_loss_categorization; annex2c_tmin_category=annex2c_tmin_category,β=β,gl=gl,gw=gw)
s = out[1]
c = out[2]
tmm, long_CTP = CTP_Grid(CTPGrid) # minimum measured thickness determined at the time of the inspection.

# STEP 4 – Determine the remaining thickness ratio using Equation (5.5) and the longitudinal flaw length parameter using Equation (5.6).
Rt = (tmm-FCA) / tc # remaining thickness ratio. # (5.5)
lambda = (1.285*s)/(sqrt(D*tc)) # longitudinal flaw length parameter eq (5.6)

# STEP 5 – Check the limiting flaw size criteria; if the following requirements are satisfied, proceed to STEP 6; otherwise, the flaw is not acceptable per the Level 1 Assessment procedure.
x = Part5LTAFlawSizeLimitCriteria(equipment_group,units,Rt,D,tc,tmm,FCAml)
flaw_size_accept = Part5LTAFlawSizeLevel1Acceptance(x,equipment_group)

# STEP 6 – If the region of metal loss is categorized as an LTA (i.e. the LTA is not a groove), then proceed to STEP 7. If the region of metal loss is categorized as a groove and Equation (5.11) is satisfied,
# then proceed to STEP 7. Otherwise, the Level 1 assessment is not satisfied and proceed to paragraph 5.4.2.3.
if (flaw_size_accept == 1) # begin Step 6 - Flaw size criteria met
    if (metal_loss_categorization == "Groove-Like Flaw" && (gr/((1-Rt)*tc)) >= 0.5)
         print("Groove-Like Flaw meets equation 5.11 - Proceed to STEP 7\n")
         step6_satisfied = 1
     elseif (metal_loss_categorization == "Groove-Like Flaw" && (gr/((1-Rt)*tc)) < 0.5)
         print("Groove-Like Flaw does not meet equation 5.11 - Level 1 assessment is not satisfied - Perform a level 2 assessment per API 579 2016 paragraph 5.4.2.3.\n")
         step6_satisfied = 0
     elseif (metal_loss_categorization == "LTA")
         print("LTA - Proceed to STEP 7\n")
         step6_satisfied = 1
     end
 elseif (flaw_size_accept == 0)
     print("Assessment stopped as Step 5 Failed\n")
     step6_satisfied = 0
    end


# STEP 7 – Determine the MAWP for the component (see Annex 2C, paragraph 2C.2) using the thickness from STEP 2.
# Annex2c
if (step6_satisfied == 1) # begin step 7 onwards
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
#using Gadfly
#plot(x=rand(10), y=rand(10))
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
if (annex2c_tmin_category == "Cylindrical Shell" || annex2c_tmin_category == "Conical Shell" || annex2c_tmin_category == "Pipe Bends Subject To Internal Pressure" || annex2c_tmin_category == "Pipe Bends Subject To Internal Pressure")
    print("The component is a cylindrical shell, conical shell, or elbow\n Begin -- evaluate the circumferential extent\n")
# STEP 9.1 – If Equation (5.13) is satisfied, the circumferential extent is acceptable, and no further evaluation is required. Otherwise, proceed to STEP 9.2.
if (c <= (2*s)*(El/Ec)) # eq (5.13)
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
elseif (step6_satisfied == 0)
    print("Step 7 onwards Not Conducted Step 6 not satisfied")
end
end # function end

# Simpsons rule odd number: https://scicomp.stackexchange.com/questions/25649/composite-simpsons-rule-with-odd-intervals
# Simpsons 3/8 rule: https://en.wikipedia.org/wiki/Simpson's_rule#Simpson.27s_3.2F8_rule
# Even numbers - use traditional simpsons rule - stesp of x , 4,2,4,2 etc.....
# Odd numbers - use 3/8 rule as above
# write function
# if length(x) isodd iseven do this....

#

@doc """
    Part5LTALevel2(annex2c_tmin_category::String; equipment_group::String="piping",flaw_location::String="external",metal_loss_categorization::String="LTA",units::String="lbs-in-psi",tnom::Float64=0.0,
    trd::Float64=0.0,FCA::Float64=0.0,FCAml::Float64=0.0,LOSS::Float64=0.0,Do::Float64=0.0,D::Float64=0.0,P::Float64=0.0,S::Float64=0.0,E::Float64=0.0,MA::Float64=0.0,Yb31::Float64=0.0,
    tsl::Float64=0.0,spacings::Float64=0.0,s::Float64=0.0,c::Float64=0.0,El::Float64=0.0,Ec::Float64=0.0, RSFa::Float64=0.9, gl::Float64=0.0, gw::Float64=0.0, gr::Float64=0.0, β::Float64=0.0)

    Variables\n
    equipment_group = "piping" # "vessel", "tank"\n
    annex2c_tmin_category = "Straight Pipes Subject To Internal Pressure" # ["Cylindrical Shell","Spherical Shell","Hemispherical Head","Elliptical Head","Torispherical Head","Conical Shell","Toriconical Head","Conical Transition","Nozzles Connections in Shells",
    # "Junction Reinforcement Requirements at Conical Transitions","Tubesheets","Flat head to cylinder connections","Bolted Flanges","Straight Pipes Subject To Internal Pressure","Boiler Tubes","Pipe Bends Subject To Internal Pressure",
    # "MAWP for External Pressure","Branch Connections","API 650 Storage Tanks"]\n
    flaw_location = "external" # "External","Internal"\n
    metal_loss_categorization = "Groove-Like Flaw" # "LTA" or "Groove-Like Flaw"\n
    units = "lbs-in-psi" # "lbs-in-psi" or "nmm-mm-mpa"\n
    tnom = .3 # nominal or furnished thickness of the component adjusted for mill undertolerance as applicable.\n
    trd = .3 # uniform thickness away from the local metal loss location established by thickness measurements at the time of the assessment.\n
    FCAml = .05 # Future Corrosion Allowance applied to the region of metal loss.\n
    FCA = .05 # Future Corrosion Allowance applied to the region away from the metal loss (see Annex 2C, paragraph 2C.2.8).\n
    LOSS = 0 #the amount of uniform metal loss away from the local metal loss location at the time of the assessment.\n
    Do = 3.5 # Outside Diameter\n
    D = Do - 2*(tnom)  # inside diameter of the shell corrected for FCAml , as applicable\n
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
function Part5LTALevel2(annex2c_tmin_category::String; equipment_group::String="piping",flaw_location::String="external",metal_loss_categorization::String="LTA",units::String="lbs-in-psi",tnom::Float64=0.0,
    trd::Float64=0.0,FCA::Float64=0.0,FCAml::Float64=0.0,LOSS::Float64=0.0,Do::Float64=0.0,D::Float64=0.0,P::Float64=0.0,S::Float64=0.0,E::Float64=0.0,MA::Float64=0.0,Yb31::Float64=0.0,
    tsl::Float64=0.0, t::Float64=0.0, spacings::Float64=0.0,s::Float64=0.0,c::Float64=0.0,El::Float64=0.0,Ec::Float64=0.0, RSFa::Float64=0.9, gl::Float64=0.0, gw::Float64=0.0, gr::Float64=0.0, β::Float64=0.0)
    @assert any(annex2c_tmin_category .== ["Cylindrical Shell","Spherical Shell","Hemispherical Head","Elliptical Head","Torispherical Head","Conical Shell","Toriconical Head","Conical Transition","Nozzles Connections in Shells",
    "Junction Reinforcement Requirements at Conical Transitions","Tubesheets","Flat head to cylinder connections","Bolted Flanges","Straight Pipes Subject To Internal Pressure","Boiler Tubes","Pipe Bends Subject To Internal Pressure",
    "MAWP for External Pressure","Branch Connections","API 650 Storage Tanks"]) "Invalid entry must be any of the following tmin groups: 'Cylindrical Shell','Spherical Shell','Hemispherical Head','Elliptical Head','Torispherical Head','Conical Shell','Toriconical Head','Conical Transition','Nozzles Connections in Shells',
    'Junction Reinforcement Requirements at Conical Transitions','Tubesheets','Flat head to cylinder connections','Bolted Flanges','Straight Pipes Subject To Internal Pressure','Boiler Tubes','Pipe Bends Subject To Internal Pressure',
    'MAWP for External Pressure','Branch Connections','API 650 Storage Tanks' "
    @assert any(equipment_group .== ["piping", "vessel", "tank"]) "Invalid input: please enter either: 'piping','vessel','tank' "
    @assert any(flaw_location .== ["external", "internal"]) "Invalid input: please enter either: 'external shells', 'internal shells' "
    @assert any(metal_loss_categorization .== ["LTA", "Groove-Like Flaw"]) "Invalid input: please enter either: 'LTA', 'Groove-Like Flaw' "
    @assert any(units .== ["lbs-in-psi", "nmm-mm-mpa"]) "Invalid input: please enter either: 'lbs-in-psi', 'nmm-mm-mpa' "

print("Begin -- Level 2 Assessment - API 579 June 2016 Edition\n")
# Adjust the FCA by internal and external as below
FCA_string = "internal"  # "External","Internal"
if (FCA_string == "internal")
Dml = D + (2*FCAml) # inside diameter of the shell corrected for ml FCA , as applicable.
elseif (FCA_string == "external")
    Dml = D # inside diameter of the shell corrected for FCAml , as applicable.
end

# STEP 1 – Determine the CTP (see paragraph 5.3.3.2)
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

# STEP 3 – Determine the minimum measured thickness in the LTA, tmm , and the flaw dimensions, s and c (see paragraph 5.3.3.2.b) for the CTP.
# s and c
# User define for LTA and Groove-Like flaw
# For cylinders and cones - if the groove is orientated at an angle to the longitudinal axis, then the groove-like flaw profile can be projected on to the longitudinal and circumferential planes using the following equations to establish the equivalent LTA dimensions
out = sc(metal_loss_categorization; annex2c_tmin_category=annex2c_tmin_category,β=β,gl=gl,gw=gw)
s = out[1]
c = out[2]
tmm, long_CTP = CTP_Grid(CTPGrid) # minimum measured thickness determined at the time of the inspection.

# STEP 4 – Determine the remaining thickness ratio using Equation (5.5) and the longitudinal flaw length parameter using Equation (5.6).
Rt = (tmm[1]-FCA) / tc # remaining thickness ratio. # (5.5)
lambda = (1.285*s)/(sqrt(D*tc)) # longitudinal flaw length parameter eq (5.6)

# STEP 5 – Check the limiting flaw size criteria; if the following requirements are satisfied, proceed to STEP 6; otherwise, the flaw is not acceptable per the Level 1 Assessment procedure.
x = Part5LTAFlawSizeLimitCriteria(equipment_group,units,Rt,D,tc,tmm,FCAml)
flaw_size_accept = Part5LTAFlawSizeLevel1Acceptance(x,equipment_group)

# STEP 6 – If the region of metal loss is categorized as an LTA (i.e. the LTA is not a groove), then proceed to STEP 7. If the region of metal loss is categorized as a groove and Equation (5.11) is satisfied,
# then proceed to STEP 7. Otherwise, the Level 1 assessment is not satisfied and proceed to paragraph 5.4.2.3.
if (flaw_size_accept == 1) # begin Step 6 (1) - Flaw size criteria met
    if (metal_loss_categorization == "Groove-Like Flaw" && (gr/((1-Rt)*tc)) >= 0.5) # eq (5.11)
         print("Groove-Like Flaw meets equation 5.11 - Proceed to STEP 7\n")
         step6_satisfied = 1
     elseif (metal_loss_categorization == "Groove-Like Flaw" && (gr/((1-Rt)*tc)) < 0.5) # eq (5.11)
         print("Groove-Like Flaw does not meet equation 5.11 - Level 1 assessment is not satisfied - Perform a level 2 assessment per API 579 2016 paragraph 5.4.2.3.\n")
         step6_satisfied = 0
     elseif (metal_loss_categorization == "LTA")
         print("LTA - Proceed to STEP 7\n")
         step6_satisfied = 1
     end
 elseif (flaw_size_accept == 0)
     print("Assessment stopped as Step 5 Failed\n")
     step6_satisfied = 0
end

if (flaw_size_accept == 1 && step6_satisfied == 0) # equation 5.11 not met so determine how the groove will be treated like a crack like flaw
    if (metal_loss_categorization == "Groove-Like Flaw" && (0.1 < (gr/((1-Rt)*tc)) < 0.5)) # eq (5.16)
         print("Equation (5.16) is satisfied :: Groove shall be evaluated as an equivalent crack-like flaw using the assessment procedures in Part 9\n
         In this assessment, the crack depth shall equal the groove depth, i.e. a = (1 - Rt)tc , the crack length shall equal the groove length, and the fracture\n
         toughness shall be evaluated using Table 5.3 or Part 9\n")
         step6_satisfied = 0
     elseif (metal_loss_categorization == "Groove-Like Flaw" && ((gr/((1-Rt)*tc)) <= 0.1)) # eq (5.17)
         print("Equation (5.17) is satisfied :: Groove shall be evaluated as an equivalent crack-like flaw using the assessment procedures in Part 9.\n
         In this assessment, the crack depth shall equal the groove depth, i.e. a = (1 - Rt)tc , the crack length shall equal the groove length, and the fracture\n
         toughness shall be evaluated using Part 9\n")
         step6_satisfied = 0
     end
end


# STEP 7 – Determine the MAWP for the component (see Annex 2C, paragraph 2C.2) using the thickness from STEP 2.
# Annex2c
if (step6_satisfied == 1) # begin step 7 onwards
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

# STEP 8 – Determine the Remaining Strength Factor for the longitudinal CTP using the following procedure.
# Numerical approach inputs
spacings = .5
s2 = collect(spacings:spacings:size(CTPGrid,2)/(1/spacings)) # maximum inspection boundary - longitudinal direction
c2 = collect(spacings:spacings:size(CTPGrid,1)/(1/spacings)) # minimum inspection boundary - circumferential  direction
# STEP 8.1 – Rank the thickness readings in ascending order based on metal loss profile.
# Initialize starting poiunt thickness and start, center and index positions
Ss = s2 .- spacings
Se = s2 .+ spacings
Si = Se - Ss
data_needed = [long_CTP Ss s2 Se Si]
ranked_ascending_order = sortslices(data_needed,dims=1) # sort data by thickness in ascending order
    index_CTP = [s2 long_CTP]

# STEP 8.2 – Set the initial evaluation starting point as the location of maximum metal loss. This is the location in the thickness profile where tmm is recorded.
# Subsequent starting points should be in accordance with the ranking in STEP 8.1.
RSFi = zeros(size(long_CTP,1))
i=1
for i in 1:size(ranked_ascending_order,1)
subset_1_starting = ranked_ascending_order[i,1:5]  # for loop here to grab the starting portion.....
if any(subset_1_starting .== 0.0) != 1

# STEP 8.3 – At the current evaluation starting point, subdivide the thickness profile into a series of
# subsections (see Figure 5.8). The number and extent of the subsections should be chosen based on
# the desired accuracy and should encompass the variations in metal loss.

# Build Ss, c, Se and Si for the particualr subset (lower / center and upper bounds)
# for loop to iterate - stop when hit 0 and subsequently stop at the upper limit
subset_min_direction = subset_1_starting[2]/spacings  # find the lower limit of the index postion of the particualr subset
subset_max_direction = subset_1_starting[4]/spacings # find the maximum limit of the index postion of the particualr subset
subset_max = minimum([subset_min_direction,subset_max_direction]) # take the minimum - can only slide along the grid to the most outer edge
Ss_grid_position = zeros(Int64.(subset_max),1)
Ss_t_at_grid_position = zeros(Int64.(subset_max),1)
c_grid_position = zeros(Int64.(subset_max),1)
c_t_at_grid_position = zeros(Int64.(subset_max),1)
Se_grid_position = zeros(Int64.(subset_max),1)
Se_t_at_grid_position = zeros(Int64.(subset_max),1)
Si_out = zeros(Int64.(subset_max),1)
@inbounds for k = 1:size(Si_out,1)
    if (k == 1)
    Ss_grid_position[k] = subset_1_starting[2]
    c_grid_position[k] = subset_1_starting[3]
    Se_grid_position[k] = subset_1_starting[4]
    Si_out[k] = subset_1_starting[5]
elseif (k >=2)
    Ss_grid_position[k] = Ss_grid_position[k-1] - spacings
    c_grid_position[k] = subset_1_starting[3]
    Se_grid_position[k] = Se_grid_position[k-1] + spacings
    Si_out[k] = Se_grid_position[k] - Ss_grid_position[k]
end
end

subset_out = [Ss_grid_position c_grid_position Se_grid_position Si_out]

# place in a J loop - go throgh each - do MT AO etc....
# trapezoid rule needed for area
global A_i = zeros(size(subset_out,1))
for j in 1:size(subset_out,1)
    starting_set = reshape(subset_out[j,1:size(subset_out,2)],1,4)
    # trapezondonial rule - do trapezoid area and sum all across the profile
    x = collect(starting_set[1]:spacings:starting_set[3])
    grab_t = zero(x)
    trapezoid_total_area = zero(x)
    for t in 1:size(index_CTP,1) # loop through the thickness index
        for ta in 1:size(x,1) # loop through the subset in question
            if (x[ta] == index_CTP[t,1])
                grab_t[ta] = tc - index_CTP[t,2] # it is the area of loss that is needed so t = tc - remaining wall
            if ta == 1
                trapezoid_total_area[ta] =  0.0
            elseif ta > 1
                trapezoid_total_area[ta] = spacings/2 *(grab_t[ta-1]+grab_t[ta])
            end
        end
        end
    end

global A_i[j] = sum(trapezoid_total_area) # Ai
end

subset_out = hcat(subset_out,A_i)

# Calculate Ai_o = Si * tc
Ai_o = subset_out[:,4] .*tc
lambda = (1.285*subset_out[:,4])./sqrt(D*tc)


# Mt
global Mt = zeros(size(subset_out,1))
for k in 1:size(subset_out,1)
if (annex2c_tmin_category == "Cylindrical Shell" || annex2c_tmin_category == "Conical Shell" || annex2c_tmin_category == "Straight Pipes Subject To Internal Pressure" || annex2c_tmin_category == "Pipe Bends Subject To Internal Pressure" ||
    annex2c_tmin_category == "API 650 Storage Tanks" || annex2c_tmin_category == "MAWP for External Pressure" || annex2c_tmin_category == "Hemispherical Head" || annex2c_tmin_category == "Elliptical Head" || annex2c_tmin_category == "Torispherical Head" ||
    annex2c_tmin_category == "Toriconical Head")
    global Mt[k] =(1.001 - 0.014195*lambda[k] + 0.2909* (lambda[k]^2) - 0.09642*(lambda[k]^3) + 0.02089* (lambda[k]^4) - 0.003054 * (lambda[k] ^5) + 2.957*(10^-4)*(lambda[k]^6) - 1.8462*(10^-5)*(lambda[k]^7) + (7.1553*(10^-7))*(lambda[k]^8)-1.5631*(10^-8)*(lambda[k]^9)+1.4656*(10^-10)*(lambda[k]^10))
elseif (annex2c_tmin_category == "Spherical Shell")
    global Mt[k] = (1.0005 + 0.49001*lambda[k] + 0.32409*(lambda[k])^2) / (1.0 + 0.50144*(lambda[k]) - 0.011067*(lambda[k])^2) # spheres
    end
end

# append output to subset array
subset_out = hcat(subset_out,Ai_o,lambda,Mt)

# remaining strength factor RSF
global RSF = zeros(size(subset_out,1))
k=1
    for k in 1:size(subset_out,1)
    global RSF[k] = (1.0-(A_i[k]/Ai_o[k])) / (1.0- 1.0 / Mt[k]*(A_i[k]/Ai_o[k]))
end

subset_out = hcat(subset_out,RSF)

global RSFi[i] = minimum(RSF)
elseif any(subset_1_starting .== 0.0) 1
    global RSFi[i] = 1.0
end

end # end loop

global RSF = minimum(RSFi)

global MAWPr = MAWP*(RSF/RSFa)

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
    print("Part 5 level 2 - Satisfies June 2016 API 579-1/ASME FFS-1 Level 2 assessment\n")
    level_2_satisfied = 1
elseif (MAWPr < P || MAWPr < MAWP)
    print("Component is unacceptable for operating at the equipment design pressure or equipment MAWP\n")
    print("Part 5 level 2 - Does not satisfy June 2016 API 579-1/ASME FFS-1 Level 2 assessment\n")
        level_2_satisfied = 0
end

# STEP 9 – Evaluate the longitudinal extent of the flaw for cylindrical and conical shells.
if (annex2c_tmin_category == "Cylindrical Shell" || annex2c_tmin_category == "Conical Shell" || annex2c_tmin_category == "Pipe Bends Subject To Internal Pressure" || annex2c_tmin_category == "Pipe Bends Subject To Internal Pressure" || annex2c_tmin_category == "Straight Pipes Subject To Internal Pressure")
    print("The component is a cylindrical shell, conical shell, or elbow\n Begin -- evaluate the circumferential extent\n")
# STEP 9.1 – If Equation (5.13) is satisfied, the circumferential extent is acceptable, and no further evaluation is required. Otherwise, proceed to STEP 9.2.
if (c <= (2*s)*(El/Ec)) # eq (5.13)
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
    MAWPr = MAWPr*(((tmm-FCAml)/tlmin)) #step 8 MAWPr
    print("MAWP for the component can be adjusted using Equation (5.15). Otherwise a Level 2 or Level 3 assessment may be performed.")
end # end step 9.4
elseif (annex2c_tmin_category != "Cylindrical Shell" || annex2c_tmin_category != "Conical Shell" || annex2c_tmin_category != "Pipe Bends Subject To Internal Pressure")
    print("The assessment is complete for all component types\n")
end

labels = ["tc", "tm", "Rt", "lambda", "MAWPc", "MAWPl", "MAWP", "Mt", "RSF", "MAWPr", "P"]
global part_5_level_2_calculated_parameters = [tc, tmm, Rt, lambda, MAWPc, MAWPl, MAWP, Mt, RSF, MAWPr, P]
out = hcat(labels,part_5_level_2_calculated_parameters)
return out
elseif (step6_satisfied == 0)
    print("Step 7 onwards Not Conducted Step 6 not satisfied")
end
end
