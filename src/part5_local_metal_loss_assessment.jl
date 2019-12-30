# PART 5 – ASSESSMENT OF LOCAL METAL LOSS

# Determine Asessment Applicability
""" Determine the assessment applicability
@doc DesignCodeCriteria
@doc MaterialToughness
@doc CyclicService
@doc Part5ComponentType
"""
print("Begin -- Assessment Applicability and Component Type Checks\n")
design = DesignCodeCriteria("ASME B31.3 Piping Code")
toughness = MaterialToughness("Certain")
cylic = CyclicService(100, "Meets Part 14")
x = Part5ComponentType("Straight Section of Piping, Eblow or Bend - No Structural Attachments", vessel_orientation="horizontal", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=3.0, design_temperature=100.0, units="lbs-in-psi")
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
#if (lmsd_satisfied == 1) # begin level 1 assessment
    annex2c_tmin_category = "Straight Pipes Subject To Internal Pressure" # ["Cylindrical Shell","Spherical Shell","Hemispherical Head","Elliptical Head","Torispherical Head","Conical Shell","Toriconical Head","Conical Transition","Nozzles Connections in Shells",
    # "Junction Reinforcement Requirements at Conical Transitions","Tubesheets","Flat head to cylinder connections","Bolted Flanges","Straight Pipes Subject To Internal Pressure","Boiler Tubes","Pipe Bends Subject To Internal Pressure",
    # "MAWP for External Pressure","Branch Connections","API 650 Storage Tanks"]
    equipment_group = "piping" # "vessel", "tank"
    flaw_location = "external" # "External","Internal"
    metal_loss_categorization = "LTA" # "LTA" or "groove"
    units = "lbs-in-psi" # "lbs-in-psi" or "nmm-mm-mpa"
    tnom = .3 # nominal or furnished thickness of the component adjusted for mill undertolerance as applicable.
    trd = .3 # uniform thickness away from the local metal loss location established by thickness measurements at the time of the assessment.
    FCAml = 0.0 # Future Corrosion Allowance applied to the region of metal loss.
    FCA = 0.0 # Future Corrosion Allowance applied to the region away from the metal loss (see Annex 2C, paragraph 2C.2.8).
    LOSS = 0.0 #the amount of uniform metal loss away from the local metal loss location at the time of the assessment.
    Do = 3.5 # Outside Diameter
    D = Do - 2*(tnom)
    P = 1480.0 # internal design pressure.
    S = 20000.0 # allowable stress.
    E = 1.0 # weld joint efficiency or quality factor from the original construction code, if unknown use 0.7.
    MA = 0.0 # mechanical allowances (thread or groove depth); for threaded components, the nominal thread depth (dimension h of ASME B.1.20.1) shall apply.
    Yb31 = 0.4 # coefficient from ASME B31 Piping codes used for determining the pipe wall thickness, the coefficient can be determined from the following table that is valid for tmin < Do / 6 Annex 2C .
    t = trd # thickness of the shell or pipe adjusted for mill tolerance, LOSS and FCA , or cylinder thickness at a conical transition for a junction reinforcement calculation adjusted for mill tolerance, LOSS and FCA , as applicable.
    tsl = 0.0 # supplemental thickness for mechanical loads other than pressure that result in longitudinal stress; this thickness is usually obtained from the results of a weight case in a stress analysis of the piping system (see paragraph 2C.2.7).
    spacings = 0.5 # spacings determine by visual inspection to adequately ccategorizse the corrosion -----------+ may add to CTP_Grid function for plotting purposes
    # Flaw dimensions
    s = 6.0 # longitudinal extent or length of the region of local metal loss based on future corroded thickness,
    c = 2.0 # circumferential extent or length of the region of local metal loss (see Figure 5.2 and Figure 5.10), based on future corroded thickness, tc .
    El = 1.0
    Ec = 1.0
    RSFa = 0.9

    part_5_lta_output = Part5LTALevel1("Straight Pipes Subject To Internal Pressure"; equipment_group="piping", flaw_location="external", metal_loss_categorization="LTA", units="lbs-in-psi", tnom=.3,
            trd=.3, FCA=0.0, FCAml=0.0, LOSS=0.0, Do=3.5, D=2.9, P=1480.0, S=20000.0, E=1.0, MA=0.0, Yb31=0.4, tsl=0.0, spacings=0.5, s=6.0, c=2.0, El=1.0, Ec=1.0, RSFa=0.9)

    # For all assessments determine far enough from structural discontinuity
    # Flaw-To-Major Structural Discontinuity Spacing
    L1msd = [12.0] # distance to the nearest major structural discontinuity.
    L2msd = [12.0] # distance to the nearest major structural discontinuity.
    L3msd = [12.0] # distance to the nearest major structural discontinuity.
    L4msd = [12.0] # distance to the nearest major structural discontinuity.
    L5msd = [12.0] # distance to the nearest major structural discontinuity.
    Lmsd = minimum([L1msd,L2msd,L3msd,L4msd,L5msd])
    if (Lmsd[1] >= (1.8*(sqrt(D*(trd - LOSS - FCA)))))
        print("Satisfied - Flaw is located far enough from structural discontinuity")
        lmsd_satisfied = 1
    else
        print("Not satisfied - Flaw is too close to a structural discontinuity - Conduct a level 3 assessment")
        lmsd_satisfied = 0
    end

# Perform level 1 assessment
if (part5_applicability[1] == 1 && lmsd_satisfied == 1) # begin level 1 assessment

part_5_lta_output = Part5LTALevel1(annex2c_tmin_category; equipment_group=equipment_group, flaw_location=flaw_location, metal_loss_categorization=metal_loss_categorization, units=units, tnom=tnom,
        trd=trd, FCA=FCA, FCAml=FCAml, LOSS=LOSS, Do=Do, D=D, P=P, S=S, E=E, MA=MA, Yb31=Yb31, tsl=tsl, spacings=spacings, s=s, c=c, El=El, Ec=Ec, RSFa=RSFa)
end

part_5_lta_output
#============================


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
