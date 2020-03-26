using FitnessForService

@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

##############################################################################################################
# Test each function and condition and ensure working correctly. Check units and categorizations correct etc..
# run full script against API 579 example code
##############################################################################################################

@testset "applicability.jl" begin
    @testset "Design Code Applicability" begin
        case_1 = DesignCodeCriteria("ASME B&PV Code, Section VIII, Division 1")
        case_2 = DesignCodeCriteria("ASME B&PV Code, Section VIII, Division 2")
        case_3 = DesignCodeCriteria("ASME B&PV Code, Section I")
        case_4 = DesignCodeCriteria("ASME B31.1 Piping Code")
        case_5 = DesignCodeCriteria("ASME B31.3 Piping Code")
        case_6 = DesignCodeCriteria("ASME B31.4 Piping Code")
        case_7 = DesignCodeCriteria("ASME B31.8 Piping Code")
        case_8 = DesignCodeCriteria("ASME B31.12 Piping Code")
        case_9 = DesignCodeCriteria("API Std 650")
        case_10 = DesignCodeCriteria("API Std 620")
        case_11 = DesignCodeCriteria("API Std 530")
        case_12 = DesignCodeCriteria("Other Recognized Codes and Standards")
        case_13 = DesignCodeCriteria("EMMUA")
        @test case_1 == 1
        @test case_2 == 1
        @test case_3 == 1
        @test case_4 == 1
        @test case_5 == 1
        @test case_6 == 1
        @test case_7 == 1
        @test case_8 == 1
        @test case_9 == 1
        @test case_10 == 1
        @test case_11 == 1
        @test case_12 == 0 # other code and standards refer to API 579
        @test case_13 == 0 # other code and standards refer to API 579
    end

    @testset "Material Toughness" begin
        case_1 = MaterialToughness("Certain")
        case_2 = MaterialToughness("Uncertain")
        @test case_1 == 1
        @test case_2 == 0
    end

    @testset "Cyclic Service" begin
        case_1 = CyclicService(100,"Meets Part 14") # check both meet
        case_2 = CyclicService(160,"Meets Part 14") # check only 1x meet
        case_3 = CyclicService(100,"Does not meet Part 14") # check only 1x meet
        case_4 = CyclicService(160,"Does not meet Part 14") # check both do not meet
        @test case_1 == 1
        @test case_2 == 0
        @test case_3 == 0
        @test case_4 == 0
    end

    @testset "Component Type and Level 1,2,3 Applicability" begin
        # piping tests with Carbon and Low Alloy Steels
        # inches
        case_1 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=1.0, design_temperature=150.0, units="lbs-in-psi")
        case_2 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=6.0, design_temperature=150.0, units="lbs-in-psi")
        case_3 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=10.0, design_temperature=150.0, units="lbs-in-psi")
        case_4 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=24.0, design_temperature=150.0, units="lbs-in-psi")
        case_5 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=1.0, design_temperature=500.0, units="lbs-in-psi")
        case_6 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=6.0, design_temperature=500.0, units="lbs-in-psi")
        case_7 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=10.0, design_temperature=500.0, units="lbs-in-psi")
        case_8 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=24.0, design_temperature=500.0, units="lbs-in-psi")
        case_9 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=1.0, design_temperature=-100.0, units="lbs-in-psi")
        case_10 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=6.0, design_temperature=-100.0, units="lbs-in-psi")
        case_11 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=10.0, design_temperature=-100.0, units="lbs-in-psi")
        case_12 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=24.0, design_temperature=-100.0, units="lbs-in-psi")
        case_13 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - With Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=1.0, design_temperature=150.0, units="lbs-in-psi")
        # piping tests with High Alloy and Nonferrous Steels
        case_14 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=1.0, design_temperature=150.0, units="lbs-in-psi")
        case_15 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=6.0, design_temperature=150.0, units="lbs-in-psi")
        case_16 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=10.0, design_temperature=150.0, units="lbs-in-psi")
        case_17 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=24.0, design_temperature=150.0, units="lbs-in-psi")
        case_18 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=1.0, design_temperature=500.0, units="lbs-in-psi")
        case_19 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=6.0, design_temperature=500.0, units="lbs-in-psi")
        case_20 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=12.0, design_temperature=500.0, units="lbs-in-psi")
        case_21 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=24.0, design_temperature=500.0, units="lbs-in-psi")
        case_22 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=1.0, design_temperature=-100.0, units="lbs-in-psi")
        case_23 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=6.0, design_temperature=-100.0, units="lbs-in-psi")
        case_24 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=10.0, design_temperature=-100.0, units="lbs-in-psi")
        case_25 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=24.0, design_temperature=-100.0, units="lbs-in-psi")
        case_26 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - With Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=1.0, design_temperature=150.0, units="lbs-in-psi")
        # piping tests with Carbon and Low Alloy Steels
        # nmm-mm-mpa
        case_27 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=25.4, design_temperature=65.5556, units="nmm-mm-mpa")
        case_28 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=152.4, design_temperature=65.5556, units="nmm-mm-mpa")
        case_29 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=254.0, design_temperature=65.5556, units="nmm-mm-mpa")
        case_30 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=609.6, design_temperature=65.5556, units="nmm-mm-mpa")
        case_31 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=25.4, design_temperature=260.0, units="nmm-mm-mpa")
        case_32 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=152.4, design_temperature=260.0, units="nmm-mm-mpa")
        case_33 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=254.0, design_temperature=260.0, units="nmm-mm-mpa")
        case_34 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=609.6, design_temperature=260.0, units="nmm-mm-mpa")
        case_35 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=25.4, design_temperature=-50.0, units="nmm-mm-mpa")
        case_36 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=152.4, design_temperature=-50.0, units="nmm-mm-mpa")
        case_37 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=254.0, design_temperature=-50.0, units="nmm-mm-mpa")
        case_38 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=609.6, design_temperature=-50.0, units="nmm-mm-mpa")
        case_39 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - With Structural Attachments", vessel_orientation="", material="Carbon and Low Alloy Steels", D=0.0,Lss=0.0,H=0.0, NPS=25.4, design_temperature=65.5556, units="nmm-mm-mpa")
        # piping tests with High Alloy and Nonferrous Steels
        case_40 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=25.4, design_temperature=65.5556, units="nmm-mm-mpa")
        case_41 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=152.4, design_temperature=65.5556, units="nmm-mm-mpa")
        case_42 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=254.0, design_temperature=65.5556, units="nmm-mm-mpa")
        case_43 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=609.6, design_temperature=65.5556, units="nmm-mm-mpa")
        case_44 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=25.4, design_temperature=260.0, units="nmm-mm-mpa")
        case_45 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=152.4, design_temperature=260.0, units="nmm-mm-mpa")
        case_46 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=304.8, design_temperature=260.0, units="nmm-mm-mpa")
        case_47 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=609.6, design_temperature=260.0, units="nmm-mm-mpa")
        case_48 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=25.4, design_temperature=-37.7778, units="nmm-mm-mpa")
        case_49 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=152.4, design_temperature=-37.7778, units="nmm-mm-mpa")
        case_50 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=254.0, design_temperature=-37.7778, units="nmm-mm-mpa")
        case_51 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - No Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=609.6, design_temperature=-37.7778, units="nmm-mm-mpa")
        case_52 = Part5ComponentType("Straight Section of Piping, Elbow or Bend - With Structural Attachments", vessel_orientation="", material="High Alloy and Nonferrous Steels", D=0.0,Lss=0.0,H=0.0, NPS=25.4, design_temperature=65.5556, units="nmm-mm-mpa")
        # Cylindrical Vessel and , Conical Shell Section tests - limited to dimensional data stated in API 579 Figure 4.3 and Figure 4.4
        # lbs-in-psi
        case_53 = Part5ComponentType("Cylindrical Vessel", vessel_orientation="horizontal", material="Carbon and Low Alloy Steels", D=120.0,Lss=96.0,H=300.0, NPS=0.0, design_temperature=0.0, units="lbs-in-psi")
        case_54 = Part5ComponentType("Cylindrical Vessel", vessel_orientation="horizontal", material="Carbon and Low Alloy Steels", D=144.0,Lss=96.0,H=300.0, NPS=0.0, design_temperature=0.0, units="lbs-in-psi")
        case_55 = Part5ComponentType("Conical Shell Section", vessel_orientation="horizontal", material="Carbon and Low Alloy Steels", D=120.0,Lss=96.0,H=300.0, NPS=0.0, design_temperature=0.0, units="lbs-in-psi")
        case_56 = Part5ComponentType("Conical Shell Section", vessel_orientation="horizontal", material="Carbon and Low Alloy Steels", D=144.0,Lss=96.0,H=300.0, NPS=0.0, design_temperature=0.0, units="lbs-in-psi")
        case_57 = Part5ComponentType("Cylindrical Vessel", vessel_orientation="vertical", material="Carbon and Low Alloy Steels", D=120.0,Lss=96.0,H=300.0, NPS=0.0, design_temperature=0.0, units="lbs-in-psi")
        case_58 = Part5ComponentType("Cylindrical Vessel", vessel_orientation="vertical", material="Carbon and Low Alloy Steels", D=144.0,Lss=96.0,H=1440.0, NPS=0.0, design_temperature=0.0, units="lbs-in-psi")
        case_59 = Part5ComponentType("Conical Shell Section", vessel_orientation="vertical", material="Carbon and Low Alloy Steels", D=120.0,Lss=96.0,H=300.0, NPS=0.0, design_temperature=0.0, units="lbs-in-psi")
        case_60 = Part5ComponentType("Conical Shell Section", vessel_orientation="vertical", material="Carbon and Low Alloy Steels", D=144.0,Lss=96.0,H=1440.0, NPS=0.0, design_temperature=0.0, units="lbs-in-psi")
        # nmm-mm-mpa
        case_61 = Part5ComponentType("Cylindrical Vessel", vessel_orientation="horizontal", material="Carbon and Low Alloy Steels", D=3048.0,Lss=2438.4,H=7620.0, NPS=0.0, design_temperature=0.0, units="nmm-mm-mpa")
        case_62 = Part5ComponentType("Cylindrical Vessel", vessel_orientation="horizontal", material="Carbon and Low Alloy Steels", D=3657.6,Lss=2438.4,H=7620.0, NPS=0.0, design_temperature=0.0, units="nmm-mm-mpa")
        case_63 = Part5ComponentType("Conical Shell Section", vessel_orientation="horizontal", material="Carbon and Low Alloy Steels", D=3048.0,Lss=2438.4,H=7620.0, NPS=0.0, design_temperature=0.0, units="nmm-mm-mpa")
        case_64 = Part5ComponentType("Conical Shell Section", vessel_orientation="horizontal", material="Carbon and Low Alloy Steels", D=3657.6,Lss=2438.4,H=7620.0, NPS=0.0, design_temperature=0.0, units="nmm-mm-mpa")
        case_65 = Part5ComponentType("Cylindrical Vessel", vessel_orientation="vertical", material="Carbon and Low Alloy Steels", D=3048.0,Lss=2438.4,H=7620.0, NPS=0.0, design_temperature=0.0, units="nmm-mm-mpa")
        case_66 = Part5ComponentType("Cylindrical Vessel", vessel_orientation="vertical", material="Carbon and Low Alloy Steels", D=3657.6,Lss=2438.4,H=36576.0, NPS=0.0, design_temperature=0.0, units="nmm-mm-mpa")
        case_67 = Part5ComponentType("Conical Shell Section", vessel_orientation="vertical", material="Carbon and Low Alloy Steels", D=3048.0,Lss=2438.4,H=7620.0, NPS=0.0, design_temperature=0.0, units="nmm-mm-mpa")
        case_68 = Part5ComponentType("Conical Shell Section", vessel_orientation="vertical", material="Carbon and Low Alloy Steels", D=3657.6,Lss=2438.4,H=36576.0, NPS=0.0, design_temperature=0.0, units="nmm-mm-mpa")
        # "Spherical Vessel","Storage Sphere"
        case_69 = Part5ComponentType("Spherical Vessel", vessel_orientation="vertical", material="Carbon and Low Alloy Steels", D=3657.6,Lss=2438.4,H=36576.0, NPS=0.0, design_temperature=0.0, units="nmm-mm-mpa")
        case_70 = Part5ComponentType("Storage Sphere", vessel_orientation="vertical", material="Carbon and Low Alloy Steels", D=3657.6,Lss=2438.4,H=36576.0, NPS=0.0, design_temperature=0.0, units="nmm-mm-mpa")
        # "Spherical Formed Head","Elliptical Formed Head","Torispherical Formed Head"
        case_71 = Part5ComponentType("Spherical Formed Head", vessel_orientation="vertical", material="Carbon and Low Alloy Steels", D=3657.6,Lss=2438.4,H=36576.0, NPS=0.0, design_temperature=0.0, units="nmm-mm-mpa")
        case_72 = Part5ComponentType("Elliptical Formed Head", vessel_orientation="vertical", material="Carbon and Low Alloy Steels", D=3657.6,Lss=2438.4,H=36576.0, NPS=0.0, design_temperature=0.0, units="nmm-mm-mpa")
        case_73 = Part5ComponentType("Torispherical Formed Head", vessel_orientation="vertical", material="Carbon and Low Alloy Steels", D=3657.6,Lss=2438.4,H=36576.0, NPS=0.0, design_temperature=0.0, units="nmm-mm-mpa")
        # "Cylindrical Atmosperic Storage Tank Shell Courses"
        case_74 = Part5ComponentType("Cylindrical Atmosperic Storage Tank Shell Courses", vessel_orientation="vertical", material="Carbon and Low Alloy Steels", D=3657.6,Lss=2438.4,H=36576.0, NPS=0.0, design_temperature=0.0, units="nmm-mm-mpa")
        # "Pressure Vessel Nozzles","Tank Nozzles","Piping Branch Connections","Reinforcement Zone of Conical Sections","Flanges","Cylinder to Flat Head Junction","Integral Tubesheet Connections"
        case_75 = Part5ComponentType("Pressure Vessel Nozzles", vessel_orientation="vertical", material="Carbon and Low Alloy Steels", D=3657.6,Lss=2438.4,H=36576.0, NPS=0.0, design_temperature=0.0, units="nmm-mm-mpa")
        case_76 = Part5ComponentType("Tank Nozzles", vessel_orientation="vertical", material="Carbon and Low Alloy Steels", D=3657.6,Lss=2438.4,H=36576.0, NPS=0.0, design_temperature=0.0, units="nmm-mm-mpa")
        case_77 = Part5ComponentType("Piping Branch Connections", vessel_orientation="vertical", material="Carbon and Low Alloy Steels", D=3657.6,Lss=2438.4,H=36576.0, NPS=0.0, design_temperature=0.0, units="nmm-mm-mpa")
        case_78 = Part5ComponentType("Reinforcement Zone of Conical Sections", vessel_orientation="vertical", material="Carbon and Low Alloy Steels", D=3657.6,Lss=2438.4,H=36576.0, NPS=0.0, design_temperature=0.0, units="nmm-mm-mpa")
        case_79 = Part5ComponentType("Flanges", vessel_orientation="vertical", material="Carbon and Low Alloy Steels", D=3657.6,Lss=2438.4,H=36576.0, NPS=0.0, design_temperature=0.0, units="nmm-mm-mpa")
        case_80 = Part5ComponentType("Cylinder to Flat Head Junction", vessel_orientation="vertical", material="Carbon and Low Alloy Steels", D=3657.6,Lss=2438.4,H=36576.0, NPS=0.0, design_temperature=0.0, units="nmm-mm-mpa")
        case_81 = Part5ComponentType("Integral Tubesheet Connections", vessel_orientation="vertical", material="Carbon and Low Alloy Steels", D=3657.6,Lss=2438.4,H=36576.0, NPS=0.0, design_temperature=0.0, units="nmm-mm-mpa")

        @test sum(case_1) == 3
        @test sum(case_2) == 3
        @test sum(case_3) == 3
        @test sum(case_4) == 2 # diameter is out of temperature range allowable for Type A
        @test sum(case_5) == 2 # temperature exceeds the maximum allowable for Type A
        @test sum(case_6) == 2 # temperature exceeds the maximum allowable for Type A
        @test sum(case_7) == 2 # temperature exceeds the maximum allowable for Type A
        @test sum(case_8) == 2 # diameter is out of temperature range allowable for Type A and temperature exceeds the maximum allowable for Type A
        @test sum(case_9) == 2 # temperature exceeds the minimum allowable for Type A
        @test sum(case_10) == 2 # temperature exceeds the minimum allowable for Type A
        @test sum(case_11) == 2 # temperature exceeds the minimum allowable for Type A
        @test sum(case_12) == 2 # diameter is out of temperature range allowable for Type A and temperature exceeds the minimum allowable for Type A
        @test sum(case_13) == 2 # piping has structural attachments therefore is a Class B, type 1 component
        @test sum(case_14) == 3 # passing case
        @test sum(case_15) == 3 # passing case
        @test sum(case_16) == 3 # passing case
        @test sum(case_17) == 2 # diameter is out of temperature range allowable for Type A
        @test sum(case_18) == 2 # temperature exceeds the maximum allowable for Type A
        @test sum(case_19) == 2 # temperature exceeds the maximum allowable for Type A
        @test sum(case_20) == 2 # temperature exceeds the maximum allowable for Type A
        @test sum(case_21) == 2 # diameter is out of temperature range allowable for Type A and temperature exceeds the maximum allowable for Type A
        @test sum(case_22) == 3 # temperature within -150F for high alloy material for Type A
        @test sum(case_23) == 2 # temperature exceeds -50F minimum for high alloy material for Type A
        @test sum(case_24) == 2 # temperature exceeds -50F minimum for high alloy material for Type A
        @test sum(case_25) == 2 # diameter is out of temperature range allowable for Type A and temperature exceeds the minimum allowable for Type A
        @test sum(case_26) == 2 # piping has structural attachments therefore is a Class B, type 1 component
        @test sum(case_27) == 3
        @test sum(case_28) == 3
        @test sum(case_29) == 3
        @test sum(case_30) == 2 # diameter is out of temperature range allowable for Type A
        @test sum(case_31) == 2 # temperature exceeds the maximum allowable for Type A
        @test sum(case_32) == 2 # temperature exceeds the maximum allowable for Type A
        @test sum(case_33) == 2 # temperature exceeds the maximum allowable for Type A
        @test sum(case_34) == 2 # diameter is out of temperature range allowable for Type A and temperature exceeds the maximum allowable for Type A
        @test sum(case_35) == 2 # temperature exceeds the minimum allowable for Type A
        @test sum(case_36) == 2 # temperature exceeds the minimum allowable for Type A
        @test sum(case_37) == 2 # temperature exceeds the minimum allowable for Type A
        @test sum(case_38) == 2 # diameter is out of temperature range allowable for Type A and temperature exceeds the minimum allowable for Type A
        @test sum(case_39) == 2 # piping has structural attachments therefore is a Class B, type 1 component
        @test sum(case_40) == 3 # passing case
        @test sum(case_41) == 3 # passing case
        @test sum(case_42) == 3 # passing case
        @test sum(case_43) == 2 # diameter is out of temperature range allowable for Type A
        @test sum(case_44) == 2 # temperature exceeds the maximum allowable for Type A
        @test sum(case_45) == 2 # temperature exceeds the maximum allowable for Type A
        @test sum(case_46) == 2 # temperature exceeds the maximum allowable for Type A
        @test sum(case_47) == 2 # diameter is out of temperature range allowable for Type A and temperature exceeds the maximum allowable for Type A
        @test sum(case_48) == 3 # temperature within -150F for high alloy material for Type A
        @test sum(case_49) == 3 # temperature within -150F for high alloy material for Type A
        @test sum(case_50) == 3 # temperature within -150F for high alloy material for Type A
        @test sum(case_51) == 2 # diameter is out of temperature range allowable for Type A and temperature exceeds the minimum allowable for Type A
        @test sum(case_52) == 2 # piping has structural attachments therefore is a Class B, type 1 component
        @test sum(case_53) == 3 # horizontal vessel (Lss/D <= 2.5 && D <= 10.0) has been met
        @test sum(case_54) == 2 # horizontal vessel (Lss/D <= 2.5 && D <= 10.0) has not been met
        @test sum(case_55) == 3 # horizontal vessel (Lss/D <= 2.5 && D <= 10.0) has been met
        @test sum(case_56) == 2 # horizontal vessel (Lss/D <= 2.5 && D <= 10.0) has not been met
        @test sum(case_57) == 3 # vertical vessel (H/D <= 3 && H <= 100) has been met
        @test sum(case_58) == 2 # vertical vessel (H/D <= 3 && H <= 100) has not been met
        @test sum(case_59) == 3 # vertical vessel (H/D <= 3 && H <= 100) has been met
        @test sum(case_60) == 2 # vertical vessel (H/D <= 3 && H <= 100) has not been met
        @test sum(case_61) == 3 # horizontal vessel (Lss/D <= 2.5 && D <= 10.0) has been met
        @test sum(case_62) == 2 # horizontal vessel (Lss/D <= 2.5 && D <= 10.0) has not been met
        @test sum(case_63) == 3 # horizontal vessel (Lss/D <= 2.5 && D <= 10.0) has been met
        @test sum(case_64) == 2 # horizontal vessel (Lss/D <= 2.5 && D <= 10.0) has not been met
        @test sum(case_65) == 3 # vertical vessel (H/D <= 3 && H <= 100) has been met
        @test sum(case_66) == 2 # vertical vessel (H/D <= 3 && H <= 100) has not been met
        @test sum(case_67) == 3 # vertical vessel (H/D <= 3 && H <= 100) has been met
        @test sum(case_68) == 2 # vertical vessel (H/D <= 3 && H <= 100) has not been met
        @test sum(case_69) == 3 # type A
        @test sum(case_70) == 3 # type A
        @test sum(case_71) == 3 # type A
        @test sum(case_72) == 3 # type A
        @test sum(case_73) == 3 # type A
        @test sum(case_74) == 3 # type A
        @test sum(case_75) == 1 # type b class 2
        @test sum(case_76) == 1 # type b class 2
        @test sum(case_77) == 1 # type b class 2
        @test sum(case_78) == 1 # type b class 2
        @test sum(case_79) == 1 # type b class 2
        @test sum(case_80) == 1 # type b class 2
        @test sum(case_81) == 1 # type b class 2
    end
