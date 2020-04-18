# PART 5 – ASSESSMENT OF LOCAL METAL LOSS

using DataFrames
using CSV

# Determine Asessment Applicability
#Determine the assessment applicability
# @doc DesignCodeCriteria
# @doc MaterialToughness
# @doc CyclicService
# @doc Part5ComponentType
print("Begin -- Assessment Applicability and Component Type Checks\n")
creep_range = CreepRangeTemperature("Carbon Steel (UTS ≤ 414MPa (60 ksi))"; design_temperature=100.0, units="lbs-in-psi")
design = DesignCodeCriteria("ASME B31.3 Piping Code")
toughness = MaterialToughness("Certain")
cyclic = CyclicService(100, "Meets Part 14")
x = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="horizontal", material="Carbon and Low Alloy Steels", D=24.75,Lss=120.0,H=0.0, NPS=10.0, design_temperature=100.0, units="lbs-in-psi")
part5_applicability = Part5AsessmentApplicability(x,design,toughness,cyclic,creep_range)


# For all assessments - determine the inspection data grid
M1 = [0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500]
M2 = [0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500]
M3 = [0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500]
M4 = [0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500]
M5 = [0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500]
M6 = [0.220, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500]
CTPGrid = hcat(M6,M5,M4,M3,M2,M1) # build in descending order
CTPGrid = rotl90(CTPGrid) # rotate to correct orientation

# Level 1 fit for service
annex2c_tmin_category = "Straight Pipes Subject To Internal Pressure" # ["Cylindrical Shell","Spherical Shell","Hemispherical Head","Elliptical Head","Torispherical Head","Conical Shell","Toriconical Head","Conical Transition","Nozzles Connections in Shells",
# "Junction Reinforcement Requirements at Conical Transitions","Tubesheets","Flat head to cylinder connections","Bolted Flanges","Straight Pipes Subject To Internal Pressure","Boiler Tubes","Pipe Bends Subject To Internal Pressure",
# "MAWP for External Pressure","Branch Connections","API 650 Storage Tanks"]
equipment_group = "piping" # "vessel", "tank"
flaw_location = "external" # "External","Internal"
FCA_string = "external"
metal_loss_categorization = "LTA" # "LTA" or "Groove-Like Flaw"
units = "lbs-in-psi" # "lbs-in-psi" or "nmm-mm-mpa"
tmm_forcing = true
tmm = .165
tnom = 0.280 # nominal or furnished thickness of the component adjusted for mill undertolerance as applicable.
trd = 0.280 # uniform thickness away from the local metal loss location established by thickness measurements at the time of the assessment.
FCAml = 0.05 # Future Corrosion Allowance applied to the region of metal loss.
FCA = 0.05 # Future Corrosion Allowance applied to the region away from the metal loss (see Annex 2C, paragraph 2C.2.8).
LOSS = 0.045 #the amount of uniform metal loss away from the local metal loss location at the time of the assessment.
Do = 6.625 # Outside Diameter
D = Do - 2*(tnom) # Inside Dia.
P = 740.0 # internal design pressure.
S = 20000.0 # allowable stress.
E = 1.0 # weld joint efficiency or quality factor from the original construction code, if unknown use 0.7.
MA = 0.0 # mechanical allowances (thread or groove depth); for threaded components, the nominal thread depth (dimension h of ASME B.1.20.1) shall apply.
Yb31 = 0.4 # coefficient from ASME B31 Piping codes used for determining the pipe wall thickness, the coefficient can be determined from the following table that is valid for tmin < Do / 6 Annex 2C .
t = trd - LOSS - FCA # thickness of the shell or pipe adjusted for mill tolerance, LOSS and FCA , or cylinder thickness at a conical transition for a junction reinforcement calculation adjusted for mill tolerance, LOSS and FCA , as applicable.
tsl = 0.0 # supplemental thickness for mechanical loads other than pressure that result in longitudinal stress; this thickness is usually obtained from the results of a weight case in a stress analysis of the piping system (see paragraph 2C.2.7).
spacings = 0.5 # spacings determine by visual inspection to adequately ccategorizse the corrosion -----------+ may add to CTP_Grid function for plotting purposes
# Flaw dimensions
s = 6.0 # longitudinal extent or length of the region of local metal loss based on future corroded thickness,
c = 2.0  # circumferential extent or length of the region of local metal loss (see Figure 5.2 and Figure 5.10), based on future corroded thickness, tc .
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
Lmsd = minimum([L1msd,L2msd,L3msd,L4msd,L5msd])[1]
if (Lmsd >= (1.8*(sqrt(D*(trd - LOSS - FCA)))))
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

