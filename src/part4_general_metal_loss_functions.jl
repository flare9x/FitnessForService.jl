
@doc """
    COV_var(x::Array{Float64})::Array{Float64}

Determine Coefficient of Variation, COV
    """ ->
function COV_var(x::Array{Float64})::Array{Float64}
    @assert size(x,1) >= 15 "Minimum of 15 readings required to confirm metal loss is general - provide more readings'"
        index = collect(1:1:size(x,1))
        tam = sum(x) * 1/size(x,1)
        # Calculate (Trdi - Tam) and (Trdi - Tam)^2
trdi_tam = zeros(size(x,1))
trdi_tam_2power = zeros(size(x,1))
for i = 1:size(x,1)
  trdi_tam[i] = x[i] - tam
  trdi_tam_2power[i] = (x[i] - tam)^2
end

S = sum(trdi_tam_2power) # sum (Trdi - Tam)^2 sqaured differences
N = size(x,1)

# COV
COV = (1/tam)*((S/(N-1))^0.5)

    return out = [tam, COV]
end # function

@doc """
    part4_PTR_Level_1_Assessment(x::Array{Float64}; annex2c_tmin_category::String, equipment_group::String="piping",flaw_location::String="external",units::String="lbs-in-psi",tnom::Float64=0.0,
    FCAml::Float64=0.0,Do::Float64=0.0,D::Float64=0.0,P::Float64=0.0,S::Float64=0.0,E::Float64=0.0,MA::Float64=0.0,Yb31::Float64=0.0, tsl::Float64=0.0, t::Float64=0.0)

Average Measured Thickness from Point Thickness Readings (PTR)

Variables\n
equipment_group = "piping" # "vessel", "tank"\n
annex2c_tmin_category = "Straight Pipes Subject To Internal Pressure" # ["Cylindrical Shell","Spherical Shell","Hemispherical Head","Elliptical Head","Torispherical Head","Conical Shell","Toriconical Head","Conical Transition","Nozzles Connections in Shells",
# "Junction Reinforcement Requirements at Conical Transitions","Tubesheets","Flat head to cylinder connections","Bolted Flanges","Straight Pipes Subject To Internal Pressure","Boiler Tubes","Pipe Bends Subject To Internal Pressure",
# "MAWP for External Pressure","Branch Connections","API 650 Storage Tanks"]\n
flaw_location = "external" # "External","Internal"\n
units = "lbs-in-psi" # "lbs-in-psi" or "nmm-mm-mpa"\n
tnom = .3 # nominal or furnished thickness of the component adjusted for mill undertolerance as applicable.\n
FCAml = .05 # Future Corrosion Allowance applied to the region of metal loss.\n
FCA = .05 # Future Corrosion Allowance applied to the region away from the metal loss (see Annex 2C, paragraph 2C.2.8).\n
LOSS = 0 #the amount of uniform metal loss away from the local metal loss location at the time of the assessment.\n
Do = 3.5 # Outside Diameter\n
D = Do - 2*(tnom)  # inside diameter of the shell corrected for FCAml , as applicable\n
P = 1480.0 # internal design pressure.\n
S = 20000.0 # allowable stress.\n
E = 1.0 # weld joint efficiency or quality factor from the original construction code, if unknown use 0.7.\n
MA = 0.0 # mechanical allowances (thread or groove depth); for threaded components, the nominal thread depth (dimension h of ASME B.1.20.1) shall apply.\n
Yb31 = 0.4 # coefficient from ASME B31 Piping codes used for determining the pipe wall thickness, the coefficient can be determined from the following table that is valid for tmin < Do / 6 Annex 2C .\n
t = tnom - LOSS - FCA  # thickness of the shell or pipe adjusted for mill tolerance, LOSS and FCA , or cylinder thickness at a conical transition for a junction reinforcement calculation adjusted for mill tolerance, LOSS and FCA , as applicable.\n
tsl = 0.0 # supplemental thickness for mechanical loads other than pressure that result in longitudinal stress; this thickness is usually obtained from the results of a weight case in a stress analysis of the piping system (see paragraph 2C.2.7).\n

    """ ->
