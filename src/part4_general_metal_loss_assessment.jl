# PART 4 – ASSESSMENT OF GENERAL LOCAL METAL LOSS

using Statistics

print("Begin -- Assessment Applicability and Component Type Checks\n")
creep_range = CreepRangeTemperature("Carbon Steel (UTS ≤ 414MPa (60 ksi))"; design_temperature=100.0, units="nmm-mm-mpa")
design = DesignCodeCriteria("ASME B31.3 Piping Code")
smoothness = Smoothness("Smooth Contour")
cyclic = CyclicService(100, "Meets Part 14")
x = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="horizontal", material="Carbon and Low Alloy Steels", D=24.75,Lss=120.0,H=0.0, NPS=3.0, design_temperature=100.0, units="lbs-in-psi")
part5_applicability = Part5AsessmentApplicability(x,design,smoothness,cyclic,creep_range)

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

# STEP 1 – Take the point thickness reading data in accordance with paragraph 4.3.3 Tam , and the
# Coefficient Of Variation (COV). A template for computing the COV is provided in Table 4.3.
# Tam = average measured wall thickness of the component based on the point thickness readings (PTR) measured at the time of the inspection.
# COV = Coefficient Of Variation.
# Trd = Thickness reading within corroded
x = [13.0,12.0,11.0,13.0,10.0,12.0,11.0,12.0,13.0,13.0,11.0,12.0,12.0,13.0,13.0]
step_1 = COV_var(x)

# STEP 2 – If the COV from STEP 1 is less than or equal to 0.1, then proceed to STEP 3 to complete the
# assessment using the average thickness, tam . If the COV is greater than 0.1 then the use of thickness
# profiles should be considered for the assessment (see paragraph 4.4.2.2).
if step_1[2] <= 0.1
    print("COV is <= 0.1 - Procced to Step 3 to complete the assessment using the average thickness Tam - COV = ", round(step_1[2],digits =2))
else
    print("COV is > 0.1 - Thickness Profiles should be conisdered for assessment :: (see paragraph 4.4.2.2) - COV = ", round(step_1[2],digits =2))
end

# STEP 3 – The acceptability of the component for continued operation can be established using the Level 1
# criteria in Table 4.4, Table 4.5, Table 4.6, and Table 4.7. The averaged measured thickness or
# MAWP acceptance criterion may be used. In either case, the minimum thickness criterion shall be
# satisfied. For MAWP acceptance criterion (see Part 2, paragraph 2.4.2.2.e) to determine the
# acceptability of the equipment for continued operation
