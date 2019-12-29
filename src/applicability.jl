# Fitness for service applicability

# Application Construction Codes
@doc """
    DesignCodeCriteria(x::String)::Int64

Check code meets API 579 construction codes

Choose from: ASME B&PV Code, Section VIII, Division 1,ASME B&PV Code, Section VIII, Division 2,ASME B&PV Code, Section I,ASME B31.1 Piping Code,ASME B31.3 Piping Code,ASME B31.4 Piping Code,
"ASME B31.8 Piping Code,ASME B31.12 Piping Code,API Std 650,API Std 620,API Std 530,Other Recognized Codes and Standards
""" ->
function DesignCodeCriteria(x::String)::Int64
    # reference data
    let codes = ["ASME B&PV Code, Section VIII, Division 1","ASME B&PV Code, Section VIII, Division 2","ASME B&PV Code, Section I","ASME B31.1 Piping Code","ASME B31.3 Piping Code","ASME B31.4 Piping Code",
    "ASME B31.8 Piping Code","ASME B31.12 Piping Code","API Std 650","API Std 620","API Std 530","Other Recognized Codes and Standards"]
    if any(x .== codes[1:length(codes)-1]) == 1
        print("Condition Satisfied - Code = ",x,"\n")
        design_code_criteria = 1
    elseif any(x .== codes) == 0
        print("Condition Not Satisfied\n")
        print("Check spelling else code not applicable, see API 579 2016 1.2 Scope sections 1.2.2 & 1.2.3\n")
        design_code_criteria = 0
    elseif (x == "Other Recognized Codes and Standards")
        print("For Other Recognized Codes and Standards - See conditions stated in API 579 2016 1.2 Scope sections 1.2.2 & 1.2.3.\n")
        design_code_criteria = 0
        end
    return design_code_criteria
end # let end
end

# Sufficient Material Toughness
@doc """
    MaterialToughness(x::String)::Int64

The material is considered to have sufficient material toughness.

x = "Certain" or "Uncertain"
""" ->
function MaterialToughness(x::String)::Int64
    @assert any(x .== ["Certain", "Uncertain"]) == 1 "Must be 'Certain' or 'Uncertain'"
    if (x == "Certain") == 1
        material_toughness = 1
        print("Material Toughness Condition Satisfied\n")
    elseif (x == "Uncertain") == 1
        material_toughness = 0
        print("Material Toughness Condition Not Satisfied\nConsult API 579 2016 Part 3\n")
        print("If the component is subject to embrittlement during operation due to temperature and/or the process environment, a Part 3, Level 3 assessment should be performed.")
    end
    return material_toughness
end

# Cylic Service
@doc """
    CyclicService(cycles::Int64)::Int64

The component is not in cyclic service.
""" ->
function CyclicService(cycles::Int64, y::String)::Int64
    @assert any(y .== ["Meets Part 14", "Does not meet Part 14"]) == 1 "Must be 'Meets Part 14' or 'Does not meet Part 14'"
    if (cycles < 150 && y == "Meets Part 14")
        cyclic_service = 1
        print("Cyclic Service Condition Satisfied\n")
    elseif (cycles >= 150 || y != "Meets Part 14")
        cyclic_service = 0
        print("Cyclic Service Condition Not Satisfied\n")
        end
    return cyclic_service
end

