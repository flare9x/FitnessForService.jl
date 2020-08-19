# ANNEX 2C – THICKNESS, MAWP AND STRESS EQUATIONS FOR A FFS ASSESSMENT

# 2C.2.5 Treatment of Weld and Riveted Joint Efficiency, and Ligament Efficiency
#+++ condiser weld joint efficient for damage over welds +++ to add

# 2C.2.6 Treatment of Damage in Formed Heads
#+++ If damage (e.g. corrosion/erosion, pitting, etc.) occurs in the center section of an elliptical or torispherical head +++ to add

#2C.3 Pressure Vessels and Boiler Components – Internal Pressure
# 2C.3.3 Cylindrical Shells
# 2C.3.4 Spherical Shell or Hemispherical Head
# 2C.3.5 Elliptical Head
# 2C.3.6 Torispherical Head
# 2C.3.7 Conical Shell
# 2C.3.8 Toriconical Head
# 2C.3.9 Conical Transition
# 2C.3.10 Nozzles Connections in Shells
#2C.3.12 Other Components
# 2C.3.11 Junction Reinforcement Requirements at Conical Transitions
# Tubesheets: VIII-1 Part UHX, VIII-2, Part 4, paragraph 4.18 or TEMA.
# Flat head to cylinder connections: VIII-1 paragraph UG-34 or VIII-2, Part 4, paragraph 4.3.
# Bolted Flanges: VIII-1, Appendix 2 or VIII-2, Part 4, paragraph 4.16.
#2C.4 Pressure Vessels and Boiler Components – External Pressure
# 2C.5.3 Required Thickness and MAWP – Straight Pipes Subject To Internal Pressure
@doc """
    Pipingtcmin(P::Float64; Do::Float64=0.0, S::Float64=0.0, E::Float64=0.0, Yb31::Float64=0.0, MA::Float64=0.0)

2C.5 Piping Components and Boiler Tubes - equation (2C.146)\n
Circumferential stress (Longitudinal Joints)\n
Minimum required thickness based on the circumferential membrane stress for a cylinder or cone, as applicable\n
Do # Outside Diameter\n
P # internal design pressure\n
S # allowable stress\n
E # weld joint efficiency or quality factor from the original construction code, if unknown use 0.7\n
MA # mechanical allowances (thread or groove depth); for threaded components, the nominal thread depth (dimension h of ASME B.1.20.1) shall apply\n
Yb31 # coefficient from ASME B31 Piping codes used for determining the pipe wall thickness, the coefficient can be determined from the following table that is valid for tmin < Do / 6 Annex 2C\n
t = trd # thickness of the shell or pipe adjusted for mill tolerance, LOSS and FCA , or cylinder thickness at a conical transition for a junction reinforcement calculation adjusted for mill tolerance, LOSS and FCA , as applicable\n
""" ->
function Pipingtcmin(P::Float64; Do::Float64=0.0, S::Float64=0.0, E::Float64=0.0, Yb31::Float64=0.0, MA::Float64=0.0)
    tcmin = ((P*Do) / (2*((S*E) + (P*Yb31)))) + MA # (2C.146)
    return tcmin
end


@doc """
    PipingMAWPc(S::Float64; E::Float64=0.0, t::Float64=0.0, MA::Float64=0.0, Do::Float64=0.0, Yb31::Float64=0.0)

2C.5 Piping Components and Boiler Tubes - equation (2C.147)\n
Circumferential stress (Longitudinal Joints)\n
Maximum allowable working pressure based on circumferential stress\n
Do # Outside Diameter\n
S # allowable stress\n
E # weld joint efficiency or quality factor from the original construction code, if unknown use 0.7\n
MA # mechanical allowances (thread or groove depth); for threaded components, the nominal thread depth (dimension h of ASME B.1.20.1) shall apply\n
Yb31 # coefficient from ASME B31 Piping codes used for determining the pipe wall thickness, the coefficient can be determined from the following table that is valid for tmin < Do / 6 Annex 2C\n
t = trd # thickness of the shell or pipe adjusted for mill tolerance, LOSS and FCA , or cylinder thickness at a conical transition for a junction reinforcement calculation adjusted for mill tolerance, LOSS and FCA , as applicable\n
""" ->
function PipingMAWPc(S::Float64; E::Float64=0.0, t::Float64=0.0, MA::Float64=0.0, Do::Float64=0.0, Yb31::Float64=0.0)
    MAWPc = (2*S*E*(t-MA))/(Do-(2*Yb31*(t-MA))) # eq (2C.147)
    return MAWPc
