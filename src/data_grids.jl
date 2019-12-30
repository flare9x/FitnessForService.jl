# Grid Function
@doc """
    CTP_Grid(CTPGrid::Array{Float64,2})

    Returns tmm - minimum measured thickness determined at the time of the inspection
"""
function CTP_Grid(CTPGrid::Array{Float64,2})
    # Labels for plotting
    #=circumferential_plane_index = Int64.(collect(1:1:s2)) # collect auto rounds - no need to write code to correct
    circ_label = fill("C",length(circumferential_plane_index))
    circ_index_labels = map(string, circ_label, circumferential_plane_index) # join integer and string to string
    circ_spacing_index = collect(0:0.5:(length(circumferential_plane_index)/2)-spacings)
    longitudinal_plane_index = Int64.(collect(1:1:c2)) # collect auto rounds - no need to write code to correct
    long_label = fill("M",length(longitudinal_plane_index))
    long_index_labels = map(string, long_label, longitudinal_plane_index) # join integer and string to string
    long_spacing_index = collect(0:0.5:(length(longitudinal_plane_index)/2)-spacings)
    =#

    # Determine CTPs (Critical Thickness Profiles)
    Circumferential_CTP = zeros(size(CTPGrid,1)) # initialize output
    Longitudinal_CTP = zeros(size(CTPGrid,2)) # initialize output
    col_index = [1:size(CTPGrid,2);]
    row_index = [1:size(CTPGrid,1);]
    @inbounds for i in 1:size(CTPGrid,1)
        Circumferential_CTP[i] = minimum(CTPGrid[row_index[i],1:size(CTPGrid,2)])
    end
    @inbounds for i in 1:size(CTPGrid,2)
        Longitudinal_CTP[i] = minimum(CTPGrid[1:size(CTPGrid,1),col_index[i]:size(CTPGrid,2)])
    end

    # find tmm
    minC_CTP = minimum(Circumferential_CTP)
    minL_CTP = minimum(Longitudinal_CTP)
    tmm = minimum([minC_CTP,minL_CTP]) # minimum measured thickness determined at the time of the inspection.
        return tmm
end