# Limitations on component types and applied loads
@doc """
    Part5ComponentType(component::String, vessel_orientation::String, material::String, D::Float64,Lss::Float64,H::Float64, NPS::Int64, design_temperature::Float64, units::String)::Array{Int64}

5.2.5 Applicability of the Level 1 and Level 2 Assessment Procedures\n
Level 1 Assessment – Type A Components - Subject to Internal Pressure\n
Level 2 Assessment – Type A and Type B, Class 1 components subject to internal pressure, external pressure, and supplemental loads\n
Level 3 Assessment - Performed when the Level 1 and Level 2 Assessment procedures do not apply\n

Figure 4.3 – Criteria for a Horizontal Pressure Vessel or Heat Exchanger to be Categorized as Type A Components\n
Lss = length between saddle supports for horizontal pressure vessels and heat exchangers\n
D = Outside Diameter :: If the horizontal vessel or heat exchanger contains conical transitions, the diameter D shall be based on the minimum inside diameter.\n

Figure 4.4 – Criteria for a Vertical Pressure Vessel to be Categorized as Type A Components\n
H = Vessel Height - bottom of skirt to top of the head\n
D = Outside Diameter :: If the horizontal vessel or heat exchanger contains conical transitions, the diameter D shall be based on the minimum inside diameter.\n

Figure 4.5 – Temperature Criteria for Piping Categorized as a Type A Component\n
Nominal pipe size and design temperatrues to qualify for Type A component - note this is only true for piping with no structural attachments\n

component = any of ["Cylindrical Vessel","Conical Shell Section","Spherical Vessel","Storage Sphere","Spherical Formed Head","Elliptical Formed Head","Torispherical Formed Head","Straight Section of Piping, Eblow or Bend - No Structural Attachments","Straight Section of Piping, Eblow or Bend - With Structural Attachments",
"Cylindrical Atmosperic Storage Tank Shell Courses","Pressure Vessel Nozzles","Tank Nozzles","Piping Branch Connections","Reinforcement Zone of Conical Sections","Flanges","Cylinder to Flat Head Junction","Integral Tubesheet Connections",
"Pressure Vessel Head to Shell Junction","Stiffening Rings Attached to Shell","Pressure Vessel Skirt and Lug Type Supports","Tank Shell Bottom Course","Tank Bottom Junction"]\n

vessel_orientation = "horizontal" or "vertical" or piping " "\n
material = "Carbon and Low Alloy Steels" or "High Alloy and Nonferrous Steels"\n
D = Vessel Outside Diameter\n
Lss = length between saddle supports for horizontal pressure vessels and heat exchangers\n
H = Vessel Height\n
NPS = Nominal pipe size\n
design_temperature = in F or C\n
units = "lbs-in-psi" or "nmm-mm-mpa"\n

""" ->
function Part5ComponentType(component::String; vessel_orientation::String, material::String, D::Float64,Lss::Float64,H::Float64, NPS::Float64, design_temperature::Float64, units::String)::Array{Int64}
    # input data
    # NPS groups
    print("Begin -- Component Type and Level 1,2,3 assessment applicability\n")
    let cs_nps_pipe_range_group_1 = [0.0,1/8,1/4,3/8,1/2,3/4,1,1.25,2,2.5,3,3.5,4],
    cs_nps_pipe_range_group_2 = [5,6,8],
    cs_nps_pipe_range_group_3 = [10,12,14,16],
    cs_nps_pipe_range_group_4 = [18,20,22,24],
    alloy_nps_pipe_range_group_1 = [1/8,1/4,3/8,1/2,3/4,1,1.25,2,2.5,3,3.5,4],
    alloy_nps_pipe_range_group_2 = [5,6,8,10],
    alloy_nps_pipe_range_group_3 = [12,14,16,18,20,22,24],
    # List of components
    components = ["Cylindrical Vessel","Conical Shell Section","Spherical Vessel","Storage Sphere","Spherical Formed Head","Elliptical Formed Head","Torispherical Formed Head","Straight Section of Piping, Eblow or Bend - No Structural Attachments","Straight Section of Piping, Eblow or Bend - With Structural Attachments",
    "Cylindrical Atmosperic Storage Tank Shell Courses","Pressure Vessel Nozzles","Tank Nozzles","Piping Branch Connections","Reinforcement Zone of Conical Sections","Flanges","Cylinder to Flat Head Junction","Integral Tubesheet Connections",
    "Pressure Vessel Head to Shell Junction","Stiffening Rings Attached to Shell","Pressure Vessel Skirt and Lug Type Supports","Tank Shell Bottom Course","Tank Bottom Junction"]
    #-- begin component type categorization and level 1,2,3 assessment applicability
    if (units == "nmm-mm-mpa")
    @assert any(NPS .== round.(cs_nps_pipe_range_group_1 .* 25.4,digits=2)) || any(NPS .== round.(cs_nps_pipe_range_group_2 .* 25.4,digits=2)) || any(NPS .== round.(cs_nps_pipe_range_group_3 .* 25.4,digits=2)) || any(NPS .== round.(cs_nps_pipe_range_group_4 .* 25.4,digits=2)) "Enter a Nominal Pipe Size Consult NPS table"
    elseif (units == "lbs-in-psi")
    @assert any(NPS .== cs_nps_pipe_range_group_1) || any(NPS .== cs_nps_pipe_range_group_2) || any(NPS .== cs_nps_pipe_range_group_3) || any(NPS .== cs_nps_pipe_range_group_4) "Enter a Nominal Pipe Size Consult NPS table"
    end
    @assert any(material .== ["Carbon and Low Alloy Steels","High Alloy and Nonferrous Steels"]) "Invalid input must be: 'Carbon and Low Alloy Steels' or 'High Alloy and Nonferrous Steels'"
    @assert any(component .== components) "Please select a valid component - See documentaion assoicated with this function"
    @assert any(vessel_orientation .== ["horizontal","vertical",""]) "Invalid input must be 'horizontal' or 'vertical' or if piping " " "
    @assert any(units .== ["lbs-in-psi", "nmm-mm-mpa"]) "Invalid input must be 'lbs-in-psi' or 'nmm-mm-mpa' "
    # Begin vessel, sphers, tank and formed head Type A determination
    if any(component .== ["Cylindrical Vessel","Conical Shell Section"]) # dimensional check per Figure 4.3 and Figure 4.4.
    if (vessel_orientation == "horizontal")
    if (units == "nmm-mm-mpa")
    D_convert = (3.05 * 1000) # convert meters to mm
    elseif (units == "lbs-in-psi")
    D_convert = (10*12) # convert feet to inches
