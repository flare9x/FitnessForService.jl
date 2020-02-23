
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
    part4_PTR_Level_1_Assessment(x::Array{Float64})::Array{Float64}

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

    # STEP 1 – Take the point thickness reading data in accordance with paragraph 4.3.3 Tam , and the
    # Coefficient Of Variation (COV). A template for computing the COV is provided in Table 4.3.
    # Tam = average measured wall thickness of the component based on the point thickness readings (PTR) measured at the time of the inspection.
    # COV = Coefficient Of Variation.
    # Trd = Thickness reading within corroded
    tmm = minimum(x)
    step_1 = COV_var(x)
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
            tcmin = Pipingtcmin(P; Do=Do, S=S, E=E, Yb31=Yb31, MA=MA)
            tlmin = Pipingtlmin(P, Do=Do, S=S, E=E, Yb31=Yb31, tsl=tsl, MA=MA)
            tmin = maximum([tcmin,tlmin])
            # MAWP
            MAWPc = PipingMAWPc(S, E=E, t=t, MA=MA, Do=Do, Yb31=Yb31) # eq (2C.147)
            print("Piping MAWPc = ",round(MAWPc, digits=3),"psi\n")
            MAWPl = PipingMAWPl(S; E=E, t=t, tsl=tsl, MA=MA, Do=Do, Yb31=Yb31) # eq (2C.150)
            print("Piping MAWPl = ",round(MAWPl, digits=3),"psi\n")
            MAWP = minimum([MAWPc,MAWPl])
            print("Final MAWP = ",round(MAWP, digits=3),"psi\n")

            # tmin level 1 acceptance for PTR
            if (tam - FCAml) >= tcmin
                print("Average Measured Thickness from Point Thickness Readings (PTR) - Level 1 assessment has been satisfied :: (tam - FCAml) >= tcmin == True\n")
            else
                print("Average Measured Thickness from Point Thickness Readings (PTR) - Level 1 assessment has not been satisfied :: (tam - FCAml) >= tcmin == False\n")
            end

            # mawp level 1 acceptance for PTR
            # adjust tam by: (tam - FCAml)
            print("Determine MAWPcr using (tam - FCAml) - Adjust the average thickness (tam) within corroded by future CA applied to the region of corrosion - What is MAWP within corroded whilst maintaining CA as applicable\n")
            t_adj = (tam - FCAml)
            MAWPcr = PipingMAWPc(S, E=E, t=t_adj, MA=MA, Do=Do, Yb31=Yb31) # eq (2C.147)
            print("Piping Within Corroded MAWPcr = ",round(MAWPcr, digits=3),"psi\n")
            MAWPlr = PipingMAWPl(S; E=E, t=t_adj, tsl=tsl, MA=MA, Do=Do, Yb31=Yb31) # eq (2C.150)
            print("Piping Within Corroded MAWPlr = ",round(MAWPlr, digits=3),"psi\n")
            if (MAWPcr >= P)
                print("MAWP from Point Thickness Readings (PTR) - Level 1 assessment has been satisfied :: (MAWPcr >= P) == True\n")
            else
                print("MAWP from Point Thickness Readings (PTR) - Level 1 assessment has not been satisfied :: (MAWPcr >= P) == False\n")
            end

            # Minimum Measured Thickness level 1 for PTR
            tmin = maximum([tcmin,tlmin])
            if units == "lbs-in-psi"
            tlim = maximum([.2*tnom,0.05])
            elseif units ==  "nmm-mm-mpa"
            tlim = maximum([.2*tnom,1.3])
            end

            if (tmm - FCAml) >= maximum([0.5*tmin,tlim])
                print("Minimum Measured Thickness from Point Thickness Readings (PTR) - Level 1 assessment has been satisfied :: (tmm - FCAml) >= maximum([0.5*tmin,tlim]) == True\n")
            else
                print("Minimum Measured Thickness from Point Thickness Readings (PTR) - Level 1 assessment has not been satisfied :: (tmm - FCAml) >= maximum([0.5*tmin,tlim]) == False\n")
            end

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
    elseif (step3_satisfied == 3)
        print("Use CTPs")
    end # PTR logical check
end # function
