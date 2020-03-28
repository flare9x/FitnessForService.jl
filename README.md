[![Build Status](https://travis-ci.org/flare9x/FitnessForService.jl.svg?branch=master)](https://travis-ci.org/flare9x/FitnessForService.jl)

# FitnessForService.jl
 API 579 Fitness For Service Methodologies

## Installation
```julia
    ]
 add https://github.com/flare9x/FitnessForService.jl
 ```
## Usage

## API 579 Part 5 – Assessment of Local Metal Loss - Level 1 & 2 Assessment

API 579 have specific conditions that must be met which determine the applicability of the level 1,2 or 3 assessment. Limitations of the assessments include:
*   The flaw is a LTA per API 579 or Groove-like-flaw
*   Assessment procedures may only be applied to components which are not operating in the creep range

Applicability of the level 1 and level 2 procedures
*   The original design criteria were in accordance with a recognized code or standard
*   The material is considered to have sufficient material toughness
*   The component is not in cyclic service
*   Level 1 Assessment – Type A Components Only
*   Level 2 Assessment – Type A and Type B, Class 1 components subject to internal pressure, external pressure, and supplemental loads
*   Distance to structural discontinuity (Lmsd)

Applicability of the Level 3 Assessment Procedures
*   Level 3 Assessment – Performed when the Level 1 and Level 2 Assessment procedures do not apply

The functions that check the applicability of the assessment procedure:

```julia
creep_range = CreepRangeTemperature("Carbon Steel (UTS ≤ 414MPa (60 ksi))"; design_temperature=100.0, units="lbs-in-psi")
design = DesignCodeCriteria("ASME B31.3 Piping Code")
toughness = MaterialToughness("Certain")
cyclic = CyclicService(100, "Meets Part 14")
x = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="horizontal", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=3.0, design_temperature=100.0, units="lbs-in-psi")
part5_applicability = Part5AsessmentApplicability(x,design,toughness,cyclic,creep_range)
 ```

Each component falls into a different Type and class category. Type A components have a design equation that specifically relates pressure (or liquid fill height for tanks) and supplemental loads, as applicable, to a required wall thickness, and the supplemental loads in combination with pressure do not govern the required wall thickness, i.e. the required thickness is based on pressure only.

Type A components are limited to Level 1, 2 and 3 assessments.

Type B, Class 1 components have the same geometry and loading conditions as described in Type A above but are not classified as Type A components because supplemental loads in combination with pressure may govern the required wall thickness.

Type B, Class 1 components are limited to Level 2 and 3 assessments.

Type B, Class 2 components do not have a design equation that specifically relates pressure (or liquid fill height for tanks) and/or other loads, as applicable, to a required wall thickness. These components have a code design procedure to determine an acceptable configuration. Type B, Class 2 components typically exist at a major structural discontinuity and involve the satisfaction of a local reinforcement requirement (e.g. nozzle reinforcement area), or necessitate the computation of a stress level based upon a given load condition, geometry, and thickness configuration (e.g. flange design). These rules typically result in one component with a thickness that is dependent upon that of another component. Design rules of this type have thickness interdependency, and the definition of a minimum thickness for a component is ambiguous.

Type B, Class 2 components are limited to Level 3 assessments.

Type C Components – A component that does not have a design equation which specifically relates pressure (or liquid fill height for tanks) and/or other loads, as applicable, to a required wall thickness. In addition, these components do not have a code design procedure to determine local stresses.

Type C components are limited to Level 3 assessments.

An example output of the Type and level 1,2,3 assessment applicability for carbon steel Straight Section of Piping, Elbow or Bend - No Structural Attachments, NPS 3 with design temperature 100F:

```julia
Design Temperature 100.0 F is below or equal to the creep temperature limit 650F for material Carbon Steel (UTS ≤ 414MPa (60 ksi)) - Criteria satisfied
Condition Satisfied - Code = ASME B31.3 Piping Code
Material Toughness Condition Satisfied
Cyclic Service Condition Satisfied
Begin -- Component Type and Level 1,2,3 assessment applicability
Carbon and Low Alloy Steels
NPS Group = 0 to 4 inches
100.0F falls between the limit range of [-50.0, 400.0]F
Piping Component is a Type A component
The criteria for level 1 assessment application has been satisfied
The criteria for level 2 assessment application has been satisfied
The criteria for level 3 assessment application has been satisfied
 ```
An example output of the Type and level 1,2,3 assessment applicability for component type: Flanges:

 ```julia
Design Temperature 100.0 F is below or equal to the creep temperature limit 650F for material Carbon Steel (UTS ≤ 414MPa (60 ksi)) - Criteria satisfied
Condition Satisfied - Code = ASME B&PV Code, Section VIII, Division 1
Material Toughness Condition Satisfied
Cyclic Service Condition Satisfied
Begin -- Component Type and Level 1,2,3 assessment applicability
Flanges qualifies as a Type B, Class 2 Component
(level 1) Component Type Not Satisfied
(level 2) Component Type Not Satisfied
The criteria for level 3 assessment application has been satisfied
  ```

Once the limitation and correct assessment applicability have been determined. Running the script part5_local_metal_loss_assessment.jl will apply the correct assessment to the applicable component type.

Each assessment is wrapped in a function. The Part 5 level 1 assessment function may be explored with @doc Part5LTALevel1.
The function consists of the relevant input variables that are needed to perform the assessment:

   ```julia
 @doc Part5LTALevel1
       Part5LTALevel1(annex2c_tmin_category::String; equipment_group::String="piping",flaw_location::String="external",metal_loss_categorization::String="LTA",units::String="lbs-in-psi",tnom::Float64=0.0,
  trd::Float64=0.0,FCA::Float64=0.0,FCAml::Float64=0.0,LOSS::Float64=0.0,Do::Float64=0.0,D::Float64=0.0,P::Float64=0.0,S::Float64=0.0,E::Float64=0.0,MA::Float64=0.0,Yb31::Float64=0.0,
  tsl::Float64=0.0,spacings::Float64=0.0,s::Float64=0.0,c::Float64=0.0,El::Float64=0.0,Ec::Float64=0.0, RSFa::Float64=0.9, gl::Float64=0.0, gw::Float64=0.0, gr::Float64=0.0, β::Float64=0.0)

  Variables
  
  equipment_group = "piping" # "vessel", "tank"
  
  annex2c_tmin_category = "Straight Pipes Subject To Internal Pressure" # ["Cylindrical Shell","Spherical Shell","Hemispherical Head","Elliptical
Head","Torispherical Head","Conical Shell","Toriconical Head","Conical Transition","Nozzles Connections in Shells",
  # "Junction Reinforcement Requirements at Conical Transitions","Tubesheets","Flat head to cylinder connections","Bolted Flanges","Straight Pipes Subject To Internal Pressure","Boiler Tubes","Pipe Bends Subject To Internal Pressure",
  # "MAWP for External Pressure","Branch Connections","API 650 Storage Tanks"]
  
  flaw_location = "external" # "External","Internal"
  
  metal_loss_categorization = "Groove-Like Flaw" # "LTA" or "Groove-Like Flaw"
  
  units = "lbs-in-psi" # "lbs-in-psi" or "nmm-mm-mpa"
  
  tnom = .3 # nominal or furnished thickness of the component adjusted for mill undertolerance as applicable.
  
  trd = .3 # uniform thickness away from the local metal loss location established by thickness measurements at the time of the assessment.
  
  FCAml = .00 # Future Corrosion Allowance applied to the region of metal loss.
  
  FCA = .00 # Future Corrosion Allowance applied to the region away from the metal loss (see Annex 2C, paragraph 2C.2.8).
  
  LOSS = 0.0 #the amount of uniform metal loss away from the local metal loss location at the time of the assessment.
  
  Do = 3.5 # Outside Diameter
  
  D = Do - 2*(tnom)  # inside diameter of the shell corrected for FCAml , as applicable
  
  P = 1480 # internal design pressure.
  
  S = 20000 # allowable stress.
  
  E = 1.0 # weld joint efficiency or quality factor from the original construction code, if unknown use 0.7.
  
  MA = 0.0 # mechanical allowances (thread or groove depth); for threaded components, the nominal thread depth (dimension h of ASME B.1.20.1) shall apply.
  
  Yb31 = 0.4 # coefficient from ASME B31 Piping codes used for determining the pipe wall thickness, the coefficient can be determined from the following table that is valid for tmin < Do / 6 Annex 2C .
  
  t = trd # thickness of the shell or pipe adjusted for mill tolerance, LOSS and FCA , or cylinder thickness at a conical transition for a junction reinforcement calculation adjusted for mill tolerance, LOSS and FCA , as applicable.
  
  tsl = 0.0 # supplemental thickness for mechanical loads other than pressure that result in longitudinal stress; this thickness is usually obtained from the results of a weight case in a stress analysis of the piping system (see paragraph 2C.2.7).
  
  spacings = 0.5 # spacings determine by visual inspection to adequately ccategorizse the corrosion
  
  # Flaw dimensions
  
  s = 5.5 # longitudinal extent or length of the region of local metal loss based on future corroded thickness,
  
  c = 1.5 # circumferential extent or length of the region of local metal loss (see Figure 5.2 and Figure 5.10), based on future corroded thickness, tc .
  
  Ec = 1.0 # circumferential weld joint efficiency. note if damage on weld see # 2C.2.5 Treatment of Weld and Riveted Joint Efficiency, and Ligament Efficiency
  
  El = 1.0 # longitudinal weld joint efficiency. note if damage on weld see # 2C.2.5 Treatment of Weld and Riveted Joint Efficiency, and Ligament
Efficiency
  
  RSFa = 0.9 # remaining strength factor - consult API 579 is go lower than 0.9
  
  # Groove Like Flaw dimensions
  
  gl = .05 # length of the Groove-Like Flaw based on future corroded condition.
  
  gw = .4 # width of the Groove-Like Flaw based on future corroded condition.
  
  gr = 0.1 # radius at the base of a Groove-Like Flaw based on future corroded condition.
  
  β = 40.0 # see (Figure 5.4) :: orientation of the groove-like flaw with respect to the longitudinal axis or a parameter to compute an effective
fracture toughness for a groove being evaluated as a crack-like flaw, as applicable.
 ```

The Part 5 Level 1 assessment output example:

   ```julia
Satisfied - Flaw is located far enough from structural discontinuity
Begin -- Level 1 Assessment - API 579 June 2016 Edition
eq 5.7 is Satisfied
eq 5.10 is Satisfied
eq 5.9 is Satisfied
The criteria for level 1 assessment has been satisfied - proceed to STEP 6
LTA - Proceed to STEP 7
Piping MAWPc = 3680.982psi
Piping MAWPl = 7947.02psi
Final MAWP = 3680.982psi
Region of metal loss is acceptable at MAWPr 1593.429psi
MAWPr is less than design pressure or equipment MAWP. The component is acceptable for continued operation at MAWPr
Part 5 level 1 - Satisfies June 2016 API 579-1/ASME FFS-1 Level 1 assessment
The assessment is complete for all component types
 ```
The level 2 assessment is a more specific method of assessing and characterizing the corroded profile. As stated in API 579 paragraph 5.4.3.1: 
 
"These procedures account for the local reinforcement effects of the varying wall thickness in the region of the local metal loss and ensure that the weakest ligament is identified and properly evaluated."

The API 579 methodology utilizes a numerical integration technique (Simpsons Rule or Trapezoidal Rule) to evalaute the the area of metal loss within the corroded profile. This julia code uses the Trapezoidal Rule being that the sub-intervals of the corroded profile are not in equal intervals (for simplicity vs simpsons rule). 

 The Part 5 Level 2 assessment output example:
 
   ```julia
Begin -- Level 2 Assessment - API 579 June 2016 Edition
eq 5.7 is Satisfied
eq 5.10 is Satisfied
eq 5.9 is Satisfied
The criteria for level 1 and 2 assessment has been satisfied - proceed to STEP 6
LTA - Proceed to STEP 7
Piping MAWPc = 3680.982psi
Piping MAWPl = 7947.02psi
Final MAWP = 3680.982psi
Region of metal loss is acceptable at MAWPr 3008.189psi
MAWPr is less than design pressure or equipment MAWP. The component is acceptable for continued operation at MAWPr
Part 5 level 2 - Satisfies June 2016 API 579-1/ASME FFS-1 Level 2 assessment
The component is a cylindrical shell, conical shell, or elbow
 Begin -- evaluate the circumferential extent
eq 5.13 satisfied - no further evaluation is required
 ```
 
 ## Sensitivty Analysis 
 
 Understanding input varibles and their relative sensitivty on the assessment output. 
 
 Example of iterating through a range of FCAml values and observing the effect on the MAWPr output:
 
 ![fcaml](https://github.com/flare9x/FitnessForService.jl/blob/master/images/FCAml_spectrum.PNG)
 
 The plot shows permissible FCAml allowances up to stated design pressure. 
 
 Considering confidence levels in the ability of inspection / NDE to find the maximum loss in a region of damage. 
 To account for variance in inspection / NDE in reporting the minimum thickness:
 
![minimum remaining wall thickness](https://github.com/flare9x/FitnessForService.jl/blob/master/images/remaining_WT_range_of_t_values.PNG)
  
eg: If the NDE technique used has known error of up to 10%. One may observe the spectrum of error up to stated design pressure. If within expected reason further confidence can be obtained moving forward with the observed results.

API 579 - LTA Corroded Profile:

![api 579 corroded profile](https://github.com/flare9x/FitnessForService.jl/blob/master/images/api_579_corrosion_profile.PNG)
  

## Unit Test Summary

Each fit for service assessment is tested to a correct known output and assessment functions are tested to established tables and plots in the API 579 June 2016 code:

Test Summary:          | Pass  Total<br/>
applicability.jl       |  100    100<br/>
part5_LTA_functions.jl |   11     11<br/>
