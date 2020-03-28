# PART 4 – ASSESSMENT OF GENERAL LOCAL METAL LOSS

using Statistics

print("Begin -- Assessment Applicability and Component Type Checks\n")
creep_range = CreepRangeTemperature("Carbon Steel (UTS ≤ 414MPa (60 ksi))"; design_temperature=100.0, units="nmm-mm-mpa")
design = DesignCodeCriteria("ASME B31.3 Piping Code")
smoothness = Smoothness("Smooth Contour")
cyclic = CyclicService(100, "Meets Part 14")
x = Part4ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="horizontal", material="Carbon and Low Alloy Steels", D=24.75,Lss=120.0,H=0.0, NPS=3.0, design_temperature=100.0, units="lbs-in-psi")
part4_applicability = Part4AsessmentApplicability(x,design,smoothness,cyclic,creep_range)

@doc Part4ComponentType
# single point reading data
x = [0.300, 0.300, 0.300, 0.3, 0.300, 0.275, 0.275, 0.275, 0.275, 0.275, 0.275, 0.240, 0.186, 0.250, 0.280, 0.290, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]

equipment_group = "piping" # "vessel", "tank"\n
annex2c_tmin_category = "Straight Pipes Subject To Internal Pressure" # ["Cylindrical Shell","Spherical Shell","Hemispherical Head","Elliptical Head","Torispherical Head","Conical Shell","Toriconical Head","Conical Transition","Nozzles Connections in Shells",
# "Junction Reinforcement Requirements at Conical Transitions","Tubesheets","Flat head to cylinder connections","Bolted Flanges","Straight Pipes Subject To Internal Pressure","Boiler Tubes","Pipe Bends Subject To Internal Pressure",
# "MAWP for External Pressure","Branch Connections","API 650 Storage Tanks"]\n
flaw_location = "external" # "External","Internal"\n
units = "lbs-in-psi" # "lbs-in-psi" or "nmm-mm-mpa"\n
tnom = .3 # nominal or furnished thickness of the component adjusted for mill undertolerance as applicable.\n
FCAml = 0.05 # Future Corrosion Allowance applied to the region of metal loss.\n
FCA = .0 # Future Corrosion Allowance applied to the region away from the metal loss (see Annex 2C, paragraph 2C.2.8).\n
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
RSFa = 0.9

# For all assessments determine far enough from structural discontinuity
# Flaw-To-Major Structural Discontinuity Spacing
L1msd = [12.0] # distance to the nearest major structural discontinuity.
L2msd = [12.0] # distance to the nearest major structural discontinuity.
L3msd = [12.0] # distance to the nearest major structural discontinuity.
L4msd = [12.0] # distance to the nearest major structural discontinuity.
L5msd = [12.0] # distance to the nearest major structural discontinuity.
Lmsd = minimum([L1msd,L2msd,L3msd,L4msd,L5msd])
if (Lmsd[1] >= (1.8*(sqrt(D*(tnom - LOSS - FCA)))))
    print("Satisfied - Flaw is located far enough from structural discontinuity\n")
    lmsd_satisfied = 1
else
    print("Not satisfied - Flaw is too close to a structural discontinuity - Conduct a level 3 assessment\n")
    lmsd_satisfied = 0
end

# Perform level 1 assessment - Single Point Readings
if (part4_applicability[1] == 1 && lmsd_satisfied == 1) # begin level 1 assessment
part_4_l1_output = part4_PTR_Level_1_Assessment(x; annex2c_tmin_category=annex2c_tmin_category, equipment_group=equipment_group,flaw_location=flaw_location,units=units,tnom=tnom,
    FCAml=FCAml,Do=Do,D=D,P=P,S=S,E=E,MA=MA,Yb31=Yb31,tsl=tsl,t=t)
elseif (part4_applicability[1] == 0 && lmsd_satisfied == 0)
    print("Level 1 Criteria Not Met - Perform Level 3 as applicable")
elseif (part4_applicability[1] == 1 && lmsd_satisfied == 0)
    print("Level 1 Criteria Not Met - Perform Level 3 as applicable")
elseif (part4_applicability[1] == 0 && lmsd_satisfied == 1)
    print("Level 1 Criteria Not Met - Perform Level 3 as applicable")
end

# Perform level 2 assessment  - Single Point Readings
if (part4_applicability[2] == 1 && lmsd_satisfied == 1) # begin level 2 assessment
    #let part_5_lta_output = Array{Any,2},
    part_4_l2_output = part4_PTR_Level_2_Assessment(x; annex2c_tmin_category=annex2c_tmin_category, equipment_group=equipment_group,flaw_location=flaw_location,units=units,tnom=tnom,
        FCAml=FCAml,Do=Do,D=D,P=P,S=S,E=E,MA=MA,Yb31=Yb31,tsl=tsl,t=t,RSFa=RSFa)
    #end # let end
elseif (part4_applicability[1] == 0 && lmsd_satisfied == 0)
    print("Level 2 Criteria Not Met - Perform Level 2 or 3 as applicable")
elseif (part4_applicability[1] == 1 && lmsd_satisfied == 0)
    print("Level 2 Criteria Not Met - Perform Level 2 or 3 as applicable")
elseif (part4_applicability[1] == 0 && lmsd_satisfied == 1)
    print("Level 2 Criteria Not Met - Perform Level 2 or 3 as applicable")