function part4_PTR_Level_1_Assessment(x::Array{Float64}; annex2c_tmin_category::String, equipment_group::String="piping",flaw_location::String="external",units::String="lbs-in-psi",tnom::Float64=0.0,
    FCAml::Float64=0.0,Do::Float64=0.0,D::Float64=0.0,P::Float64=0.0,S::Float64=0.0,E::Float64=0.0,MA::Float64=0.0,Yb31::Float64=0.0, tsl::Float64=0.0, t::Float64=0.0)
    @assert any(annex2c_tmin_category .== ["Cylindrical Shell","Spherical Shell","Hemispherical Head","Elliptical Head","Torispherical Head","Conical Shell","Toriconical Head","Conical Transition","Nozzles Connections in Shells",
    "Junction Reinforcement Requirements at Conical Transitions","Tubesheets","Flat head to cylinder connections","Bolted Flanges","Straight Pipes Subject To Internal Pressure","Boiler Tubes","Pipe Bends Subject To Internal Pressure",
    "MAWP for External Pressure","Branch Connections","API 650 Storage Tanks"]) "Invalid entry must be any of the following tmin groups: 'Cylindrical Shell','Spherical Shell','Hemispherical Head','Elliptical Head','Torispherical Head','Conical Shell','Toriconical Head','Conical Transition','Nozzles Connections in Shells',
    'Junction Reinforcement Requirements at Conical Transitions','Tubesheets','Flat head to cylinder connections','Bolted Flanges','Straight Pipes Subject To Internal Pressure','Boiler Tubes','Pipe Bends Subject To Internal Pressure',
    'MAWP for External Pressure','Branch Connections','API 650 Storage Tanks' "
    @assert any(equipment_group .== ["piping", "vessel", "tank"]) "Invalid input: please enter either: 'piping','vessel','tank' "
    @assert any(flaw_location .== ["external", "internal"]) "Invalid input: please enter either: 'external shells', 'internal shells' "
    @assert any(units .== ["lbs-in-psi", "nmm-mm-mpa"]) "Invalid input: please enter either: 'lbs-in-psi', 'nmm-mm-mpa' "
    @assert size(x,1) >= 15 "Minimum of 15 readings required to confirm metal loss is general - provide more readings'"

    print("Begin -- Part 4 LTA Level 1 Assessment (Point Thickness Readings) - API 579 June 2016 Edition\n")

    # STEP 1 – Take the point thickness reading data in accordance with paragraph 4.3.3 Tam , and the
    # Coefficient Of Variation (COV). A template for computing the COV is provided in Table 4.3.
    # Tam = average measured wall thickness of the component based on the point thickness readings (PTR) measured at the time of the inspection.
    # COV = Coefficient Of Variation.
    # Trd = Thickness reading within corroded
    step_1 = COV_var(x)
    tmm = minimum(x)
    tam = step_1[1]
    c_o_v = step_1[2]

    # STEP 2 – If the COV from STEP 1 is less than or equal to 0.1, then proceed to STEP 3 to complete the
    # assessment using the average thickness, tam . If the COV is greater than 0.1 then the use of thickness
    # profiles should be considered for the assessment (see paragraph 4.4.2.2).
    if c_o_v <= 0.1
        print("COV is <= 0.1 - Procced to Step 3 to complete the assessment using the average thickness tam :: COV = ", round(step_1[2],digits =2),"\n")
        step3_satisfied = 1
    else
        print("COV is > 0.1 - Thickness Profiles should be conisdered for assessment :: (see paragraph 4.4.2.2) :: COV = ", round(step_1[2],digits =2),"\n")
        step3_satisfied = 0
    end

    # STEP 3 – The acceptability of the component for continued operation can be established using the Level 1
    # criteria in Table 4.4, Table 4.5, Table 4.6, and Table 4.7. The averaged measured thickness or
    # MAWP acceptance criterion may be used. In either case, the minimum thickness criterion shall be
    # satisfied. For MAWP acceptance criterion (see Part 2, paragraph 2.4.2.2.e) to determine the
    # acceptability of the equipment for continued operation
    if (step3_satisfied == 1) # begin
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
            # calculate MAWP and Tmin
            # Tmin
            tcmin = Pipingtcmin(P, Do=Do, S=S, E=E, Yb31=Yb31, MA=MA)
            tlmin = Pipingtlmin(P, Do=Do, S=S, E=E, Yb31=Yb31, tsl=tsl, MA=MA)
            tmin = maximum([tcmin,tlmin])
            # MAWP
            MAWPc = PipingMAWPc(S, E=E, t=t, MA=MA, Do=Do, Yb31=Yb31) # eq (2C.147)
            print("Piping MAWPc = ",round(MAWPc, digits=3),"psi\n")
            MAWPl = PipingMAWPl(S; E=E, t=t, tsl=tsl, MA=MA, Do=Do, Yb31=Yb31) # eq (2C.150)
            print("Piping MAWPl = ",round(MAWPl, digits=3),"psi\n")
            MAWP = minimum([MAWPc,MAWPl])
            print("Final MAWP = ",round(MAWP, digits=3),"psi\n")

            # acceptance crtiera
            # tmin level 1 acceptance for PTR
            # The averaged measured thickness or MAWP acceptance criterion may be used. In either case, the minimum thickness criterion shall be satisfied.
            if (tam - FCAml) >= tcmin
                print("Average Measured Thickness from Point Thickness Readings (PTR) - (tam - FCAml) >= tcmin == True\n")
                print("Check the minimum measured thickness criterion.\n")
                tmin_accept=1
            else
                print("Average Measured Thickness from Point Thickness Readings (PTR) - Level 1 assessment has not been satisfied :: (tam - FCAml) >= tcmin == False\n")
                tmin_accept=0
                tmm_accept = 0
            end

            #++ Alternatively ++#
            # mawp level 1 acceptance for PTR
            # adjust tam by: (tam - FCAml)
            print("Alternatively, determine MAWPcr using (tam - FCAml)\n")
            t_adj = (tam - FCAml)
            MAWPcr = PipingMAWPc(S, E=E, t=t_adj, MA=MA, Do=Do, Yb31=Yb31) # eq (2C.147)
            print("Reduced MAWPcr in circumferential or hoop direction = ",round(MAWPcr, digits=3),"psi\n")
            MAWPlr = PipingMAWPl(S; E=E, t=t_adj, tsl=tsl, MA=MA, Do=Do, Yb31=Yb31) # eq (2C.150)
            print("Reduced MAWPlr in longitudinal direction = ",round(MAWPlr, digits=3),"psi\n")
            if (MAWPcr >= P)
                print("MAWP from Point Thickness Readings (PTR) - (MAWPcr >= P) == True\n")
                print("Check the minimum measured thickness criterion.\n")
                mawp_accept=1
            else
                print("MAWP from Point Thickness Readings (PTR) - Level 1 assessment has not been satisfied :: (MAWPcr >= P) == False\n")
                mawp_accept=0
                tmm_accept = 0
            end

            # Minimum Measured Thickness level 1 for PTR
            tmin = maximum([tcmin,tlmin])
            if units == "lbs-in-psi"
            tlim = maximum([.2*tnom,0.05])
            elseif units ==  "nmm-mm-mpa"
            tlim = maximum([.2*tnom,1.3])
            end
            if tmin_accept == 1 || mawp_accept == 1
                    if (tmm - FCAml) >= maximum([0.5*tmin,tlim])
                        print("Minimum Measured Thickness - (tmm - FCAml) >= maximum([0.5*tmin,tlim]) == True\n")
                        tmm_accept = 1
                    else
                        print("Minimum Measured Thickness - Level 1 assessment has not been satisfied :: (tmm - FCAml) >= maximum([0.5*tmin,tlim]) == False\n")
                        tmm_accept = 0
                    end
                end

        if tmin_accept + tmm_accept == 2
            print("Part 4 level 1 - Satisfies June 2016 API 579-1/ASME FFS-1 Level 1 assessment (Averaged Measured Thickness)\n")
        elseif tmin_accept + tmm_accept != 2
            print("Part 4 level 1 - Does not satisfy June 2016 API 579-1/ASME FFS-1 Level 1 assessment\n")
        end
        if mawp_accept + tmm_accept == 2
                print("Part 4 level 1 - Satisfies June 2016 API 579-1/ASME FFS-1 Level 1 assessment (MAWP)\n")
        elseif mawp_accept + tmm_accept != 2
                print("Part 4 level 1 - Does not satisfy June 2016 API 579-1/ASME FFS-1 Level 1 assessment\n")
        end

        # end piping level 1

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
        labels = ["tnom","Do","D","FCA","FCAml","tmm", "tam", "COV", "tcmin", "tlmin", "MAWPc", "MAWPl", "MAWPcr","MAWPlr", "P", "S"]
        global part_4_level_1_ctp_calculated_parameters = [tnom,Do,D,FCA,FCAml,tmm, tam, c_o_v, tcmin, tlmin, MAWPc, MAWPl, MAWPcr, MAWPlr, P, S]
        out = hcat(labels,part_4_level_1_ctp_calculated_parameters)
        return out
    elseif (step3_satisfied == 0)
        print("Use CTPs")
    end # PTR logical check
end # end function

# Level 2 Assessment
@doc """
    part4_PTR_Level_2_Assessment(x::Array{Float64}; annex2c_tmin_category::String, equipment_group::String="piping",flaw_location::String="external",units::String="lbs-in-psi",tnom::Float64=0.0,
    FCAml::Float64=0.0,Do::Float64=0.0,D::Float64=0.0,P::Float64=0.0,S::Float64=0.0,E::Float64=0.0,MA::Float64=0.0,Yb31::Float64=0.0, tsl::Float64=0.0, t::Float64=0.0, RSFa::Float64=0.9)

Average Measured Thickness from Point Thickness Readings (PTR)

Variables\n
equipment_group = "piping" # "vessel", "tank"\n
annex2c_tmin_category = "Straight Pipes Subject To Internal Pressure" # ["Cylindrical Shell","Spherical Shell","Hemispherical Head","Elliptical Head","Torispherical Head","Conical Shell","Toriconical Head","Conical Transition","Nozzles Connections in Shells",
# "Junction Reinforcement Requirements at Conical Transitions","Tubesheets","Flat head to cylinder connections","Bolted Flanges","Straight Pipes Subject To Internal Pressure","Boiler Tubes","Pipe Bends Subject To Internal Pressure",
# "MAWP for External Pressure","Branch Connections","API 650 Storage Tanks"]\n
flaw_location = "external" # "External","Internal"\n
units = "lbs-in-psi" # "lbs-in-psi" or "nmm-mm-mpa"\n
tnom = .3 # nominal or furnished thickness of the component adjusted for mill undertolerance as applicable.\n
FCAml = .05 # Future Corrosion Allowance applied to the region of metal loss.\n
FCA = .05 # Future Corrosion Allowance applied to the region away from the metal loss (see Annex 2C, paragraph 2C.2.8).\n
LOSS = 0 #the amount of uniform metal loss away from the local metal loss location at the time of the assessment.\n
Do = 3.5 # Outside Diameter\n
D = Do - 2*(tnom)  # inside diameter of the shell corrected for FCAml , as applicable\n
P = 1480.0 # internal design pressure.\n
S = 20000.0 # allowable stress.\n
E = 1.0 # weld joint efficiency or quality factor from the original construction code, if unknown use 0.7.\n
MA = 0.0 # mechanical allowances (thread or groove depth); for threaded components, the nominal thread depth (dimension h of ASME B.1.20.1) shall apply.\n
Yb31 = 0.4 # coefficient from ASME B31 Piping codes used for determining the pipe wall thickness, the coefficient can be determined from the following table that is valid for tmin < Do / 6 Annex 2C .\n
t = tnom - LOSS - FCA  # thickness of the shell or pipe adjusted for mill tolerance, LOSS and FCA , or cylinder thickness at a conical transition for a junction reinforcement calculation adjusted for mill tolerance, LOSS and FCA , as applicable.\n
tsl = 0.0 # supplemental thickness for mechanical loads other than pressure that result in longitudinal stress; this thickness is usually obtained from the results of a weight case in a stress analysis of the piping system (see paragraph 2C.2.7).\n

    """ ->