end # end units
    if (Lss/D <= 2.5 && D <= D_convert)
        component_type = "Horizontal Vessel qualifies as Type A\n"
        print(component_type)
        level_1_satisfied = 1
        level_2_satisfied = 1
        level_3_satisfied = 1
    else
        level_1_satisfied = 0
        level_2_satisfied = 1
        level_3_satisfied = 1
        print("Horizontal Vessel qualifies as a Type B, Class 1 component\n")
    end # end calculation
elseif (vessel_orientation == "vertical")
    if (units == "nmm-mm-mpa")
    H_convert = (30.5 * 1000) # convert meters to mm
    elseif (units == "lbs-in-psi")
    H_convert = (100*12) # convert feet to inches
end  # end units
    if (H/D <= 3 && H <= H_convert)
        component_type = "Vertical Vessel qualifies as Type A\n"
        print(component_type)
        level_1_satisfied = 1
        level_2_satisfied = 1
        level_3_satisfied = 1
    else
        print("Vertical Vessel qualifies as a Type B, Class 1 component\n")
        level_1_satisfied = 0
        level_2_satisfied = 1
        level_3_satisfied = 1
    end # end calculation
end # end horizontal and vessel Type A component type determination
end # dimensional check for pressure vessel cylindrical and conical shell sections
if any(component .== ["Spherical Vessel","Storage Sphere"])
    print(component," qualifies as a Type A Component\n")
    level_1_satisfied = 1
    level_2_satisfied = 1
    level_3_satisfied = 1
end # end spherical vessel and storage sphere component type determination
if any(component .== ["Spherical Formed Head","Elliptical Formed Head","Torispherical Formed Head"])
    print(component," qualifies as a Type A Component\n")
    level_1_satisfied = 1
    level_2_satisfied = 1
    level_3_satisfied = 1
end # end spherical, elliptical and torispherical formed heads Type A component type determination
if (component == "Cylindrical Atmosperic Storage Tank Shell Courses")
    print(component," qualify as a Type A Component\n")
    level_1_satisfied = 1
    level_2_satisfied = 1
    level_3_satisfied = 1
