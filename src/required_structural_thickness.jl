#############################################################################################
# Calculating the Required Structural Thickness of Pipe Using Beam Stress Theory
#############################################################################################
# Input parameters
P = 850 # pressure
Do = 12.75 # outside diameter
S = 17900 # code allowable stress
E = .85 # weld joint efficieny
W = 1.0
Y = 0.4
tnom = .375
D = Do - (2*(tnom)) # inside diameter
psteel = .284 # density of the steel = 0.284 lb/in3
tinsul = 3.0 # insulation thickness
pinsul = 0.004919 # density of insulation - note set at calcium silicate lb/in3
pproduct = 8.5 # product density (Water)  lb/gal
My = 0.1071 # Moment in the Y direction (up or down), in-lb
span = 24 # in feet
y = Do / 2 # distance from the center axis to the outer stress element, (1/2 Diameter), in


# Step 1 - Determine tpress , the thickness needed to contain the design pressure at the design temperature
# Pressure design thickness
t = (P * Do) / (2*((S * E * W) + (P * Y)))

# Step 2 -  Determine the weight of each component that contributes to the overall weight of the piping system.
# This includes the weight of the pipe, the fluid inside, the insulation, and the weight of any external items.

# Determine weight of pipe = determine the cross sectional area of the new pipe and multiply by the density of steel
wpipe = ((Do-(tnom / 2)) * π * tnom * psteel)

# Determine weight of the insulation
winsul = (Do + tinsul) * π * tinsul * pinsul

# Determine weight of the fluid
r = D/2
h = D
# Calculate volme of the fluid (cubic gal)
area = acos((r-h)/r) * r^2 - (r-h) * sqrt(2*r*h - h^2)
volume_cubic_inch = area * 12
volume_cubic_gal = volume_cubic_inch / 231

wprod = (volume_cubic_gal * pproduct) / 12 # lb/inches

#####
# Consideration for the weight from other external influences should be considered and added.   Items such as ice, snow, or even animals may be appropriate,
# depending on location and conditions.  If the additional weight is from a point load condition, refer to AISC Beam Deflection Table for the appropriate moment calculation.
######

wother = 0.0 # lb/inch

# Step 3 -  Determine the Moments that will be used to calculate the bending stress in the pipe.  The Moments are loads created due to the weight of the overall piping system
My = My * (wpipe + wprod + winsul + wother) * ((span * 12)^2)

# Determine structural wall thickness
# Beam Flexural Stress Method
# The required minimum structural thickness of the pipe is derived from the Moment of Inertia needed to limit the bending stress to the maximum allowable stress levels
# Step 4
σmax = S # code allowable stress limit

# If the effect of wind loading is ignored, then σy = σmax because forces are only acting in the downward direction, -Y.
σy = (My * y)  / σmax # in4

# Step 5
# σy = (π / 64) * (Do^4 - x^4) # use algebra to solve for x
# find x
# divide both sides by (π / 64)
solve = σy / (π / 64) # (Do^4 - x^4) = (28.77 / (π / 64))
# subtract Do^4 from both sides
solve = solve - Do^4 # -x^4 = solve - Do^4
solve = solve *-1
Di = (solve)^(1/4)
Ipipe = (π / 64) * (Do^4 - Di^4)

# Step 6 - Calcualte the minimum structural thickness
tstruct = (Do - Di) / 2


####################################### specific pipe case

#############################################################################################
# Calculating the Required Structural Thickness of Pipe Using Beam Stress Theory
#############################################################################################
# Input parameters
P = 285 # pressure
Do = 2.375 # outside diameter
S = 20000 # code allowable stress
E = 1 # weld joint efficieny
W = 1.0
Y = 0.4
tnom = 0.218
D = Do - (2*(tnom)) # inside diameter
psteel = .284 # density of the steel = 0.284 lb/in3
tinsul = 0.0 # insulation thickness
pinsul = 0.0049 # density of insulation - note set at calcium silicate lb/in3
pproduct = 8.5 # product density (Water)  lb/gal
My = 0.1071
span = 20 # in feet
y = Do / 2 # distance from the center axis to the outer stress element, (1/2 Diameter), in


# Step 1 - Determine tpress , the thickness needed to contain the design pressure at the design temperature
# Pressure design thickness
t = (P * Do) / (2*((S * E * W) + (P * Y)))

# Step 2 -  Determine the weight of each component that contributes to the overall weight of the piping system.
# This includes the weight of the pipe, the fluid inside, the insulation, and the weight of any external items.

# Determine weight of pipe = determine the cross sectional area of the new pipe and multiply by the density of steel
wpipe = ((Do-(tnom / 2)) * π * tnom * psteel)

# Determine weight of the insulation
winsul = (Do + tinsul) * π * tinsul * pinsul

# Determine weight of the fluid
r = D/2
h = D
# Calculate volme of the fluid (cubic gal)
area = acos((r-h)/r) * r^2 - (r-h) * sqrt(2*r*h - h^2)
volume_cubic_inch = area * 12
volume_cubic_gal = volume_cubic_inch / 231

wprod = (volume_cubic_gal * pproduct) / 12 # lb/inches

#####
# Consideration for the weight from other external influences should be considered and added.   Items such as ice, snow, or even animals may be appropriate,
# depending on location and conditions.  If the additional weight is from a point load condition, refer to AISC Beam Deflection Table for the appropriate moment calculation.
######

wother = 0.0 # lb/inch