function part4_PTR_Level_2_Assessment(x::Array{Float64}; annex2c_tmin_category::String, equipment_group::String="piping",flaw_location::String="external",units::String="lbs-in-psi",tnom::Float64=0.0,
    FCAml::Float64=0.0,Do::Float64=0.0,D::Float64=0.0,P::Float64=0.0,S::Float64=0.0,E::Float64=0.0,MA::Float64=0.0,Yb31::Float64=0.0, tsl::Float64=0.0, t::Float64=0.0, RSFa::Float64=0.9)
    @assert any(annex2c_tmin_category .== ["Cylindrical Shell","Spherical Shell","Hemispherical Head","Elliptical Head","Torispherical Head","Conical Shell","Toriconical Head","Conical Transition","Nozzles Connections in Shells",
    "Junction Reinforcement Requirements at Conical Transitions","Tubesheets","Flat head to cylinder connections","Bolted Flanges","Straight Pipes Subject To Internal Pressure","Boiler Tubes","Pipe Bends Subject To Internal Pressure",
    "MAWP for External Pressure","Branch Connections","API 650 Storage Tanks"]) "Invalid entry must be any of the following tmin groups: 'Cylindrical Shell','Spherical Shell','Hemispherical Head','Elliptical Head','Torispherical Head','Conical Shell','Toriconical Head','Conical Transition','Nozzles Connections in Shells',
    'Junction Reinforcement Requirements at Conical Transitions','Tubesheets','Flat head to cylinder connections','Bolted Flanges','Straight Pipes Subject To Internal Pressure','Boiler Tubes','Pipe Bends Subject To Internal Pressure',
    'MAWP for External Pressure','Branch Connections','API 650 Storage Tanks' "
    @assert any(equipment_group .== ["piping", "vessel", "tank"]) "Invalid input: please enter either: 'piping','vessel','tank' "
    @assert any(flaw_location .== ["external", "internal"]) "Invalid input: please enter either: 'external shells', 'internal shells' "
    @assert any(units .== ["lbs-in-psi", "nmm-mm-mpa"]) "Invalid input: please enter either: 'lbs-in-psi', 'nmm-mm-mpa' "
    @assert size(x,1) >= 15 "Minimum of 15 readings required to confirm metal loss is general - provide more readings'"

    print("Begin -- Part 4 LTA Level 2 Assessment (Point Thickness Readings) - API 579 June 2016 Edition\n")

    # STEP 1 – Take the point thickness reading data in accordance with paragraph 4.3.3 Tam , and the
    # Coefficient Of Variation (COV). A template for computing the COV is provided in Table 4.3.
    # Tam = average measured wall thickness of the component based on the point thickness readings (PTR) measured at the time of the inspection.
    # COV = Coefficient Of Variation.
    # Trd = Thickness reading within corroded
    step_1 = COV_var(x)
    tmm = minimum(x)
    tam = step_1[1]
    c_o_v = step_1[2]

    # STEP 2 – If the COV from STEP 1 is less than or equal to 0.1, then proceed to STEP 3 to complete the
    # assessment using the average thickness, tam . If the COV is greater than 0.1 then the use of thickness
    # profiles should be considered for the assessment (see paragraph 4.4.2.2).
    if c_o_v <= 0.1
        print("COV is <= 0.1 - Procced to Step 3 to complete the assessment using the average thickness tam :: COV = ", round(step_1[2],digits =2),"\n")
        step3_satisfied = 1
    else
        print("COV is > 0.1 - Thickness Profiles should be conisdered for assessment :: (see paragraph 4.4.2.2) :: COV = ", round(step_1[2],digits =2),"\n")
        step3_satisfied = 0
    end

    # STEP 3 – The acceptability of the component for continued operation can be established using the Level 1
    # criteria in Table 4.4, Table 4.5, Table 4.6, and Table 4.7. The averaged measured thickness or
    # MAWP acceptance criterion may be used. In either case, the minimum thickness criterion shall be
    # satisfied. For MAWP acceptance criterion (see Part 2, paragraph 2.4.2.2.e) to determine the
    # acceptability of the equipment for continued operation
    if (step3_satisfied == 1) # begin
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
            # calculate MAWP and Tmin
            P = P * RSFa # adjust P for tmin calculation
            # Tmin
            tcmin = Pipingtcmin(P, Do=Do, S=S, E=E, Yb31=Yb31, MA=MA)
            tlmin = Pipingtlmin(P, Do=Do, S=S, E=E, Yb31=Yb31, tsl=tsl, MA=MA)
            tmin = maximum([tcmin,tlmin])
            # MAWP
            MAWPc = PipingMAWPc(S, E=E, t=t, MA=MA, Do=Do, Yb31=Yb31) # eq (2C.147)
            print("Piping MAWPc = ",round(MAWPc, digits=3),"psi\n")
            MAWPl = PipingMAWPl(S; E=E, t=t, tsl=tsl, MA=MA, Do=Do, Yb31=Yb31) # eq (2C.150)
            print("Piping MAWPl = ",round(MAWPl, digits=3),"psi\n")
            MAWP = minimum([MAWPc,MAWPl])
            print("Final MAWP = ",round(MAWP, digits=3),"psi\n")

            #########++++++ acceptance crtiera ++++++#########
            # tmin level 1 acceptance for PTR
            # The averaged measured thickness or MAWP acceptance criterion may be used. In either case, the minimum thickness criterion shall be satisfied.
            if (tam - FCAml) >= maximum([tcmin,tlmin])
                print("Average Measured Thickness from Point Thickness Readings (PTR) - (tam - FCAml) >= max([tcmin,tlin]) == True\n")
                print("Check the minimum measured thickness criterion.\n")
                tmin_accept=1
            else
                print("Average Measured Thickness from Point Thickness Readings (PTR) - Level 1 assessment has not been satisfied :: (tam - FCAml) >= max([tcmin,tlin]) == False\n")
                tmin_accept=0
                tmm_accept = 0
            end

            #++ Alternatively ++#
            # mawp level 1 acceptance for PTR
            # adjust tam by: (tam - FCAml)
            print("Alternatively, determine MAWPcr using (tam - FCAml)\n")
            t_adj = (tam - tsl - FCAml)
            MAWPcr = PipingMAWPc(S, E=E, t=t_adj, MA=MA, Do=Do, Yb31=Yb31) # eq (2C.147)
            print("Reduced MAWPcr in circumferential or hoop direction = ",round(MAWPcr, digits=3),"psi\n")
            MAWPlr = PipingMAWPl(S; E=E, t=t_adj, tsl=tsl, MA=MA, Do=Do, Yb31=Yb31) # eq (2C.150)
            print("Reduced MAWPlr in longitudinal direction = ",round(MAWPlr, digits=3),"psi\n")
            if ((minimum([MAWPcr,MAWPlr]) / RSFa) >= P)
                print("MAWP from Point Thickness Readings (PTR) - ((min([MAWPcr,MAWPlr]) / RSFa) >= P) == True\n")
                print("Check the minimum measured thickness criterion.\n")
                mawp_accept=1
            else
                print("MAWP from Point Thickness Readings (PTR) - Level 1 assessment has not been satisfied :: ((min([MAWPcr,MAWPlr]) / RSFa) >= P) == False\n")
                mawp_accept=0
                tmm_accept = 0
            end

            # Minimum Measured Thickness level 1 for PTR
            tmin = maximum([tcmin,tlmin])
            if units == "lbs-in-psi"
            tlim = maximum([.2*tnom,0.05])
            elseif units ==  "nmm-mm-mpa"
            tlim = maximum([.2*tnom,1.3])
            end
            if tmin_accept == 1 || mawp_accept == 1
                    if (tmm - FCAml) >= maximum([0.5*tmin,tlim])
                        print("Minimum Measured Thickness - (tmm - FCAml) >= maximum([0.5*tmin,tlim]) == True\n")
                        tmm_accept = 1
                    else
                        print("Minimum Measured Thickness - Level 1 assessment has not been satisfied :: (tmm - FCAml) >= maximum([0.5*tmin,tlim]) == False\n")
                        tmm_accept = 0
                    end
                end

        if tmin_accept + tmm_accept == 2
            print("Part 4 level 2 - Satisfies June 2016 API 579-1/ASME FFS-1 Level 2 assessment (Averaged Measured Thickness)\n")
        elseif tmin_accept + tmm_accept != 2
            print("Part 4 level 2 - Does not satisfy June 2016 API 579-1/ASME FFS-1 Level 2 assessment\n")
        end
        if mawp_accept + tmm_accept == 2
                print("Part 4 level 2 - Satisfies June 2016 API 579-1/ASME FFS-1 Level 2 assessment (MAWP)\n")
        elseif mawp_accept + tmm_accept != 2
                print("Part 4 level 2 - Does not satisfy June 2016 API 579-1/ASME FFS-1 Level 2 assessment\n")
        end

        # end piping level 1

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
        labels = ["tnom","Do","D","FCA","FCAml","tmm", "tam", "COV", "tcmin", "tlmin", "MAWPc", "MAWPl", "MAWPcr","MAWPlr", "P", "S"]
        global part_4_level_1_ctp_calculated_parameters = [tnom,Do,D,FCA,FCAml,tmm, tam, c_o_v, tcmin, tlmin, MAWPc, MAWPl, MAWPcr, MAWPlr, P, S]
        out = hcat(labels,part_4_level_1_ctp_calculated_parameters)
        return out
    elseif (step3_satisfied == 0)
        print("Use CTPs")
    end # PTR logical check