end # end cylindrical atmospheric storage tank shell courses. Type A component type determination
#--- begin piping determination for Type A
# NPS piping groups
if (component == "Straight Section of Piping, Eblow or Bend - No Structural Attachments")
if (material == "Carbon and Low Alloy Steels")
    if (units == "nmm-mm-mpa")
        cs_nps_pipe_range_group_1 = round.(cs_nps_pipe_range_group_1 .* 25.4,digits=2)
        cs_nps_pipe_range_group_2 = round.(cs_nps_pipe_range_group_2 .* 25.4,digits=2)
        cs_nps_pipe_range_group_3 = round.(cs_nps_pipe_range_group_3 .* 25.4,digits=2)
        cs_nps_pipe_range_group_4 = round.(cs_nps_pipe_range_group_4 .* 25.4,digits=2)
    end
    if any(NPS .== cs_nps_pipe_range_group_1)
        temperature_limit = [-50.0,400.0]
        if (units == "nmm-mm-mpa")
            temperature_limit = round.((temperature_limit .- 32) * 5/9,digits=2)
        elseif (units == "lbs-in-psi")
            temperature_limit = temperature_limit
        end
        if (design_temperature >= temperature_limit[1] && design_temperature <= temperature_limit[2])
            component_type = "Piping Component is a Type A component"
            if (units == "lbs-in-psi")
            print("Carbon and Low Alloy Steels\n")
            print("NPS Group = 0 to 4 inches\n")
            print(design_temperature,"F falls between the limit range of ",temperature_limit,"F\n")
        else
            print("Carbon and Low Alloy Steels\n")
            print("NPS Group = 0 to 100mm\n")
            print(design_temperature,"C falls between the limit range of ",temperature_limit,"C\n")
        end
            print(component_type)
            level_1_satisfied = 1
            level_2_satisfied = 1
            level_3_satisfied = 1
        else
            component_type = "Piping Component is Type B, Class 1"
            if (units == "lbs-in-psi")
            print("Carbon and Low Alloy Steels\n")
            print("NPS Group = 0 to 4 inches\n")
            print(design_temperature,"F falls outside of the limit range ",temperature_limit,"F\n")
        else
            print("Carbon and Low Alloy Steels\n")
            print("NPS Group = 0 to 100mm\n")
            print(design_temperature,"C falls outside of the limit range ",temperature_limit,"C\n")
        end
            print(component_type)
            level_1_satisfied = 0
            level_2_satisfied = 1
            level_3_satisfied = 1
        end # end temperature crtieria for NPS group 1
    elseif any(NPS .== cs_nps_pipe_range_group_2)
        temperature_limit = [-50.0,300.0]
        if (units == "nmm-mm-mpa")
            temperature_limit = round.((temperature_limit .- 32) * 5/9,digits=2)
        elseif (units == "lbs-in-psi")
            temperature_limit = temperature_limit
        end
        if (design_temperature >= temperature_limit[1] && design_temperature <= temperature_limit[2])
            component_type = "Piping Component is a Type A component"
            if (units == "lbs-in-psi")
            print("Carbon and Low Alloy Steels\n")
            print("NPS Group = >4 to 8 inches\n")
            print(design_temperature,"F falls between the limit range of ",temperature_limit,"F\n")
        else
            print("Carbon and Low Alloy Steels\n")
            print("NPS Group = > 100 to 200mm\n")
            print(design_temperature,"C falls between the limit range of ",temperature_limit,"C\n")
        end
            print(component_type)
            level_1_satisfied = 1
            level_2_satisfied = 1
            level_3_satisfied = 1
        else
            component_type = "Piping Component is Type B, Class 1"
            if (units == "lbs-in-psi")
            print("Carbon and Low Alloy Steels\n")
            print("NPS Group = >4 to 8 inches\n")
            print(design_temperature,"F falls outside of the limit range ",temperature_limit,"F\n")
        else
            print("Carbon and Low Alloy Steels\n")
            print("NPS Group = > 100 to 200mm\n")
            print(design_temperature,"C falls outside of the limit range ",temperature_limit,"C\n")
        end
            print(component_type)
            level_1_satisfied = 0
            level_2_satisfied = 1
            level_3_satisfied = 1
        end # end temperature crtieria for group 2
    elseif any(NPS .== cs_nps_pipe_range_group_3)
        temperature_limit = [-50.0,200.0]
        if (units == "nmm-mm-mpa")
            temperature_limit = round.((temperature_limit .- 32) * 5/9,digits=2)
        elseif (units == "lbs-in-psi")
            temperature_limit = temperature_limit
        end
        if (design_temperature >= temperature_limit[1] && design_temperature <= temperature_limit[2])
            component_type = "Piping Component is a Type A component"
            if (units == "lbs-in-psi")
            print("Carbon and Low Alloy Steels\n")
            print("NPS Group = >8 to 16 inches\n")
            print(design_temperature,"F falls between the limit range of ",temperature_limit,"F\n")
        else
            print("Carbon and Low Alloy Steels\n")
            print("NPS Group = > 200 to 400mm\n")
            print(design_temperature,"C falls between the limit range of ",temperature_limit,"C\n")
        end
            print(component_type)
            level_1_satisfied = 1
            level_2_satisfied = 1
            level_3_satisfied = 1
        else
            component_type = "Piping Component is Type B, Class 1"
            if (units == "lbs-in-psi")
            print("Carbon and Low Alloy Steels\n")
            print("NPS Group = >8 to 16 inches\n")
            print(design_temperature,"F falls outside of the limit range ",temperature_limit,"F\n")
        else
            print("Carbon and Low Alloy Steels\n")
            print("NPS Group = > 200 to 400mm\n")
            print(design_temperature,"C falls outside of the limit range ",temperature_limit,"C\n")
        end
            level_1_satisfied = 0
            level_2_satisfied = 1
            level_3_satisfied = 1
            print(component_type)
        end # end temperature crtieria for group 3
    elseif any(NPS .== cs_nps_pipe_range_group_4)
        temperature_limit = 0.0
        if (units == "nmm-mm-mpa")
            temperature_limit = round.((temperature_limit .- 32) * 5/9,digits=2)
        elseif (units == "lbs-in-psi")
            temperature_limit = temperature_limit
        end
        if (temperature_limit == 0.0 || temperature_limit == -17.78) # F and C
            if (units == "lbs-in-psi")
            print("Carbon and Low Alloy Steels\n")
            print("NPS Group = >16 to 24 inches\n")
            print(design_temperature,"F falls outside of the limit range ",temperature_limit,"F\n")
        else
            print("Carbon and Low Alloy Steels\n")
            print("NPS Group = > 400 to 600mm\n")
            print(design_temperature,"C falls outside of the limit range ",temperature_limit,"C\n")
        end
        level_1_satisfied = 0
        level_2_satisfied = 1
        level_3_satisfied = 1
            print("Piping Component is Type B, Class 1")
        end # end temperature crtieria
    end