end

@doc """
    PipingOcm(P::Float64; E::Float64=0.0, Do::Float64=0.0, t::Float64=0.0, MA::Float64=0.0, Yb31::Float64=0.0)

2C.5 Piping Components and Boiler Tubes - equation (2C.148)\n
Circumferential stress (Longitudinal Joints)\n
Nominal circumferential membrane stress for a cylinder or cone, as applicable\n
Do # Outside Diameter\n
P # internal design pressure\n
S # allowable stress\n
E # weld joint efficiency or quality factor from the original construction code, if unknown use 0.7\n
MA # mechanical allowances (thread or groove depth); for threaded components, the nominal thread depth (dimension h of ASME B.1.20.1) shall apply\n
Yb31 # coefficient from ASME B31 Piping codes used for determining the pipe wall thickness, the coefficient can be determined from the following table that is valid for tmin < Do / 6 Annex 2C\n
t = trd # thickness of the shell or pipe adjusted for mill tolerance, LOSS and FCA , or cylinder thickness at a conical transition for a junction reinforcement calculation adjusted for mill tolerance, LOSS and FCA , as applicable\n

""" ->
function PipingOcm(P::Float64; E::Float64=0.0, Do::Float64=0.0, t::Float64=0.0, MA::Float64=0.0, Yb31::Float64=0.0)
    Ocm = (P/E)*((Do/(2*(t-MA)))-Yb31) # eq (2C.148)
    return Ocm
end

@doc """
    Pipingtlmin(P::Float64; Do::Float64=0.0, S::Float64=0.0, E::Float64=0.0, Yb31::Float64=0.0, tsl::Float64=0.0, MA::Float64=0.0)

2C.5 Piping Components and Boiler Tubes - equation (2C.149)\n
Longitudinal stress (Circumferential Joints)\n
Minimum required thickness based on the longitudinal membrane stress for a cylinder or cone, as applicable.e\n
Do # Outside Diameter\n
P # internal design pressure\n
S # allowable stress\n
E # weld joint efficiency or quality factor from the original construction code, if unknown use 0.7\n
MA # mechanical allowances (thread or groove depth); for threaded components, the nominal thread depth (dimension h of ASME B.1.20.1) shall apply\n
tsl # supplemental thickness for mechanical loads other than pressure that result in longitudinal stress; this thickness is usually obtained from the results of a weight case in a stress analysis of the piping system (see paragraph 2C.2.7)\n
Yb31 # coefficient from ASME B31 Piping codes used for determining the pipe wall thickness, the coefficient can be determined from the following table that is valid for tmin < Do / 6 Annex 2C\n
t = trd # thickness of the shell or pipe adjusted for mill tolerance, LOSS and FCA , or cylinder thickness at a conical transition for a junction reinforcement calculation adjusted for mill tolerance, LOSS and FCA , as applicable\n
""" ->
function Pipingtlmin(P::Float64; Do::Float64=0.0, S::Float64=0.0, E::Float64=0.0, Yb31::Float64=0.0, tsl::Float64=0.0, MA::Float64=0.0)
    tlmin =(P*Do)/(4*((S*E)+(P*Yb31)))+tsl+MA # (2C.149)
    return tlmin
end