end # end function

# CTPs

@doc """
part4_CTP_Level_1_Assessment(CTPGrid::Array{Float64,2}; FCA_string::String="external",annex2c_tmin_category::String, equipment_group::String="piping",flaw_location::String="external",units::String="lbs-in-psi",tnom::Float64=0.0,
    FCAml::Float64=0.0,Do::Float64=0.0,D::Float64=0.0,P::Float64=0.0,S::Float64=0.0,E::Float64=0.0,MA::Float64=0.0,Yb31::Float64=0.0, tsl::Float64=0.0, t::Float64=0.0, s_spacings::Float64=0.5, c_spacings::Float64=0.5, RSFa::Float64=0.9)

Average CTP Thickness from Critial Thickness Profile (CTP)

Variables\n
FCA_string = "external" # Application of FCA external / internal\n
equipment_group = "piping" # "vessel", "tank"\n
annex2c_tmin_category = "Straight Pipes Subject To Internal Pressure" # ["Cylindrical Shell","Spherical Shell","Hemispherical Head","Elliptical Head","Torispherical Head","Conical Shell","Toriconical Head","Conical Transition","Nozzles Connections in Shells",
# "Junction Reinforcement Requirements at Conical Transitions","Tubesheets","Flat head to cylinder connections","Bolted Flanges","Straight Pipes Subject To Internal Pressure","Boiler Tubes","Pipe Bends Subject To Internal Pressure",
# "MAWP for External Pressure","Branch Connections","API 650 Storage Tanks"]\n
flaw_location = "external" # "External","Internal"\n
units = "lbs-in-psi" # "lbs-in-psi" or "nmm-mm-mpa"\n
tnom = .3 # nominal or furnished thickness of the component adjusted for mill undertolerance as applicable.\n
FCAml = .05 # Future Corrosion Allowance applied to the region of metal loss.\n
FCA = .05 # Future Corrosion Allowance applied to the region away from the metal loss (see Annex 2C, paragraph 2C.2.8).\n
LOSS = 0 #the amount of uniform metal loss away from the local metal loss location at the time of the assessment.\n
Do = 3.5 # Outside Diameter\n
D = Do - 2*(tnom)  # inside diameter of the shell corrected for FCAml , as applicable\n
P = 1480.0 # internal design pressure.\n
S = 20000.0 # allowable stress.\n
E = 1.0 # weld joint efficiency or quality factor from the original construction code, if unknown use 0.7.\n
MA = 0.0 # mechanical allowances (thread or groove depth); for threaded components, the nominal thread depth (dimension h of ASME B.1.20.1) shall apply.\n
Yb31 = 0.4 # coefficient from ASME B31 Piping codes used for determining the pipe wall thickness, the coefficient can be determined from the following table that is valid for tmin < Do / 6 Annex 2C .\n
t = tnom - LOSS - FCA  # thickness of the shell or pipe adjusted for mill tolerance, LOSS and FCA , or cylinder thickness at a conical transition for a junction reinforcement calculation adjusted for mill tolerance, LOSS and FCA , as applicable.\n
tsl = 0.0 # supplemental thickness for mechanical loads other than pressure that result in longitudinal stress; this thickness is usually obtained from the results of a weight case in a stress analysis of the piping system (see paragraph 2C.2.7).\n
s_spacings = 0.5 # grid spacing in longitudinal direction
c_spacings = 0.5 # grid circumferential in longitudinal direction
RSFa = 0.9 # remaining strength factor - consult API 579 is go lower than 0.9\n
    """ ->
function part4_CTP_Level_1_Assessment(CTPGrid::Array{Float64,2}; FCA_string::String="external",annex2c_tmin_category::String, equipment_group::String="piping",flaw_location::String="external",units::String="lbs-in-psi",tnom::Float64=0.0,
    FCAml::Float64=0.0,Do::Float64=0.0,D::Float64=0.0,P::Float64=0.0,S::Float64=0.0,E::Float64=0.0,MA::Float64=0.0,Yb31::Float64=0.0, tsl::Float64=0.0, t::Float64=0.0, s_spacings::Float64=0.5, c_spacings::Float64=0.5, RSFa::Float64=0.9)
    @assert any(annex2c_tmin_category .== ["Cylindrical Shell","Spherical Shell","Hemispherical Head","Elliptical Head","Torispherical Head","Conical Shell","Toriconical Head","Conical Transition","Nozzles Connections in Shells",
    "Junction Reinforcement Requirements at Conical Transitions","Tubesheets","Flat head to cylinder connections","Bolted Flanges","Straight Pipes Subject To Internal Pressure","Boiler Tubes","Pipe Bends Subject To Internal Pressure",
    "MAWP for External Pressure","Branch Connections","API 650 Storage Tanks"]) "Invalid entry must be any of the following tmin groups: 'Cylindrical Shell','Spherical Shell','Hemispherical Head','Elliptical Head','Torispherical Head','Conical Shell','Toriconical Head','Conical Transition','Nozzles Connections in Shells',
    'Junction Reinforcement Requirements at Conical Transitions','Tubesheets','Flat head to cylinder connections','Bolted Flanges','Straight Pipes Subject To Internal Pressure','Boiler Tubes','Pipe Bends Subject To Internal Pressure',
    'MAWP for External Pressure','Branch Connections','API 650 Storage Tanks' "
    @assert any(equipment_group .== ["piping", "vessel", "tank"]) "Invalid input: please enter either: 'piping','vessel','tank' "
    @assert any(FCA_string .== ["external", "internal"]) "Invalid input: please enter either: 'external', 'internal' "
    @assert any(flaw_location .== ["external", "internal"]) "Invalid input: please enter either: 'external shells', 'internal shells' "

print("Begin -- Part 4 LTA Level 1 Assessment (Critical Thickness Profile) - API 579 June 2016 Edition\n")

    # STEP 1 – Determine the thickness profile data in accordance with paragraph 4.3.3.3 and determine the minimum measured thickness, tmm.
    tmm, long_CTP, circ_CTP = CTP_Grid_Part4(CTPGrid) # tmm = minimum measured thickness determined at the time of the inspection.

    # STEP 2 – Determine the wall thickness and diameter to be used in the assessment using Equation (4.2)
    # and Equation (4.3) or Equation (4.4).
    tml = tnom - FCAml

    # Adjust the FCA by internal and external as below
    FCA_string = "internal"
    if (FCA_string == "internal")
    Dml = D + (2*FCAml) # inside diameter of the shell corrected for FCAml, as applicable.
    elseif (FCA_string == "external")
        Dml = D # inside diameter of the shell corrected for FCAml , as applicable.
    end

    # STEP 3 – Compute the remaining thickness ratio, Rt .
    Rt = (tmm[1]-FCAml) / tml # remaining thickness ratio. # (5.5)

    # STEP 4 – Compute the length for thickness averaging, L where the parameter Q is evaluated using Table 4.8
    # handle cases for Q = 50
    if (Rt < RSFa)
        Q = 1.123*( ( ( ((1-Rt) / (1-(Rt/RSFa))) ^2) -1)^0.5)
    elseif Rt >= RSFa
        Q = 50.0
    end
    L = Q*sqrt(Dml*tml)

    # STEP 5 – Establish the Critical Thickness Profiles (CTP’s) from the thickness profile data (see paragraph 4.3.3.3).
    # Determine the average measured thickness tsam based on the longitudinal CTP and the average measured thickness tcam based on the circumferential CTP.
    # The average measured thicknesses tsam and tcam shall be based on the length L determined in STEP 4 (see Figure 4.19).
    # The length L shall be located on the respective CTP such that the resulting average thickness is a minimum.

    # create index position of grid
    long_index = collect(0:s_spacings:length(long_CTP))
    circ_index = collect(0:c_spacings:length(circ_CTP))
    bounds_grid_error = 0

    # Longitudinal CTP (tsam)
    # find index position of minimum
    long_min = minimum(long_CTP)

    min_index = Int64.(zeros(size(long_CTP,1)))
    for i = 1:length(long_CTP)
        if long_CTP[i] == long_min
             min_index[i] = i
        end
    end

    # reduce
    min_index = min_index[min_index .!= 0][1]