end



# Part 4 level 1/2 - CTP

# For all assessments - determine the inspection data grid
M1 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.3, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M2 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M3 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M4 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.100, 0.220, 0.280, 0.250, 0.240, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M5 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.215, 0.255, 0.215, 0.145, 0.275, 0.170, 0.240, 0.250, 0.250, 0.280, 0.290, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M6 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.170, 0.270, 0.190, 0.190, 0.285, 0.250, 0.225, 0.275, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M7 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M8 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.3, 0.300]
M9 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.3, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
CTPGrid = hcat(M9,M8,M7,M6,M5,M4,M3,M2,M1) # build in descending order
CTPGrid = rotl90(CTPGrid) # rotate to correct orientation

FCA_string = "external" # Application of FCA external / internal
equipment_group = "piping" # "vessel", "tank"\n
annex2c_tmin_category = "Straight Pipes Subject To Internal Pressure" # ["Cylindrical Shell","Spherical Shell","Hemispherical Head","Elliptical Head","Torispherical Head","Conical Shell","Toriconical Head","Conical Transition","Nozzles Connections in Shells",
# "Junction Reinforcement Requirements at Conical Transitions","Tubesheets","Flat head to cylinder connections","Bolted Flanges","Straight Pipes Subject To Internal Pressure","Boiler Tubes","Pipe Bends Subject To Internal Pressure",
# "MAWP for External Pressure","Branch Connections","API 650 Storage Tanks"]\n
flaw_location = "external" # "External","Internal"\n
units = "lbs-in-psi" # "lbs-in-psi" or "nmm-mm-mpa"\n
tnom = .3 # nominal or furnished thickness of the component adjusted for mill undertolerance as applicable.\n
FCAml = 0.05 # Future Corrosion Allowance applied to the region of metal loss.\n
FCA = .0 # Future Corrosion Allowance applied to the region away from the metal loss (see Annex 2C, paragraph 2C.2.8).\n
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
s_spacings=0.5 # grid spacing in longitudinal direction
c_spacings=0.5 # grid circumferential in longitudinal direction
RSFa = 0.9 # remaining strength factor - consult API 579 is go lower than 0.9


# For all assessments determine far enough from structural discontinuity
# Flaw-To-Major Structural Discontinuity Spacing
L1msd = [12.0] # distance to the nearest major structural discontinuity.
L2msd = [12.0] # distance to the nearest major structural discontinuity.
L3msd = [12.0] # distance to the nearest major structural discontinuity.
L4msd = [12.0] # distance to the nearest major structural discontinuity.
L5msd = [12.0] # distance to the nearest major structural discontinuity.
Lmsd = minimum([L1msd,L2msd,L3msd,L4msd,L5msd])
if (Lmsd[1] >= (1.8*(sqrt(D*(tnom - LOSS - FCA)))))
    print("Satisfied - Flaw is located far enough from structural discontinuity\n")
    lmsd_satisfied = 1
else
    print("Not satisfied - Flaw is too close to a structural discontinuity - Conduct a level 3 assessment\n")
    lmsd_satisfied = 0
end

# Perform level 1 assessment - Single Point Readings
if (part4_applicability[1] == 1 && lmsd_satisfied == 1) # begin level 1 assessment
part_4_l1_output = part4_CTP_Level_1_Assessment(CTPGrid; FCA_string=FCA_string,annex2c_tmin_category=annex2c_tmin_category, equipment_group=equipment_group,flaw_location=flaw_location,units=units,tnom=tnom,
    FCAml=FCAml,Do=Do,D=D,P=P,S=S,E=E,MA=MA,Yb31=Yb31,tsl=tsl,t=t)
elseif (part4_applicability[1] == 0 && lmsd_satisfied == 0)
    print("Level 1 Criteria Not Met - Perform Level 3 as applicable")
elseif (part4_applicability[1] == 1 && lmsd_satisfied == 0)
    print("Level 1 Criteria Not Met - Perform Level 3 as applicable")
elseif (part4_applicability[1] == 0 && lmsd_satisfied == 1)
    print("Level 1 Criteria Not Met - Perform Level 3 as applicable")
end

# Perform level 2 assessment
if (part4_applicability[2] == 1 && lmsd_satisfied == 1) # begin level 2 assessment
    #let part_5_lta_output = Array{Any,2},
    part_4_l2_output = part4_CTP_Level_2_Assessment(CTPGrid; FCA_string=FCA_string,annex2c_tmin_category=annex2c_tmin_category, equipment_group=equipment_group,flaw_location=flaw_location,units=units,tnom=tnom,
        FCAml=FCAml,Do=Do,D=D,P=P,S=S,E=E,MA=MA,Yb31=Yb31,tsl=tsl,t=t,RSFa=RSFa)
    #end # let end
elseif (part4_applicability[1] == 0 && lmsd_satisfied == 0)
    print("Level 2 Criteria Not Met - Perform Level 2 or 3 as applicable")
elseif (part4_applicability[1] == 1 && lmsd_satisfied == 0)
    print("Level 2 Criteria Not Met - Perform Level 2 or 3 as applicable")
elseif (part4_applicability[1] == 0 && lmsd_satisfied == 1)
    print("Level 2 Criteria Not Met - Perform Level 2 or 3 as applicable")
end