@doc """
    PipingMAWPl(S::Float64; E::Float64=0.0, t::Float64=0.0, tsl::Float64=0.0, MA::Float64=0.0, Do::Float64=0.0, Yb31::Float64=0.0)

2C.5 Piping Components and Boiler Tubes - equation (2C.150)\n
Longitudinal stress (Circumferential Joints)\n
Maximum allowable working pressure based on circumferential stress\n
Do # Outside Diameter\n
S # allowable stress\n
E # weld joint efficiency or quality factor from the original construction code, if unknown use 0.7\n
MA # mechanical allowances (thread or groove depth); for threaded components, the nominal thread depth (dimension h of ASME B.1.20.1) shall apply\n
tsl # supplemental thickness for mechanical loads other than pressure that result in longitudinal stress; this thickness is usually obtained from the results of a weight case in a stress analysis of the piping system (see paragraph 2C.2.7)\n
Yb31 # coefficient from ASME B31 Piping codes used for determining the pipe wall thickness, the coefficient can be determined from the following table that is valid for tmin < Do / 6 Annex 2C\n
t = trd # thickness of the shell or pipe adjusted for mill tolerance, LOSS and FCA , or cylinder thickness at a conical transition for a junction reinforcement calculation adjusted for mill tolerance, LOSS and FCA , as applicable\n
""" ->
function PipingMAWPl(S::Float64; E::Float64=0.0, t::Float64=0.0, tsl::Float64=0.0, MA::Float64=0.0, Do::Float64=0.0, Yb31::Float64=0.0)
    MAWPl = (4*S*E*(t-tsl-MA))/(Do-(4*Yb31*(t-tsl-MA))) # eq (2C.150)
    return MAWPl
end

@doc """
    PipingOlm(P::Float64; E::Float64=0.0, Do::Float64=0.0, t::Float64=0.0, tsl::Float64=0.0, MA::Float64=0.0, Yb31::Float64=0.0)

2C.5 Piping Components and Boiler Tubes - equation (2C.151)\n
Longitudinal stress (Circumferential Joints)\n
Nominal circumferential membrane stress for a cylinder or cone, as applicable\n
Do # Outside Diameter\n
P # internal design pressure\n
S # allowable stress\n
E # weld joint efficiency or quality factor from the original construction code, if unknown use 0.7\n
MA # mechanical allowances (thread or groove depth); for threaded components, the nominal thread depth (dimension h of ASME B.1.20.1) shall apply\n
Yb31 # coefficient from ASME B31 Piping codes used for determining the pipe wall thickness, the coefficient can be determined from the following table that is valid for tmin < Do / 6 Annex 2C\n
t = trd # thickness of the shell or pipe adjusted for mill tolerance, LOSS and FCA , or cylinder thickness at a conical transition for a junction reinforcement calculation adjusted for mill tolerance, LOSS and FCA , as applicable\n

""" ->
function PipingOlm(P::Float64; E::Float64=0.0, Do::Float64=0.0, t::Float64=0.0, tsl::Float64=0.0, MA::Float64=0.0, Yb31::Float64=0.0)
    Olm = (P/E)*((Do/(4*(t-tsl-MA)))-Yb31) # eq (2C.151)
    return Olm
end

# ASME B31.8 P
@doc """
    B31_8Piping_P(S::Float64; F::Float64=0.0, E::Float64=0.0, T::Float64=0.0, Do::Float64=0.0, t::Float64=0.0)

    ASME B31.8\n
    841.1 Steel Piping Systems Design Requirements\n
    ð18Þ 841.1.1 Steel Pipe Design Formula\n
Do # nominal outside diameter of pipe\n
S # specified minimum yield strength\n
F # design factor obtained from Table 841.1.6-1. In setting the values of the design factor, F, due consideration has been given and allowance has been made for the various underthickness \ntolerances provided for in the pipe specifications listed and approved for usage in this Code (B31.8)\n
E # longitudinal joint factor obtained from Table 841.1.7-1 [see also para. 817.1.3(d)]\n
T # temperature derating factor obtained from Table 841.1.8-1 (B31.8)\n
t = nominal wall thickness\n
P = design pressure\n
""" ->
function B31_8Piping_P(S::Float64; F::Float64=0.0, E::Float64=0.0, T::Float64=0.0, Do::Float64=0.0, t::Float64=0.0)
    P = (2*S*t / Do) * F * E * T # eq (2C.147)
    return P
end




# 2C.5.4 Required Thickness and MAWP – Boiler Tubes
# 2C.5.5 Required Thickness and MAWP – Pipe Bends Subject To Internal Pressure
# 2C.5.6 Required Thickness and MAWP for External Pressure
# 2C.5.7 Branch Connections

#2C.6 API 650 Storage Tanks
# 2C.6.3 Required Thickness and MFH for Liquid Hydrostatic Loading
#