# find thickness to use in averaging
    if L/2 <= s_spacings
        if min_index > 1
        t1 = long_min + (long_CTP[min_index-1] - long_min) * ((L / 2) / s_spacings)
        bounds_grid_error = 0
elseif min_index == 1
    @error "part4_general_metal_loss_functions.jl: Thickness needed for t3 exceeds grid input size"
    @info "Please increase data grid in the circumferential direction so that the correct averaging thickness's are used in the assessment"
    bounds_grid_error = 1
        t1 = long_min + (long_CTP[min_index-1] - long_min) * ((L / 2) / s_spacings)
end

    if min_index < length(long_CTP)
        t2 = long_min + (long_CTP[min_index+1] - long_min) * ((L / 2) / s_spacings)
            bounds_grid_error = 0
    elseif min_index == length(long_CTP)
        @error "part4_general_metal_loss_functions.jl: Thickness needed for t3 exceeds grid input size"
        @info "Please increase data grid in the circumferential direction so that the correct averaging thickness's are used in the assessment"
            bounds_grid_error = 1
            t2 = long_min + (long_CTP[min_index+1] - long_min) * ((L / 2) / s_spacings)
        end

elseif L/2 > s_spacings # find the next thickness over the thickness averaging length/2
    # initialize array
    out = zeros(size(long_index,1))
    for i = 1:length(long_index)
        if L/2 > long_index[i]
            out[i] = true
        end
    end
s_index_pos_for_l = Int64.(sum(out))
# error check for bounds errors
if min_index - s_index_pos_for_l > 0
    t1 = long_min + (long_CTP[min_index-s_index_pos_for_l] - long_min) * ((L / 2) / s_spacings)
        bounds_grid_error = 0
elseif min_index - s_index_pos_for_l <= 0
    @error "part4_general_metal_loss_functions.jl: Thickness needed for t1 exceeds grid input size"
    @info "Please increase data grid in longitudinal direction so that the correct averaging thickness's are used in the assessment"
        bounds_grid_error = 1
    t1 = long_min + (long_CTP[min_index-s_index_pos_for_l] - long_min) * ((L / 2) / s_spacings)
end

if min_index+s_index_pos_for_l > 0
    t2 = long_min + (long_CTP[min_index+s_index_pos_for_l] - long_min) * ((L / 2) / s_spacings)
        bounds_grid_error = 0
elseif min_index+s_index_pos_for_l <= 0
    @error "part4_general_metal_loss_functions.jl: Thickness needed for t2 exceeds grid input size"
    @info "Please increase data grid in longitudinal direction so that the correct averaging thickness's are used in the assessment"
        bounds_grid_error = 1
    t2 = long_min + (long_CTP[min_index+s_index_pos_for_l] - long_min) * ((L / 2) / s_spacings)
end
end

A1 = ((t1 + long_min) / 2) * (L / 2)
A2 = ((t2 + long_min) / 2) * (L / 2)
A = A1 + A2
tsam = A / L

# Circumferential CTP (tcam)
# find index position of minimum
circ_min = minimum(circ_CTP)

min_index = Int64.(zeros(size(circ_CTP,1)))
for i = 1:length(circ_CTP)
    if circ_CTP[i] == circ_min
         min_index[i] = i
    end
end

# reduce
min_index = min_index[min_index .!= 0][1]

# find thickness to use in averaging
    if L/2 <= c_spacings
        if min_index > 1
    t3 = circ_min + (circ_CTP[min_index-1] - circ_min) * ((L / 2) / c_spacings)
        bounds_grid_error = 0
elseif min_index == 1
    @error "part4_general_metal_loss_functions.jl: Thickness needed for t3 exceeds grid input size"
    @info "Please increase data grid in the circumferential direction so that the correct averaging thickness's are used in the assessment"
        bounds_grid_error = 1
    t3 = circ_min + (circ_CTP[min_index-1] - circ_min) * ((L / 2) / c_spacings)
end

    if min_index < length(circ_CTP)
    t4 = circ_min + (circ_CTP[min_index+1] - circ_min) * ((L / 2) / c_spacings)
        bounds_grid_error = 0
    elseif min_index == length(circ_CTP)
        @error "part4_general_metal_loss_functions.jl: Thickness needed for t3 exceeds grid input size"
        @info "Please increase data grid in the circumferential direction so that the correct averaging thickness's are used in the assessment"
            bounds_grid_error = 1
            t4 = circ_min + (circ_CTP[min_index+1] - circ_min) * ((L / 2) / c_spacings)
        end

    elseif L/2 > c_spacings
    # initialize array
    out = zeros(size(circ_index,1))
    for i = 1:length(circ_index)
    if L/2 > circ_index[i]
        out[i] = true
        end
    end

s_index_pos_for_c = Int64.(sum(out))
# error check for bounds errors
if min_index - s_index_pos_for_c > 0
    t3 = long_min + (circ_CTP[min_index-s_index_pos_for_c] - circ_min) * ((L / 2) / c_spacings)
        bounds_grid_error = 0
elseif min_index - s_index_pos_for_c <= 0
    @error "part4_general_metal_loss_functions.jl: Thickness needed for t3 exceeds grid input size"
    @info "Please increase data grid in the circumferential direction so that the correct averaging thickness's are used in the assessment"
        bounds_grid_error = 1
    t3 = long_min + (circ_CTP[min_index-s_index_pos_for_c] - circ_min) * ((L / 2) / c_spacings)
end

if min_index+s_index_pos_for_c > 0
    t4 = long_min + (circ_CTP[min_index+s_index_pos_for_c] - circ_min) * ((L / 2) / c_spacings)
        bounds_grid_error = 0
elseif min_index+s_index_pos_for_c <= 0
    @error "part4_general_metal_loss_functions.jl: Thickness needed for t4 exceeds grid input size"
    @info "Please increase data grid in circumferential direction so that the correct averaging thickness's are used in the assessment"
        bounds_grid_error = 1
    t4 = long_min + (circ_CTP[min_index+s_index_pos_for_c] - circ_min) * ((L / 2) / c_spacings)
end
end

A3 = ((t3 + circ_min) / 2) * (L / 2)
A4 = ((t4 + circ_min) / 2) * (L / 2)
A = A3 + A4
tcam = A / L