elseif (material == "High Alloy and Nonferrous Steels")
    if (units == "nmm-mm-mpa")
        alloy_nps_pipe_range_group_1 = round.(alloy_nps_pipe_range_group_1 .* 25.4,digits=2)
        alloy_nps_pipe_range_group_2 = round.(alloy_nps_pipe_range_group_2 .* 25.4,digits=2)
        alloy_nps_pipe_range_group_3 = round.(alloy_nps_pipe_range_group_3 .* 25.4,digits=2)
    end
    if any(NPS .== alloy_nps_pipe_range_group_1)
        temperature_limit = [-150.0,200.0]
        if (units == "nmm-mm-mpa")
            temperature_limit = round.((temperature_limit .- 32) * 5/9,digits=2)
        elseif (units == "lbs-in-psi")
            temperature_limit = temperature_limit
        end
        if (design_temperature >= temperature_limit[1] && design_temperature <= temperature_limit[2])
            component_type = "Piping Component is a Type A component"
            if (units == "lbs-in-psi")
            print("High Alloy and Nonferrous Steels\n")
            print("NPS Group = 0 to 4 inches\n")
            print(design_temperature,"F falls between the limit range of ",temperature_limit,"F\n")
        else
            print("High Alloy and Nonferrous Steels\n")
            print("NPS Group = 0 to 100mm\n")
            print(design_temperature,"C falls between the limit range of ",temperature_limit,"C\n")
        end
            level_1_satisfied = 1
            level_2_satisfied = 1
            level_3_satisfied = 1
            print(component_type)
        else
            component_type = "Piping Component is Type B, Class 1"
            if (units == "lbs-in-psi")
            print("High Alloy and Nonferrous Steels\n")
            print("NPS Group = 0 to 4 inches\n")
            print(design_temperature,"F falls outside of the limit range ",temperature_limit,"F\n")
        else
            print("High Alloy and Nonferrous Steels\n")
            print("NPS Group = 0 to 100mm\n")
            print(design_temperature,"C falls outside of the limit range ",temperature_limit,"C\n")
        end
            level_1_satisfied = 0
            level_2_satisfied = 1
            level_3_satisfied = 1
            print(component_type)
        end # end temperature crtieria for NPS group 1
    elseif any(NPS .== alloy_nps_pipe_range_group_2)
        temperature_limit = [-50.0,200.0]
        if (units == "nmm-mm-mpa")
            temperature_limit = round.((temperature_limit .- 32) * 5/9,digits=2)
        elseif (units == "lbs-in-psi")
            temperature_limit = temperature_limit
        end
        if (design_temperature >= temperature_limit[1] && design_temperature <= temperature_limit[2])
            component_type = "Piping Component is a Type A component"
            if (units == "lbs-in-psi")
            print("High Alloy and Nonferrous Steels\n")
            print("NPS Group = >4 to 10 inches\n")
            print(design_temperature,"F falls between the limit range of ",temperature_limit,"F\n")
        else
            print("High Alloy and Nonferrous Steels\n")
            print("NPS Group = > 100 to 250mm\n")
            print(design_temperature,"C falls between the limit range of ",temperature_limit,"C\n")
        end
            level_1_satisfied = 1
            level_2_satisfied = 1
            level_3_satisfied = 1
            print(component_type)
        else
            component_type = "Piping Component is Type B, Class 1"
            if (units == "lbs-in-psi")
            print("High Alloy and Nonferrous Steels\n")
            print("NPS Group = >4 to 10 inches\n")
            print(design_temperature,"F falls outside of the limit range ",temperature_limit,"F\n")
        else
            print("High Alloy and Nonferrous Steels\n")
            print("NPS Group = > 100 to 250mm\n")
            print(design_temperature,"C falls outside of the limit range ",temperature_limit,"C\n")
        end
            level_1_satisfied = 0
            level_2_satisfied = 1
            level_3_satisfied = 1
            print(component_type)
        end # end temperature crtieria for group 2
    elseif any(NPS .== alloy_nps_pipe_range_group_3)
        temperature_limit = 0.0
        if (units == "nmm-mm-mpa")
            temperature_limit = round.((temperature_limit .- 32) * 5/9,digits=2)
        elseif (units == "lbs-in-psi")
            temperature_limit = temperature_limit
        end
        if (temperature_limit == 0.0 || temperature_limit == -17.78) # F and C
            if (units == "lbs-in-psi")
            print("High Alloy and Nonferrous Steels\n")
            print("NPS Group = >10 to 24 inches\n")
            print(design_temperature,"F falls outside of the limit range ",temperature_limit,"F\n")
        else
            print("High Alloy and Nonferrous Steels\n")
            print("NPS Group = > 250 to 600mm\n")
            print(design_temperature,"C falls outside of the limit range ",temperature_limit,"C\n")
        end
            level_1_satisfied = 0
            level_2_satisfied = 1
            level_3_satisfied = 1
            print("Piping Component is Type B, Class 1")
        end # end temperature crtieria
    end
