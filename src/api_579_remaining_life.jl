# remaining life 4.5.2 MAWP Approach
using Gadfly
using DataFrames
using Cairo

# Data variables

annex2c_tmin_category = "Straight Pipes Subject To Internal Pressure" # ["Cylindrical Shell","Spherical Shell","Hemispherical Head","Elliptical Head","Torispherical Head","Conical Shell","Toriconical Head","Conical Transition","Nozzles Connections in Shells",
# "Junction Reinforcement Requirements at Conical Transitions","Tubesheets","Flat head to cylinder connections","Bolted Flanges","Straight Pipes Subject To Internal Pressure","Boiler Tubes","Pipe Bends Subject To Internal Pressure",
# "MAWP for External Pressure","Branch Connections","API 650 Storage Tanks"]
equipment_group = "piping" # "vessel", "tank"
flaw_location = "external" # "External","Internal"
FCA_string = "internal"
metal_loss_categorization = "LTA" # "LTA" or "Groove-Like Flaw"
units = "lbs-in-psi" # "lbs-in-psi" or "nmm-mm-mpa"
remaining_life = true
tmm_forcing = true
tmm = .222
tnom = .365 # nominal or furnished thickness of the component adjusted for mill undertolerance as applicable.
trd = .365 # uniform thickness away from the local metal loss location established by thickness measurements at the time of the assessment.
FCAml = 0.05 # Future Corrosion Allowance applied to the region of metal loss.
FCA = 0.05 # Future Corrosion Allowance applied to the region away from the metal loss (see Annex 2C, paragraph 2C.2.8).
LOSS = 0.0 #the amount of uniform metal loss away from the local metal loss location at the time of the assessment.
Do = 10.75 # Outside Diameter
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

# STEP 1 – Determine the metal loss of the component, tloss
tloss = tnom - tmm

# STEP 2 – Determine the MAWPr for a series of increasing time increments using an effective corrosion
# allowance and the nominal thickness in the computation. The effective corrosion allowance is determined
# as follows:
time = collect(1.0:1.0:50.0) # years
crate = 0.005 # inches per year
Csrate = 0.005 # long growth
Ccrate = 0.005 # circ growth
CAe = tnom .- (crate .* time)

# STEP 3 – Using the results from STEP 2, determine the remaining life from a plot of the MAWP versus
# time. The time at which the MAWPr curve intersects the equipment design pressure or equipment
# MAWP is the remaining life of the component.
#crate = 0.01
MAWPr_out = zeros(size(time,1))
for i = 1:length(time)
        let c = c, s=s, crate=crate, tloss = tloss
    c = c + Ccrate * time[i]
    s = s + Csrate * time[i]
    tmm = CAe[i]
    out = Part5LTALevel1(CTPGrid; tmm_forcing=tmm_forcing, tmm=tmm, annex2c_tmin_category=annex2c_tmin_category, equipment_group=equipment_group, flaw_location=flaw_location, FCA_string=FCA_string, metal_loss_categorization=metal_loss_categorization, units=units, Lmsd=Lmsd,tnom=tnom,
        trd=trd, FCA=FCA, FCAml=FCAml, LOSS=LOSS, Do=Do, D=D, P=P, S=S, E=E, MA=MA, Yb31=Yb31, t=t,tsl=tsl, spacings=spacings, s=s, c=c, El=El, Ec=Ec, RSFa=RSFa, gl=gl, gw=gw, gr=gr,β=β)
MAWPr_out[i] = out[18,2]
end # let
end

# create dataframe for plotting
df = hcat(MAWPr_out,fill(crate,size(MAWPr_out,1)),time)
df = DataFrame(df)
names = ["MAWPr","Corrosion Rates (ipy)","Time"]
rename!(df, names)
# x axis label
x_label = join(["Time to Design P ",string(P)," psig - Years"],"")

# Plot data
p = plot(df, x=df.Time, y=df.MAWPr, color="Corrosion Rates (ipy)", Geom.line, Scale.y_continuous(format=:plain),
Guide.title("API 579 Remaining Life - tmm revised for specific corrosion rates - Years for MAWPr to reach equipment Design P at a specific corrosion rate (ipy)"), Guide.xlabel(x_label),Guide.ylabel("MAWPr"),
yintercept=[P],
Geom.hline(size=0.5mm, style=:solid, color="red"),
Guide.YTicks(ticks=collect(0:100:1500)),
Guide.XTicks(ticks=time))
draw(PNG("C:/Users/Andrew.Bannerman/OneDrive - Shell/Documents/remaining_life_static_cr_rate.png",12inch,9inch),p)


# Part 5 Remaining life method - note tmm defined vs CTP's use MAWP RL approach
crate = collect(0:0.0025:0.03)
time = collect(1.0:1.0:50.0)
MAWPr = zeros(size(time,1))
remaining_wt = .4
Csrate = 0.005 # long growth
Ccrate = 0.005 # circ growth
rl_out = Array{Float64}(undef, 0, 3)
i=1
j = 10
for i = 1:length(crate)
    let remaining_wt = remaining_wt, c = c, s=s
        for j in 1:length(time)
    tmm = remaining_wt - (crate[i] * time[j])
    c = c + Ccrate * time[j]
    s = s + Csrate * time[j]
    out = Part5LTALevel1(CTPGrid; tmm_forcing=tmm_forcing, tmm=tmm, annex2c_tmin_category=annex2c_tmin_category, equipment_group=equipment_group, flaw_location=flaw_location, FCA_string=FCA_string, metal_loss_categorization=metal_loss_categorization, units=units, Lmsd=Lmsd,tnom=tnom,
        trd=trd, FCA=FCA, FCAml=FCAml, LOSS=LOSS, Do=Do, D=D, P=P, S=S, E=E, MA=MA, Yb31=Yb31, t=t,tsl=tsl, spacings=spacings, s=s, c=c, El=El, Ec=Ec, RSFa=RSFa, gl=gl, gw=gw, gr=gr,β=β)
MAWPr[j] = out[18,2]
print("this is iteration i",i,"this is iteration j",j)
if j == length(time)
    global final_out = hcat(fill(crate[i],size(MAWPr,1)),MAWPr,time)
    global rl_out = vcat(rl_out,final_out)
    end
end # end j loop

end # end let
end # end i loop



df = DataFrame(rl_out)
names = ["Corrosion Rates (ipy)","MAWPr","Time"]
rename!(df, names)

x_label = join(["Time to Design P ",string(P)," psig - Years"],"")

# Plot data
p = plot(df, x=df.Time, y=df.MAWPr, color="Corrosion Rates (ipy)", Geom.line, Scale.y_continuous(format=:plain),
Guide.title("API 579 Remaining Life - tmm revised for varying corrosion rates - Years for MAWPr to reach equipment Design P at varying corrosion rates (ipy)"), Guide.xlabel(x_label),Guide.ylabel("MAWPr"),
yintercept=[P],
Geom.hline(size=0.5mm, style=:solid, color="red"),
Guide.YTicks(ticks=collect(0:100:1500)),
Guide.XTicks(ticks=time))
draw(PNG("C:/Users/Andrew.Bannerman/OneDrive - Shell/Documents/remaining_life.png",12inch,9inch),p)