# STEP 6 – Based on the values of tsam  and ctascm  from STEP 5, determine the acceptability of the component for continued
# operation using the Level 1 criteria in Table 4.4, Table 4.5, Table 4.6, and Table 4.7, as applicable. The averaged measured
# thickness or MAWP acceptance criterion may be used. In either case, the minimum measured thickness, tmm , shall satisfy the criterion in Table 4.4, Table 4.5,
# Table 4.6 and Table 4.7. For MAWP acceptance criterion (see Part 2, paragraph 2.4.2.2.e) to
# determine the acceptability of the equipment for continued operation.
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
            # calculate MAWP and Tmin
            # Tmin
            tcmin = Pipingtcmin(P, Do=Do, S=S, E=E, Yb31=Yb31, MA=MA)
            tlmin = Pipingtlmin(P, Do=Do, S=S, E=E, Yb31=Yb31, tsl=tsl, MA=MA)
            tmin = maximum([tcmin,tlmin])
            # MAWP
            MAWPc = PipingMAWPc(S, E=E, t=t, MA=MA, Do=Do, Yb31=Yb31) # eq (2C.147)
            print("Piping MAWPc = ",round(MAWPc, digits=3),"psi\n")
            MAWPl = PipingMAWPl(S; E=E, t=t, tsl=tsl, MA=MA, Do=Do, Yb31=Yb31) # eq (2C.150)
            print("Piping MAWPl = ",round(MAWPl, digits=3),"psi\n")
            MAWP = minimum([MAWPc,MAWPl])
            print("Final MAWP = ",round(MAWP, digits=3),"psi\n")

            # acceptance crtiera
            # tmin level 1 acceptance for CTP
            # The averaged measured thickness or MAWP acceptance criterion may be used. In either case, the minimum thickness criterion shall be satisfied.
            if (tsam - FCAml) >= tcmin
                print("Average Measured Thickness Longitudinal CTP (Circumferential Plane) :: (tsam - FCAml) >= tcmin == True\n")
                print("Check the minimum measured thickness criterion.\n")
                tcmin_accept=1
            else
                print("Average Measured Thickness from Longitudinal CTP (Circumferential Plane) - Level 1 assessment has not been satisfied :: (tsam - FCAml) >= tcmin == False\n")
                tcmin_accept=0
                tmm_accept = 0
            end

            if (tcam - FCAml) >= tlmin
                print("Average Measured Thickness from Circumferential CTP (Longitudinal Plane) :: (tcam - FCAml) >= tlmin == True\n")
                print("Check the minimum measured thickness criterion.\n")
                tlmin_accept=1
            else
                print("Average Measured Thickness from Circumferential CTP (Longitudinal Plane) - Level 1 assessment has not been satisfied :: (tcam - FCAml) >= tcmin == False\n")
                tlmin_accept=0
                tmm_accept = 0
            end

            #++ Alternatively ++#
            # mawp level 1 acceptance for PTR
            # adjust tam by: (tam - FCAml)
            print("Alternatively, determine MAWPcr using (tsam - FCAml)\n")
            t_adj = (tsam - FCAml)
            MAWPcr = PipingMAWPc(S, E=E, t=t_adj, MA=MA, Do=Do, Yb31=Yb31) # eq (2C.147)
            print("Reduced MAWPcr in circumferential or hoop direction = ",round(MAWPcr, digits=3),"psi\n")
            t_adj = (tcam - FCAml)
            MAWPlr = PipingMAWPl(S; E=E, t=t_adj, tsl=tsl, MA=MA, Do=Do, Yb31=Yb31) # eq (2C.150)
            print("Reduced MAWPlr in longitudinal direction = ",round(MAWPlr, digits=3),"psi\n")
            final_mawp = minimum([MAWPcr,MAWPlr])
            if (final_mawp >= P)
                print("MAWP from CTP :: (min[MAWPcr,MAWPlr] >= P) == True\n")
                print("Check the minimum measured thickness criterion.\n")
                mawp_accept=1
            else
                print("MAWP from CTP - Level 1 assessment has not been satisfied :: (MAWPcr >= P) == False\n")
                mawp_accept=0
                tmm_accept = 0
            end

            # Minimum Measured Thickness level 1 for CTP
            tmin = maximum([tcmin,tlmin])
            if units == "lbs-in-psi"
            tlim = maximum([.2*tnom,0.05])
            elseif units ==  "nmm-mm-mpa"
            tlim = maximum([.2*tnom,1.3])
            end
            if (tcmin_accept == 1 && tlmin_accept == 1) || mawp_accept == 1
                    if (tmm - FCAml) >= maximum([0.5*tmin,tlim])
                        print("Minimum Measured Thickness - (tmm - FCAml) >= maximum([0.5*tmin,tlim]) == True\n")
                        tmm_accept = 1
                    else
                        print("Minimum Measured Thickness - Level 1 assessment has not been satisfied :: (tmm - FCAml) >= maximum([0.5*tmin,tlim]) == False\n")
                        tmm_accept = 0
                    end
                end

        if tcmin_accept + tlmin_accept + tmm_accept == 3
            print("Part 4 level 1 - Satisfies June 2016 API 579-1/ASME FFS-1 Level 1 assessment (Averaged CTP (over L) Thickness)\n")
        elseif tcmin_accept + tlmin_accept + tmm_accept != 3
            print("Part 4 level 1 - Does not satisfy June 2016 API 579-1/ASME FFS-1 Level 1 assessment (Averaged CTP (over L) Thickness)\n")
        end
        if mawp_accept + tmm_accept == 2
                print("Part 4 level 1 - Satisfies June 2016 API 579-1/ASME FFS-1 Level 1 assessment (Averaged CTP (over L) MAWP)\n")
        elseif mawp_accept + tmm_accept != 2
                print("Part 4 level 1 - Does not satisfy June 2016 API 579-1/ASME FFS-1 Level 1 assessment (Averaged CTP (over L) MAWP)\n")
        end

        # end piping level 1

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

        labels = ["tnom","Do","D","Dml","FCA","FCAml","tmm", "tml", "Rt", "L","tsam","tcam", "tcmin", "tlmin", "MAWPc", "MAWPl", "MAWPcr","MAWPlr", "P", "S", "RSFa"]
        global part_4_level_1_ctp_calculated_parameters = [tnom,Do,D,Dml,FCA,FCAml,tmm, tml, Rt, L ,tsam,tcam, tcmin, tlmin, MAWPc, MAWPl, MAWPcr, MAWPlr, P, S, RSFa]
        out = hcat(labels,part_4_level_1_ctp_calculated_parameters)
        return out
end # function

# Level 2 CTP

@doc """
part4_CTP_Level_2_Assessment(CTPGrid::Array{Float64,2}; FCA_string::String="external",annex2c_tmin_category::String, equipment_group::String="piping",flaw_location::String="external",units::String="lbs-in-psi",tnom::Float64=0.0,
    FCAml::Float64=0.0,Do::Float64=0.0,D::Float64=0.0,P::Float64=0.0,S::Float64=0.0,E::Float64=0.0,MA::Float64=0.0,Yb31::Float64=0.0, tsl::Float64=0.0, t::Float64=0.0, s_spacings::Float64=0.5, c_spacings::Float64=0.5, RSFa::Float64=0.9)

Average CTP Thickness from Critial Thickness Profile (CTP)

Variables\n
FCA_string = "external" # Application of FCA external / internal\n
equipment_group = "piping" # "vessel", "tank"\n
annex2c_tmin_category = "Straight Pipes Subject To Internal Pressure" # ["Cylindrical Shell","Spherical Shell","Hemispherical Head","Elliptical Head","Torispherical Head","Conical Shell","Toriconical Head","Conical Transition","Nozzles Connections in Shells",
# "Junction Reinforcement Requirements at Conical Transitions","Tubesheets","Flat head to cylinder connections","Bolted Flanges","Straight Pipes Subject To Internal Pressure","Boiler Tubes","Pipe Bends Subject To Internal Pressure",
# "MAWP for External Pressure","Branch Connections","API 650 Storage Tanks"]\n
flaw_location = "external" # "External","Internal"\n
units = "lbs-in-psi" # "lbs-in-psi" or "nmm-mm-mpa"\n
tnom = .3 # nominal or furnished thickness of the component adjusted for mill undertolerance as applicable.\n
FCAml = .05 # Future Corrosion Allowance applied to the region of metal loss.\n
FCA = .05 # Future Corrosion Allowance applied to the region away from the metal loss (see Annex 2C, paragraph 2C.2.8).\n
LOSS = 0 #the amount of uniform metal loss away from the local metal loss location at the time of the assessment.\n
Do = 3.5 # Outside Diameter\n
D = Do - 2*(tnom)  # inside diameter of the shell corrected for FCAml , as applicable\n
P = 1480.0 # internal design pressure.\n
S = 20000.0 # allowable stress.\n
E = 1.0 # weld joint efficiency or quality factor from the original construction code, if unknown use 0.7.\n
MA = 0.0 # mechanical allowances (thread or groove depth); for threaded components, the nominal thread depth (dimension h of ASME B.1.20.1) shall apply.\n
Yb31 = 0.4 # coefficient from ASME B31 Piping codes used for determining the pipe wall thickness, the coefficient can be determined from the following table that is valid for tmin < Do / 6 Annex 2C .\n
t = tnom - LOSS - FCA  # thickness of the shell or pipe adjusted for mill tolerance, LOSS and FCA , or cylinder thickness at a conical transition for a junction reinforcement calculation adjusted for mill tolerance, LOSS and FCA , as applicable.\n
tsl = 0.0 # supplemental thickness for mechanical loads other than pressure that result in longitudinal stress; this thickness is usually obtained from the results of a weight case in a stress analysis of the piping system (see paragraph 2C.2.7).\n
s_spacings = 0.5 # grid spacing in longitudinal direction
c_spacings = 0.5 # grid circumferential in longitudinal direction
RSFa = 0.9 # remaining strength factor - consult API 579 is go lower than 0.9\n
    """ ->