end # end NPS piping Type A Component determination
elseif (component == "Straight Section of Piping, Eblow or Bend - With Structural Attachments")
    print("Piping Component qualifies as a Type B, Class 1 component\n")
    level_1_satisfied = 0
    level_2_satisfied = 1
    level_3_satisfied = 1
end # end piping with or without attachments

#-- start Type B, Class 1 component determination
# Pressure vessel cylindrical and conical shell sections statisfied in Type A else statement above
# Piping not considered type A is determined to be Type B, Class 1 this is relfected with Type A else statement above
#-- end Type B, Class 1 component determination

#-- start Type B, Class 2 component determination
if any(component .== ["Pressure Vessel Nozzles","Tank Nozzles","Piping Branch Connections","Reinforcement Zone of Conical Sections","Flanges","Cylinder to Flat Head Junction","Integral Tubesheet Connections"])
    print(component," qualifies as a Type B, Class 2 Component\n")
    level_1_satisfied = 0
    level_2_satisfied = 0
    level_3_satisfied = 1
end # end pressure vessel nozzles, tank nozzles and piping branch connections, einforcement zone of conical transitions, flanges, cylinder to flat head junctions, integral tubesheet connections
#-- end Type B, Class 2 component determination

#-- start Type C component determination
if any(component .== ["Pressure Vessel Head to Shell Junction","Stiffening Rings Attached to Shell","Pressure Vessel Skirt and Lug Type Supports","Tank Shell Bottom Course","Tank Bottom Junction"])
    print(component," qualifies as a Type C Component\n")
    level_1_satisfied = 0
    level_2_satisfied = 0
    level_3_satisfied = 1
