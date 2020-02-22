
@doc """
    COV_var(x::Array{Float64})::Array{Float64}

Determine Coefficient of Variation, COV
    """ ->
function COV_var(x::Array{Float64})::Array{Float64}
    @assert size(x,1) >= 15 "Minimum of 15 readings required to confirm metal loss is general - provide more readings'"
    let Tam = Tam, index = index
        index = collect(1:1:size(x,1))
        Tam = mean(x)
        # Calculate (Trdi - Tam) and (Trdi - Tam)^2
Trdi_Tam = zeros(size(x,1))
Trdi_Tam_2power = zeros(size(x,1))
for i = 1:size(x,1)
  Trdi_Tam[i] = x[i] - Tam
  Trdi_Tam_2power[i] = (x[i] - Tam)^2
end

S = sum(Trdi_Tam_2power) # sum (Trdi - Tam)^2 sqaured differences
N = size(x,1)

# COV
COV = (1/Tam)*((S/(N-1))^0.5)

    end # let
    return out = [Tam, COV]
end # function

COV_var(x)