FCAml_i = collect(0:0.0001:.3)
RCA_out = zeros(19)
iterations_count = zeros(size(FCAml_i,1))
data_temp = FCAml_i[1]
i=1

# Iterate to find MAWPr maximum FCAml
for i = 1:size(FCAml_i,1)
    iterations_count[i] = i
    let RCA_out = RCA_out, data_temp = data_temp

    FCAml = FCAml_i[i]
    global part_5_lta_output = Part5LTALevel1(CTPGrid; tmm_forcing=tmm_forcing, tmm=tmm, annex2c_tmin_category=annex2c_tmin_category, equipment_group=equipment_group, flaw_location=flaw_location, FCA_string=FCA_string, metal_loss_categorization=metal_loss_categorization, units=units, Lmsd=Lmsd, tnom=tnom,
        trd=trd, FCA=FCA, FCAml=FCAml, LOSS=LOSS, Do=Do, D=D, P=P, S=S, E=E, MA=MA, Yb31=Yb31, t=t,tsl=tsl, spacings=spacings, s=s, c=c, El=El, Ec=Ec, RSFa=RSFa, gl=gl, gw=gw, gr=gr,β=β)

data_temp = part_5_lta_output[size(part_5_lta_output,1)+1:length(part_5_lta_output)]
RCA_out = append!(RCA_out , data_temp)

    end
end


max = Int64.(maximum(iterations_count))
if max == size(FCAml_i,1)
    RCA_out = reshape(RCA_out,19,max+1)
else
    RCA_out = reshape(RCA_out,19,max)
end
RCA_out = RCA_out[:,2:size(RCA_out,2)]

names_df = hcat(String.(part_5_lta_output[1:size(part_5_lta_output,1)]),RCA_out)

df = DataFrame(names_df)

CSV.write("C:/Users/Andrew.Bannerman/Desktop/MARS/15. PoC/3.24/PS_out_FCA.csv", df;delim=',')

# account for variance in the MRWT
mrwt = tmm
upper = mrwt + .1
lower = mrwt - 0.1
x = collect(lower:0.0005:upper)
perc = (x .- mrwt) / mrwt *100
iterations_count = zeros(size(x,1))
data_out = zeros(19)
data_temp = x[1]

# Save datafrmaes

x_out = DataFrame(hcat(x))
perc_out = DataFrame(hcat(perc))

CSV.write("C:/Users/Andrew.Bannerman/Desktop/MARS/15. PoC/3.24/x_out.csv", x_out;delim=',')
CSV.write("C:/Users/Andrew.Bannerman/Desktop/MARS/15. PoC/3.24/perc_out.csv", perc_out;delim=',')

for i = 1:size(x,1)
    iterations_count[i] = i
    let data_out = data_out, data_temp = data_temp

    part_5_lta_output = Part5LTALevel1(CTPGrid; tmm_forcing=tmm_forcing, tmm=x[i], annex2c_tmin_category=annex2c_tmin_category, equipment_group=equipment_group, flaw_location=flaw_location, FCA_string=FCA_string, metal_loss_categorization=metal_loss_categorization, units=units, Lmsd=Lmsd, tnom=tnom,
        trd=trd, FCA=FCA, FCAml=FCAml, LOSS=LOSS, Do=Do, D=D, P=P, S=S, E=E, MA=MA, Yb31=Yb31, t=t,tsl=tsl, spacings=spacings, s=s, c=c, El=El, Ec=Ec, RSFa=RSFa, gl=gl, gw=gw, gr=gr,β=β)
data_temp = part_5_lta_output[size(part_5_lta_output,1)+1:length(part_5_lta_output)]
data_out = append!(data_out , data_temp)

    end
end


max = Int64.(maximum(iterations_count))
if max == size(x,1)
    data_out = reshape(data_out,19,max+1)
else
    data_out = reshape(data_out,19,max)
end
data_out = data_out[:,2:size(data_out,2)] # subet

names_df = hcat(String.(part_5_lta_output[1:19]),data_out)


df = DataFrame(names_df)

CSV.write("C:/Users/Andrew.Bannerman/Desktop/MARS/15. PoC/3.24/mawpr_thickness_sensitivty.csv", df;delim=',')