end

@testset "part5_LTA_functions.jl" begin
    @testset "Non Groove Part 5 LTA Level 1 Assessment" begin
        # For all assessments determine far enough from structural discontinuity
        # Flaw-To-Major Structural Discontinuity Spacing
        tnom = .3
        trd = 0.3 # uniform thickness away from the local metal loss location established by thickness measurements at the time of the assessment.
        FCAml = 0.05 # Future Corrosion Allowance applied to the region of metal loss.
        FCA = 0.0 # Future Corrosion Allowance applied to the region away from the metal loss (see Annex 2C, paragraph 2C.2.8).
        LOSS = 0.0 #the amount of uniform metal loss away from the local metal loss location at the time of the assessment.
        Do = 10.75 # Outside Diameter
        D = Do - 2*(tnom) # Inside Dia.
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
        M1 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
        M2 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.100, 0.220, 0.280, 0.250, 0.240, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
        M3 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.215, 0.255, 0.215, 0.145, 0.275, 0.170, 0.240, 0.250, 0.250, 0.280, 0.290, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
        M4 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.170, 0.270, 0.190, 0.190, 0.285, 0.250, 0.225, 0.275, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
        M5 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
        M6 = [0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300]
        CTPGrid = hcat(M6,M5,M4,M3,M2,M1) # build in descending order
        CTPGrid = rotl90(CTPGrid) # rotate to correct orientation

        part_5_lta_level_1_known_correct_output = [.3,.1,0.333,8.266,3680.982,7947.020,3680.982,4.617,0.390,1593.429,1480.0]
        part_5_lta_level_1_output = Part5LTALevel1("Straight Pipes Subject To Internal Pressure"; equipment_group="piping",flaw_location="external",metal_loss_categorization="LTA",units="lbs-in-psi",tnom=.3,
                    trd=.3,FCA=0.0,FCAml=0.00,LOSS=0.0,Do=3.5,D=2.9,P=1480.0,S=20000.0,E=1.0,MA=0.0,Yb31=0.4, tsl=0.0, t=.3, spacings=0.5,s=6.0,c=2.0,El=1.0,Ec=1.0, RSFa=0.9, gl=0.0, gw=0.0, gr=0.0, β=0.0)
        @test part_5_lta_level_1_known_correct_output[1] == part_5_lta_level_1_output[6,2] # tc check
        @test part_5_lta_level_1_known_correct_output[2] == part_5_lta_level_1_output[7,2] # tmm check
        @test part_5_lta_level_1_known_correct_output[3] == round(part_5_lta_level_1_output[8,2], digits =3) # Rt check
        @test part_5_lta_level_1_known_correct_output[4] == round(part_5_lta_level_1_output[11,2], digits =3) # lambda check
        @test part_5_lta_level_1_known_correct_output[5] == round(part_5_lta_level_1_output[12,2], digits =3) # MAWPc check
        @test part_5_lta_level_1_known_correct_output[6] == round(part_5_lta_level_1_output[13,2], digits =3) # MAWPl check
        @test part_5_lta_level_1_known_correct_output[7] == round(part_5_lta_level_1_output[14,2], digits =3) # MAWP check
        @test part_5_lta_level_1_known_correct_output[8] == round(part_5_lta_level_1_output[15,2], digits =3) # Mt check
        @test part_5_lta_level_1_known_correct_output[9] == round(part_5_lta_level_1_output[16,2], digits =3) # RSF check
        @test part_5_lta_level_1_known_correct_output[10] == round(part_5_lta_level_1_output[17,2], digits =3) # MAWPr check
        @test part_5_lta_level_1_known_correct_output[11] == round(part_5_lta_level_1_output[18,2], digits =3) # MAWPr check
    end
end