function part4_CTP_Level_2_Assessment(CTPGrid::Array{Float64,2}; FCA_string::String="external",annex2c_tmin_category::String, equipment_group::String="piping",flaw_location::String="external",units::String="lbs-in-psi",tnom::Float64=0.0,
    FCAml::Float64=0.0,Do::Float64=0.0,D::Float64=0.0,P::Float64=0.0,S::Float64=0.0,E::Float64=0.0,MA::Float64=0.0,Yb31::Float64=0.0, tsl::Float64=0.0, t::Float64=0.0, s_spacings::Float64=0.5, c_spacings::Float64=0.5, RSFa::Float64=0.9)
    @assert any(annex2c_tmin_category .== ["Cylindrical Shell","Spherical Shell","Hemispherical Head","Elliptical Head","Torispherical Head","Conical Shell","Toriconical Head","Conical Transition","Nozzles Connections in Shells",
    "Junction Reinforcement Requirements at Conical Transitions","Tubesheets","Flat head to cylinder connections","Bolted Flanges","Straight Pipes Subject To Internal Pressure","Boiler Tubes","Pipe Bends Subject To Internal Pressure",
    "MAWP for External Pressure","Branch Connections","API 650 Storage Tanks"]) "Invalid entry must be any of the following tmin groups: 'Cylindrical Shell','Spherical Shell','Hemispherical Head','Elliptical Head','Torispherical Head','Conical Shell','Toriconical Head','Conical Transition','Nozzles Connections in Shells',
    'Junction Reinforcement Requirements at Conical Transitions','Tubesheets','Flat head to cylinder connections','Bolted Flanges','Straight Pipes Subject To Internal Pressure','Boiler Tubes','Pipe Bends Subject To Internal Pressure',
    'MAWP for External Pressure','Branch Connections','API 650 Storage Tanks' "
    @assert any(equipment_group .== ["piping", "vessel", "tank"]) "Invalid input: please enter either: 'piping','vessel','tank' "
    @assert any(FCA_string .== ["external", "internal"]) "Invalid input: please enter either: 'external', 'internal' "
    @assert any(flaw_location .== ["external", "internal"]) "Invalid input: please enter either: 'external shells', 'internal shells' "
    @assert any(units .== ["lbs-in-psi", "nmm-mm-mpa"]) "Invalid input: please enter either: 'lbs-in-psi', 'nmm-mm-mpa' "

print("Begin -- Part 4 LTA Level 2 Assessment (Critical Thickness Profile) - API 579 June 2016 Edition\n")

    # STEP 1 – Determine the thickness profile data in accordance with paragraph 4.3.3.3 and determine the minimum measured thickness, tmm.
    tmm, long_CTP, circ_CTP = CTP_Grid_Part4(CTPGrid) # tmm = minimum measured thickness determined at the time of the inspection.

    # STEP 2 – Determine the wall thickness and diameter to be used in the assessment using Equation (4.2)
    # and Equation (4.3) or Equation (4.4).
    tml = tnom - FCAml

    # Adjust the FCA by internal and external as below
    FCA_string = "internal"
    if (FCA_string == "internal")
    Dml = D + (2*FCAml) # inside diameter of the shell corrected for FCAml, as applicable.
    elseif (FCA_string == "external")
        Dml = D # inside diameter of the shell corrected for FCAml , as applicable.
    end

    # STEP 3 – Compute the remaining thickness ratio, Rt .
    Rt = (tmm[1]-FCAml) / tml # remaining thickness ratio. # (5.5)

    # STEP 4 – Compute the length for thickness averaging, L where the parameter Q is evaluated using Table 4.8
    # handle cases for Q = 50
    if (Rt < RSFa)
        Q = 1.123*( ( ( ((1-Rt) / (1-(Rt/RSFa))) ^2) -1)^0.5)
    elseif Rt >= RSFa
        Q = 50.0
    end
    L = Q*sqrt(Dml*tml)

    # STEP 5 – Establish the Critical Thickness Profiles (CTP’s) from the thickness profile data (see paragraph 4.3.3.3).
    # Determine the average measured thickness tsam based on the longitudinal CTP and the average measured thickness tcam based on the circumferential CTP.
    # The average measured thicknesses tsam and tcam shall be based on the length L determined in STEP 4 (see Figure 4.19).
    # The length L shall be located on the respective CTP such that the resulting average thickness is a minimum.

    # create index position of grid
    long_index = collect(0:s_spacings:length(long_CTP))
    circ_index = collect(0:c_spacings:length(circ_CTP))
    bounds_grid_error = 0

    # Longitudinal CTP (tsam)
    # find index position of minimum
    long_min = minimum(long_CTP)

    min_index = Int64.(zeros(size(long_CTP,1)))
    for i = 1:length(long_CTP)
        if long_CTP[i] == long_min
             min_index[i] = i
        end
    end

    # reduce
    min_index = min_index[min_index .!= 0][1]

# find thickness to use in averaging
    if L/2 <= s_spacings
        if min_index > 1
        t1 = long_min + (long_CTP[min_index-1] - long_min) * ((L / 2) / s_spacings)
        bounds_grid_error = 0
elseif min_index == 1
    @error "part4_general_metal_loss_functions.jl: Thickness needed for t3 exceeds grid input size"
    @info "Please increase data grid in the circumferential direction so that the correct averaging thickness's are used in the assessment"
    bounds_grid_error = 1
        t1 = long_min + (long_CTP[min_index-1] - long_min) * ((L / 2) / s_spacings)
end

    if min_index < length(long_CTP)
        t2 = long_min + (long_CTP[min_index+1] - long_min) * ((L / 2) / s_spacings)
            bounds_grid_error = 0
    elseif min_index == length(long_CTP)
        @error "part4_general_metal_loss_functions.jl: Thickness needed for t3 exceeds grid input size"
        @info "Please increase data grid in the circumferential direction so that the correct averaging thickness's are used in the assessment"
            bounds_grid_error = 1
            t2 = long_min + (long_CTP[min_index+1] - long_min) * ((L / 2) / s_spacings)
        end

elseif L/2 > s_spacings # find the next thickness over the thickness averaging length/2
    # initialize array
    out = zeros(size(long_index,1))
    for i = 1:length(long_index)
        if L/2 > long_index[i]
            out[i] = true
        end
    end
s_index_pos_for_l = Int64.(sum(out))
# error check for bounds errors
if min_index - s_index_pos_for_l > 0
    t1 = long_min + (long_CTP[min_index-s_index_pos_for_l] - long_min) * ((L / 2) / s_spacings)
        bounds_grid_error = 0
elseif min_index - s_index_pos_for_l <= 0
    @error "part4_general_metal_loss_functions.jl: Thickness needed for t1 exceeds grid input size"
    @info "Please increase data grid in longitudinal direction so that the correct averaging thickness's are used in the assessment"
        bounds_grid_error = 1
    t1 = long_min + (long_CTP[min_index-s_index_pos_for_l] - long_min) * ((L / 2) / s_spacings)
end

if min_index+s_index_pos_for_l > 0
    t2 = long_min + (long_CTP[min_index+s_index_pos_for_l] - long_min) * ((L / 2) / s_spacings)
        bounds_grid_error = 0
elseif min_index+s_index_pos_for_l <= 0
    @error "part4_general_metal_loss_functions.jl: Thickness needed for t2 exceeds grid input size"
    @info "Please increase data grid in longitudinal direction so that the correct averaging thickness's are used in the assessment"
        bounds_grid_error = 1
    t2 = long_min + (long_CTP[min_index+s_index_pos_for_l] - long_min) * ((L / 2) / s_spacings)
end
end

A1 = ((t1 + long_min) / 2) * (L / 2)
A2 = ((t2 + long_min) / 2) * (L / 2)
A = A1 + A2
tsam = A / L

# Circumferential CTP (tcam)
# find index position of minimum
circ_min = minimum(circ_CTP)

min_index = Int64.(zeros(size(circ_CTP,1)))
for i = 1:length(circ_CTP)
    if circ_CTP[i] == circ_min
         min_index[i] = i
    end
end

# reduce
min_index = min_index[min_index .!= 0][1]

# find thickness to use in averaging
    if L/2 <= c_spacings
        if min_index > 1
    t3 = circ_min + (circ_CTP[min_index-1] - circ_min) * ((L / 2) / c_spacings)
        bounds_grid_error = 0
elseif min_index == 1
    @error "part4_general_metal_loss_functions.jl: Thickness needed for t3 exceeds grid input size"
    @info "Please increase data grid in the circumferential direction so that the correct averaging thickness's are used in the assessment"
        bounds_grid_error = 1
    t3 = circ_min + (circ_CTP[min_index-1] - circ_min) * ((L / 2) / c_spacings)
end

    if min_index < length(circ_CTP)
    t4 = circ_min + (circ_CTP[min_index+1] - circ_min) * ((L / 2) / c_spacings)
        bounds_grid_error = 0
    elseif min_index == length(circ_CTP)
        @error "part4_general_metal_loss_functions.jl: Thickness needed for t3 exceeds grid input size"
        @info "Please increase data grid in the circumferential direction so that the correct averaging thickness's are used in the assessment"
            bounds_grid_error = 1
            t4 = circ_min + (circ_CTP[min_index+1] - circ_min) * ((L / 2) / c_spacings)
        end

    elseif L/2 > c_spacings
    # initialize array
    out = zeros(size(circ_index,1))
    for i = 1:length(circ_index)
    if L/2 > circ_index[i]
        out[i] = true
        end
    end