# Step 3 -  Determine the Moments that will be used to calculate the bending stress in the pipe.  The Moments are loads created due to the weight of the overall piping system
My = My * (wpipe + wprod + winsul + wother) * ((span * 12)^2)

# Determine structural wall thickness
# Beam Flexural Stress Method
# The required minimum structural thickness of the pipe is derived from the Moment of Inertia needed to limit the bending stress to the maximum allowable stress levels
# Step 4
σmax = S # code allowable stress limit

# If the effect of wind loading is ignored, then σy = σmax because forces are only acting in the downward direction, -Y.
σy = (My * y)  / σmax # in4

# Step 5
# σy = (π / 64) * (Do^4 - x^4) # use algebra to solve for x
# find x
# divide both sides by (π / 64)
solve = σy / (π / 64) # (Do^4 - x^4) = (28.77 / (π / 64))
# subtract Do^4 from both sides
solve = solve - Do^4 # -x^4 = solve - Do^4
solve = solve *-1
Di = (solve)^(1/4)
Ipipe = (π / 64) * (Do^4 - Di^4)

# Step 6 - Calcualte the minimum structural thickness
tstruct = (Do - Di) / 2
print("Structural tmin - bend stress theory = ", tstruct)

#### iteration
spans = collect(1:1:60)
out = zeros(size(spans,1))

for i = 1:size(spans,1)
    # Input parameters
    P = 285 # pressure
    Do = 2.375 # outside diameter
    S = 20000 # code allowable stress
    E = 1 # weld joint efficieny
    W = 1.0
    Y = 0.4
    tnom = 0.218
    D = Do - (2*(tnom)) # inside diameter
    psteel = .284 # density of the steel = 0.284 lb/in3
    tinsul = 0.0 # insulation thickness
    pinsul = 0.0049 # density of insulation - note set at calcium silicate lb/in3
    pproduct = 8.5 # product density (Water)  lb/gal
    My = 0.1071
    span = spans[i] # in feet
    y = Do / 2 # distance from the center axis to the outer stress element, (1/2 Diameter), in


    # Step 1 - Determine tpress , the thickness needed to contain the design pressure at the design temperature
    # Pressure design thickness
    t = (P * Do) / (2*((S * E * W) + (P * Y)))

    # Step 2 -  Determine the weight of each component that contributes to the overall weight of the piping system.
    # This includes the weight of the pipe, the fluid inside, the insulation, and the weight of any external items.

    # Determine weight of pipe = determine the cross sectional area of the new pipe and multiply by the density of steel
    wpipe = ((Do - (tnom / 2)) * π * tnom * psteel)

    # Determine weight of the insulation
    winsul = (Do + tinsul) * π * tinsul * pinsul

    # Determine weight of the fluid
    r = D/2
    h = D
    # Calculate volme of the fluid (cubic gal)
    area = acos((r-h)/r) * r^2 - (r-h) * sqrt(2*r*h - h^2)
    volume_cubic_inch = area * 12
    volume_cubic_gal = volume_cubic_inch / 231

    wprod = (volume_cubic_gal * pproduct) / 12 # lb/inches

    #####
    # Consideration for the weight from other external influences should be considered and added.   Items such as ice, snow, or even animals may be appropriate,
    # depending on location and conditions.  If the additional weight is from a point load condition, refer to AISC Beam Deflection Table for the appropriate moment calculation.
    ######

    wother = 0.0 # lb/inch

    # Step 3 -  Determine the Moments that will be used to calculate the bending stress in the pipe.  The Moments are loads created due to the weight of the overall piping system
    My = My * (wpipe + wprod + winsul + wother) * (span * 12)^2

    # Determine structural wall thickness
    # Beam Flexural Stress Method
    # The required minimum structural thickness of the pipe is derived from the Moment of Inertia needed to limit the bending stress to the maximum allowable stress levels
    # Step 4
    σmax = S # code allowable stress limit

    # If the effect of wind loading is ignored, then σy = σmax because forces are only acting in the downward direction, -Y.
    σy = (My * y)  / σmax # in4

    # Step 5
    # σy = (π / 64) * (Do^4 - x^4) # use algebra to solve for x
    # find x
    # divide both sides by (π / 64)
    solve = σy / (π / 64) # (Do^4 - x^4) = (28.77 / (π / 64))
    # subtract Do^4 from both sides
    solve = solve - Do^4 # -x^4 = solve - Do^4
    solve = solve *-1
    Di = (solve)^(1/4)
    Ipipe = (π / 64) * (Do^4 - Di^4)

    # Step 6 - Calcualte the minimum structural thickness
    tstruct = (Do - Di) / 2

    out[i] = tstruct
end

for i = 1:size(out,1)
    if out[i] == 0.0
        out[i] = NaN
    end
end

using DataFrames
using CSV
using Gadfly
df = DataFrame(hcat(spans,out))
#CSV.write("C:/Users/Andrew.Bannerman/Desktop/MARS/struct_out1.csv", df;delim=',')

plot(x=df.x1,y=df.x2, Geom.line,Theme(default_color=colorant"blue"),
Theme(background_color="white"),
Guide.title("Structural Required Thickness for Varying pipe spans - 2 inch sch 80"),
Guide.xlabel("Span"),
Guide.ylabel("tstructural"),
Guide.yticks(ticks = collect(0:.05:.75)),
Guide.xticks(ticks = collect(0:5:60)))
