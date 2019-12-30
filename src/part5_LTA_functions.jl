# Functions for the Part 5 LTA assessment

@doc """
Part5LTAFlawSizeLimitCriteria(equipment_group::String,units::String)::Array{Int64}

Determine if the flaw is acceptable per level 1 criteria
    """ ->
function Part5LTAFlawSizeLimitCriteria(equipment_group::String,units::String)::Array{Int64}
    let test_1 = 0, test_2 = 0, test_3 =.0, test_4 = 0
        @assert any(equipment_group .== ["piping","vessel","tank"]) "Invalid input - select either: 'piping' or 'vessel' or 'tank'"
if (equipment_group == "piping" || equipment_group == "vessel" || equipment_group == "tank")
    if (Rt >= 0.20)
        print("eq 5.7 is Satisfied\n")
        test_1 = 1
    end
    if (Lmsd[1] >= 1.8*(sqrt(D*tc)))
        print("eq 5.10 is Satisfied\n")
        test_4 = 1
    end
end
if (equipment_group == "vessel" || equipment_group == "tank")
    if (units == "lbs-in-psi")
        if (tmm - FCAml >= 0.10)
            print("eq 5.8 is Satisfied\n")
            test_2 = 1
        end
    elseif (units == "nmm-mm-mpa")
        if (tmm - FCAml >=2.5)
            print("eq 5.8 is Satisfied\n")
            test_2 = 1
        end
    end
end
if (equipment_group == "piping")
    if (units == "lbs-in-psi")
        if (tmm - FCAml >=0.05)
            print("eq 5.9 is Satisfied\n")
            test_3 = 1
        end
    elseif (units == "nmm-mm-mpa")
        if (tmm - FCAml >=1.3)
            print("eq 5.9 is Satisfied\n")
            test_3 = 1
        end
    end
end
return level_1_satisfied = [test_1,test_2,test_3,test_4]
end # let end
end

@doc """
    Part5LTAFlawSizeLevel1Acceptance(x::Array{Int64})::Array{Int64}

Determine if the limiting flaw size criteria has met the level 1 requirments
""" ->
function Part5LTAFlawSizeLevel1Acceptance(x::Array{Int64},equipment_group::String)::Int64
    @assert any(equipment_group .== ["piping","vessel","tank"]) "Invalid input - select either: 'piping' or 'vessel' or 'tank'"
    let level_1_satisfied = 0
    # level 1
    if (sum([x[1],x[2],x[3],x[4]]) == 3)
        print("The criteria for level 1 assessment has been satisfied - proceed to STEP 6\n")
        level_1_satisfied = 1
    end
    if (sum([x[1],x[2],x[3],x[4]]) != 3)
        print("The criteria for level 1 assessment has not been satisfied - level 1 assessment failed\n")
        level_1_satisfied = 0
        if (x[1] == 0)
            print("eq 5.7 has not been Satisfied\n")
        end
        if (x[2] == 0 && (equipment_group == "vessel" || equipment_group == "tank"))
            print("(for vessels & tanks) eq 5.8 has not been Satisfied\n")
        end
        if (x[3] == 0 && equipment_group == "piping")
            print("(for piping)  eq 5.9 has not been Satisfied\n")
        end
        if (x[4] == 0)
            print("eq 5.10 has not been Satisfied\n")
        end
    end # not equal to end
    return level_1_satisfied
end # let end
end # function end