s_index_pos_for_c = Int64.(sum(out))
# error check for bounds errors
if min_index - s_index_pos_for_c > 0
    t3 = long_min + (circ_CTP[min_index-s_index_pos_for_c] - circ_min) * ((L / 2) / c_spacings)
        bounds_grid_error = 0
elseif min_index - s_index_pos_for_c <= 0
    @error "part4_general_metal_loss_functions.jl: Thickness needed for t3 exceeds grid input size"
    @info "Please increase data grid in the circumferential direction so that the correct averaging thickness's are used in the assessment"
        bounds_grid_error = 1
    t3 = long_min + (circ_CTP[min_index-s_index_pos_for_c] - circ_min) * ((L / 2) / c_spacings)
end

if min_index+s_index_pos_for_c > 0
    t4 = long_min + (circ_CTP[min_index+s_index_pos_for_c] - circ_min) * ((L / 2) / c_spacings)
        bounds_grid_error = 0
elseif min_index+s_index_pos_for_c <= 0
    @error "part4_general_metal_loss_functions.jl: Thickness needed for t4 exceeds grid input size"
    @info "Please increase data grid in circumferential direction so that the correct averaging thickness's are used in the assessment"
        bounds_grid_error = 1
    t4 = long_min + (circ_CTP[min_index+s_index_pos_for_c] - circ_min) * ((L / 2) / c_spacings)
end
end

A3 = ((t3 + circ_min) / 2) * (L / 2)
A4 = ((t4 + circ_min) / 2) * (L / 2)
A = A3 + A4
tcam = A / L

# STEP 6 – Based on the values of tsam  and ctascm  from STEP 5, determine the acceptability of the component for continued
# operation using the Level 1 criteria in Table 4.4, Table 4.5, Table 4.6, and Table 4.7, as applicable. The averaged measured
# thickness or MAWP acceptance criterion may be used. In either case, the minimum measured thickness, tmm , shall satisfy the criterion in Table 4.4, Table 4.5,
# Table 4.6 and Table 4.7. For MAWP acceptance criterion (see Part 2, paragraph 2.4.2.2.e) to
# determine the acceptability of the equipment for continued operation.
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
            # calculate MAWP and Tmin
            P = P * RSFa
            # Tmin
            tcmin = Pipingtcmin(P, Do=Do, S=S, E=E, Yb31=Yb31, MA=MA)
            tlmin = Pipingtlmin(P, Do=Do, S=S, E=E, Yb31=Yb31, tsl=tsl, MA=MA)
            tmin = maximum([tcmin,tlmin])
            # MAWP
            MAWPc = PipingMAWPc(S, E=E, t=t, MA=MA, Do=Do, Yb31=Yb31) # eq (2C.147)
            print("Piping MAWPc = ",round(MAWPc, digits=3),"psi\n")
            MAWPl = PipingMAWPl(S; E=E, t=t, tsl=tsl, MA=MA, Do=Do, Yb31=Yb31) # eq (2C.150)
            print("Piping MAWPl = ",round(MAWPl, digits=3),"psi\n")
            MAWP = minimum([MAWPc,MAWPl])
            print("Final MAWP = ",round(MAWP, digits=3),"psi\n")

            # acceptance crtiera
            # tmin level 1 acceptance for CTP
            # The averaged measured thickness or MAWP acceptance criterion may be used. In either case, the minimum thickness criterion shall be satisfied.
            if (tsam - FCAml) >= tcmin
                print("Average Measured Thickness Longitudinal CTP (Circumferential Plane) :: (tsam - FCAml) >= tcmin == True\n")
                print("Check the minimum measured thickness criterion.\n")
                tcmin_accept=1
            else
                print("Average Measured Thickness from Longitudinal CTP (Circumferential Plane) - Level 2 assessment has not been satisfied :: (tsam - FCAml) >= tcmin == False\n")
                tcmin_accept=0
                tmm_accept = 0
            end

            if (tcam - FCAml) >= tlmin
                print("Average Measured Thickness from Circumferential CTP (Longitudinal Plane) :: (tcam - FCAml) >= tlmin == True\n")
                print("Check the minimum measured thickness criterion.\n")
                tlmin_accept=1
            else
                print("Average Measured Thickness from Circumferential CTP (Longitudinal Plane) - Level 2 assessment has not been satisfied :: (tcam - FCAml) >= tcmin == False\n")
                tlmin_accept=0
                tmm_accept = 0
            end

            #++ Alternatively ++#
            # mawp level 1 acceptance for PTR
            # adjust tam by: (tam - FCAml)
            print("Alternatively, determine MAWPcr using (tsam - FCAml)\n")
            t_adj = (tsam - FCAml)
            MAWPcr = PipingMAWPc(S, E=E, t=t_adj, MA=MA, Do=Do, Yb31=Yb31) # eq (2C.147)
            print("Reduced MAWPcr in circumferential or hoop direction = ",round(MAWPcr, digits=3),"psi\n")
            t_adj = (tcam - tsl - FCAml)
            MAWPlr = PipingMAWPl(S; E=E, t=t_adj, tsl=tsl, MA=MA, Do=Do, Yb31=Yb31) # eq (2C.150)
            print("Reduced MAWPlr in longitudinal direction = ",round(MAWPlr, digits=3),"psi\n")
            final_mawp = minimum([MAWPcr,MAWPlr])
            if ((final_mawp / RSFa) >= P)
                print("MAWP from CTP :: ((min[MAWPcr,MAWPlr] / RSFa) >= P) == True\n")
                print("Check the minimum measured thickness criterion.\n")
                mawp_accept=1
            else
                print("MAWP from CTP - Level 2 assessment has not been satisfied :: (MAWPcr >= P) == False\n")
                mawp_accept=0
                tmm_accept = 0
            end

            # Minimum Measured Thickness level 1 for CTP
            tmin = maximum([tcmin,tlmin])
            if units == "lbs-in-psi"
            tlim = maximum([.2*tnom,0.05])
            elseif units ==  "nmm-mm-mpa"
            tlim = maximum([.2*tnom,1.3])
            end
            if (tcmin_accept == 1 && tlmin_accept == 1) || mawp_accept == 1
                    if (tmm - FCAml) >= maximum([0.5*tmin,tlim])
                        print("Minimum Measured Thickness - (tmm - FCAml) >= maximum([0.5*tmin,tlim]) == True\n")
                        tmm_accept = 1
                    else
                        print("Minimum Measured Thickness - Level 2 assessment has not been satisfied :: (tmm - FCAml) >= maximum([0.5*tmin,tlim]) == False\n")
                        tmm_accept = 0
                    end
                end

        if tcmin_accept + tlmin_accept + tmm_accept == 3
            print("Part 4 level 2 - Satisfies June 2016 API 579-1/ASME FFS-1 Level 2 assessment (Averaged CTP (over L) Thickness)\n")
        elseif tcmin_accept + tlmin_accept + tmm_accept != 3
            print("Part 4 level 2 - Does not satisfy June 2016 API 579-1/ASME FFS-1 Level 2 assessment (Averaged CTP (over L) Thickness)\n")
        end
        if mawp_accept + tmm_accept == 2
                print("Part 4 level 2 - Satisfies June 2016 API 579-1/ASME FFS-1 Level 2 assessment (Averaged CTP (over L) MAWP)\n")
        elseif mawp_accept + tmm_accept != 2
                print("Part 4 level 2 - Does not satisfy June 2016 API 579-1/ASME FFS-1 Level 2 assessment (Averaged CTP (over L) MAWP)\n")
        end

        # end piping level 1

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

        labels = ["tnom","Do","D","Dml","FCA","FCAml","tmm", "tml", "Rt", "L","tsam","tcam", "tcmin", "tlmin", "MAWPc", "MAWPl", "MAWPcr","MAWPlr", "P", "S", "RSFa"]
        global part_4_level_1_ctp_calculated_parameters = [tnom,Do,D,Dml,FCA,FCAml,tmm, tml, Rt, L ,tsam,tcam, tcmin, tlmin, MAWPc, MAWPl, MAWPcr, MAWPlr, P, S, RSFa]
        out = hcat(labels,part_4_level_1_ctp_calculated_parameters)
        return out
end # function
