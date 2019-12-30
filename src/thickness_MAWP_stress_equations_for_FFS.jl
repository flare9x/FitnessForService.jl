# ANNEX 2C – THICKNESS, MAWP AND STRESS EQUATIONS FOR A FFS ASSESSMENT

@doc """
    Pipingtcmin(P::Float64; Do::Float64=0.0, S::Float64=0.0, E::Float64=0.0, Yb31::Float64=0.0, MA::Float64=0.0)

2C.5 Piping Components and Boiler Tubes - equation (2C.146\n
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

Pipingtcmin(P, Do=Do, S=S, E=E, Yb31=Yb31, MA=MA)


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
    Pipingtcmin(P::Float64; Do::Float64=0.0, S::Float64=0.0, E::Float64=0.0, Yb31::Float64=0.0, MA::Float64=0.0)

2C.5 Piping Components and Boiler Tubes - equation (2C.146\n
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

Pipingtcmin(P, Do=Do, S=S, E=E, Yb31=Yb31, MA=MA)


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

















MAWPc =(2*S*E*(t-MA))/(Do-(2*Yb31*(t-MA))) # eq (2C.147)
MAWPl =(4*S*E*(t-tsl-MA))/(Do-(4*Yb31*(t-tsl-MA))) # eq (2C.150)
MAWP = minimum([MAWPc,MAWPl])