end # end pressure vessel nozzles, tank nozzles and piping branch connections, einforcement zone of conical transitions, flanges, cylinder to flat head junctions, integral tubesheet connections
#-- end Type C component determination
return assessment_applicability = [level_1_satisfied,level_2_satisfied,level_3_satisfied]
end # let end
end # function end
#-- end component type categorization and level 1,2,3 assessment applicability

# Applicability of level 1,2 and 3 assessment
@doc """
    Part5AsessmentApplicability(x::Array{Int64}; design::Int64, toughness::Int64, cylic::Int64)::Array{Int64}

Insure API 579 5.2.5 are satisfied in order to conduct a level 1 and/or level 2 assessment
""" ->
function Part5AsessmentApplicability(x::Array{Int64}, design::Int64, toughness::Int64, cylic::Int64)::Array{Int64}
    # level 1
    if (sum([x[1],design,toughness,cylic]) == 4)
        print("The criteria for level 1 assessment application has been satisfied\n")
        level_1_satisfied = 1
    elseif (sum([x[1],design,toughness,cylic]) != 4)
        if (x[1] == 0)
            print("(level 1) Component Type Not Satisfied\n")
            level_1_satisfied = 0
        elseif (design == 0)
            print("(level 1) Design Code Not Satisfied\n")
            level_1_satisfied = 0
        elseif (design == 0)
            print("(level 1) Material Toughness Not Satisfied\n")
            level_1_satisfied = 0
        elseif (design == 0)
            print("(level 1) Cyclic Service Not Satisfied\n")
            level_1_satisfied = 0
        end
    end # end level 1 applicability check
    # level 2
    if (sum([x[2],design,toughness,cylic]) == 4)
        print("The criteria for level 2 assessment application has been satisfied\n")
        level_2_satisfied = 1
    elseif (sum([x[2],design,toughness,cylic]) != 4)
        if (x[2] == 0)
            print("(level 2) Component Type Not Satisfied\n")
            level_2_satisfied = 0
        elseif (design == 0)
            print("(level 2) Design Code Not Satisfied\n")
            level_2_satisfied = 0
        elseif (design == 0)
            print("(level 2) Material Toughness Not Satisfied\n")
            level_2_satisfied = 0
        elseif (design == 0)
            print("(level 2) Cyclic Service Not Satisfied\n")
            level_2_satisfied = 0
        end
    end # end level 2 applicability check
    # level 3
    if (x[3] == 1)
        print("The criteria for level 3 assessment application has been satisfied\n")
        level_3_satisfied = 1
    end # end level 3 applicability check
    return assessment_applicability = [level_1_satisfied,level_2_satisfied,level_3_satisfied]
end
