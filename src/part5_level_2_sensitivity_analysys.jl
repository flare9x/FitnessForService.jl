# Sensitivty Analysis
random_set = collect(.200:.005:.300)
final_MAWP_out = zeros(10000)

for i in 1:size(final_MAWP_out,1)
    print("this is iteration", i,"\n")
# For all assessments - determine the inspection data grid
M1 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M2 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.100, rand(random_set), rand(random_set), rand(random_set), rand(random_set), 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M3 = [0.300, 0.300, 0.300, 0.300, 0.300, rand(random_set), rand(random_set), rand(random_set), rand(random_set), rand(random_set), rand(random_set), rand(random_set), rand(random_set), rand(random_set), rand(random_set), rand(random_set), 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M4 = [0.300, 0.300, 0.300, 0.300, 0.300, rand(random_set), rand(random_set), rand(random_set), rand(random_set), rand(random_set), rand(random_set), rand(random_set), rand(random_set), 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M5 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
M6 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
CTPGrid = hcat(M6,M5,M4,M3,M2,M1) # build in descending order
global CTPGrid = rotl90(CTPGrid) # rotate to correct orientation
CTPGrid[4,6]
# Level 1 fit for service
annex2c_tmin_category = "Straight Pipes Subject To Internal Pressure" # ["Cylindrical Shell","Spherical Shell","Hemispherical Head","Elliptical Head","Torispherical Head","Conical Shell","Toriconical Head","Conical Transition","Nozzles Connections in Shells",
# "Junction Reinforcement Requirements at Conical Transitions","Tubesheets","Flat head to cylinder connections","Bolted Flanges","Straight Pipes Subject To Internal Pressure","Boiler Tubes","Pipe Bends Subject To Internal Pressure",
# "MAWP for External Pressure","Branch Connections","API 650 Storage Tanks"]
equipment_group = "piping" # "vessel", "tank"
flaw_location = "external" # "External","Internal"
FCA_string = "external"
metal_loss_categorization = "LTA" # "LTA" or "Groove-Like Flaw"
units = "lbs-in-psi" # "lbs-in-psi" or "nmm-mm-mpa"
tnom = .3 # nominal or furnished thickness of the component adjusted for mill undertolerance as applicable.
trd = .3 # uniform thickness away from the local metal loss location established by thickness measurements at the time of the assessment.
FCAml = 0.07 # Future Corrosion Allowance applied to the region of metal loss.
FCA = 0.0 # Future Corrosion Allowance applied to the region away from the metal loss (see Annex 2C, paragraph 2C.2.8).
LOSS = 0.0 #the amount of uniform metal loss away from the local metal loss location at the time of the assessment.
Do = 3.5 # Outside Diameter
D = Do - 2*(tnom)
P = 1480.0 # internal design pressure.
S = 20000.0 # allowable stress.
E = 1.0 # weld joint efficiency or quality factor from the original construction code, if unknown use 0.7.
MA = 0.0 # mechanical allowances (thread or groove depth); for threaded components, the nominal thread depth (dimension h of ASME B.1.20.1) shall apply.
Yb31 = 0.4 # coefficient from ASME B31 Piping codes used for determining the pipe wall thickness, the coefficient can be determined from the following table that is valid for tmin < Do / 6 Annex 2C .
t = trd - LOSS - FCAml # thickness of the shell or pipe adjusted for mill tolerance, LOSS and FCA , or cylinder thickness at a conical transition for a junction reinforcement calculation adjusted for mill tolerance, LOSS and FCA , as applicable.
tsl = 0.0 # supplemental thickness for mechanical loads other than pressure that result in longitudinal stress; this thickness is usually obtained from the results of a weight case in a stress analysis of the piping system (see paragraph 2C.2.7).
spacings = 0.5 # spacings determine by visual inspection to adequately ccategorizse the corrosion -----------+ may add to CTP_Grid function for plotting purposes
# Flaw dimensions
s = 6.0 # longitudinal extent or length of the region of local metal loss based on future corroded thickness,
c = 2.0 # circumferential extent or length of the region of local metal loss (see Figure 5.2 and Figure 5.10), based on future corroded thickness, tc .
Ec = 1.0 # circumferential weld joint efficiency. note if damage on weld see # 2C.2.5 Treatment of Weld and Riveted Joint Efficiency, and Ligament Efficiency
El = 1.0 # longitudinal weld joint efficiency. note if damage on weld see # 2C.2.5 Treatment of Weld and Riveted Joint Efficiency, and Ligament Efficiency
RSFa = 0.9 # remaining strength factor - consult API 579 is go lower than 0.9

# For all assessments determine far enough from structural discontinuity
# Flaw-To-Major Structural Discontinuity Spacing
L1msd = [12.0] # distance to the nearest major structural discontinuity.
L2msd = [12.0] # distance to the nearest major structural discontinuity.
L3msd = [12.0] # distance to the nearest major structural discontinuity.
L4msd = [12.0] # distance to the nearest major structural discontinuity.
L5msd = [12.0] # distance to the nearest major structural discontinuity.
Lmsd = minimum([L1msd,L2msd,L3msd,L4msd,L5msd])
if (Lmsd[1] >= (1.8*(sqrt(D*(trd - LOSS - FCA)))))
    print("Satisfied - Flaw is located far enough from structural discontinuity\n")
    lmsd_satisfied = 1
else
    print("Not satisfied - Flaw is too close to a structural discontinuity - Conduct a level 3 assessment\n")
    lmsd_satisfied = 0
end

# Groove Like Flaw dimensions
gl = .05 # length of the Groove-Like Flaw based on future corroded condition.
gw = .4 # width of the Groove-Like Flaw based on future corroded condition.
gr = 0.1 # radius at the base of a Groove-Like Flaw based on future corroded condition.
β = 40.0 # see (Figure 5.4) :: orientation of the groove-like flaw with respect to the longitudinal axis or a parameter to compute an effective fracture toughness for a groove being evaluated as a crack-like flaw, as applicable.

# Perform level 1 assessment
if (part5_applicability[1] == 1 && lmsd_satisfied == 1) # begin level 1 assessment
    #let part_5_lta_output = Array{Any,2},
    part_5_lta_output = Part5LTALevel2(CTPGrid; annex2c_tmin_category=annex2c_tmin_category, equipment_group=equipment_group, flaw_location=flaw_location, FCA_string=FCA_string, metal_loss_categorization=metal_loss_categorization, units=units, Lmsd=Lmsd, tnom=tnom,
        trd=trd, FCA=FCA, FCAml=FCAml, LOSS=LOSS, Do=Do, D=D, P=P, S=S, E=E, MA=MA, Yb31=Yb31, tsl=tsl, t=t,spacings=spacings, s=s, c=c, El=El, Ec=Ec, RSFa=RSFa, gl=gl, gw=gw, gr=gr,β=β)
    #end # let end
    part_5_lta_output
    final_MAWP_out[i] = part_5_lta_output[10,2]
elseif (part5_applicability[1] == 0 && lmsd_satisfied == 0)
    print("Level 1 Criteria Not Met - Perform Level 2 or 3 as applicable")
elseif (part5_applicability[1] == 1 && lmsd_satisfied == 0)
    print("Level 1 Criteria Not Met - Perform Level 2 or 3 as applicable")
elseif (part5_applicability[1] == 0 && lmsd_satisfied == 1)
    print("Level 1 Criteria Not Met - Perform Level 2 or 3 as applicable")
end
end # end random for loop

#output
using DataFrames
using CSV
using Statistics
out = DataFrame(hcat(final_MAWP_out))

labels = ["Average MAWPr", "Maximum MAWPr", "Minimum MAWPr", "Actual MAWPr (known grid)"]
average_MAWPr = mean(final_MAWP_out)
max_MAWPr = maximum(final_MAWP_out)
min_MAWPr = minimum(final_MAWP_out)
actual_MAWPr = part_5_lta_output[10,2]

mawp_stats = [average_MAWPr, max_MAWPr, min_MAWPr, actual_MAWPr]
stats_out = hcat(labels,mawp_stats)

CSV.write("C:/Users/Andrew.Bannerman/OneDrive - Shell/Documents/API CODES/level_2_LTA_grid_assumption_MAWPr_out_case_3.csv", out;delim=',')

# s and c random
s = 6.0 # longitudinal extent or length of the region of local metal loss based on future corroded thickness,
c = 2.0 # circumferential extent or length of the region of local metal loss (see Figure 5.2 and Figure 5.10), based on future corroded thickness, tc .
Ec = 1.0 # circumferential weld joint efficiency. note if damage on weld see # 2C.2.5 Treatment of Weld and Riveted Joint Efficiency, and Ligament Efficiency
El = 1.0 # longitudinal weld joint efficiency. note if damage on weld see # 2C.2.5 Treatment of Weld and Riveted Joint Efficiency, and Ligament Efficiency

s_random = collect(6.0:.5:20.0)
c_random = collect(2.0:.5:12.0)

step_9_satisfied = zeros(5000)
criteria = zeros(5000)
c_param = zeros(5000)

for i in 1:5000
    c = rand(c_random)
    s = rand(s_random)
if (c <= (2*s)*(El/Ec)) # eq (5.13)  # original = 38
    print("eq 5.13 satisfied - no further evaluation is required\n")
    step_9_satisfied[i] = 1.0
    criteria[i] = ((2*s)*(El/Ec))
    c_param[i] = c
else
    print("eq 5.13 not satisfied - Proceed to STEP 9.2\n")
    step_9_satisfied[i] = 0.0
    criteria[i] = ((2*s)*(El/Ec))
    c_param[i] = c
end # end step 9.1
end # end loop
