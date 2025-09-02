
metadata(g::GiftiStruct) = g.metadata
metadata(a::GiftiDataArray) = a.metadata
metadata(m::ArrayMetadata) = m.metadata

data(g::GiftiStruct) = g.data
data(g::GiftiStruct, intent::AbstractString) = data(g)[get(g.intent_lookup, intent, Int[])]
data(g::GiftiStruct, regex::Regex) = filter(d -> occursin(regex, intent(d)), data(g))

data(a::GiftiDataArray) = a.data

Base.length(g::GiftiStruct) = length(data(g))
Base.getindex(g::GiftiStruct, i::Integer) = data(g)[i]

Base.getindex(a::GiftiDataArray, args...) = getindex(data(a), args...)

Base.size(a::GiftiDataArray) = size(data(a))

Base.iterate(g::GiftiStruct) = iterate(data(g))
Base.iterate(g::GiftiStruct, state) = iterate(data(g), state)
Base.eltype(::Type{GiftiStruct}) = GiftiDataArray
Base.lastindex(g::GiftiStruct) = length(g)

Base.iterate(a::GiftiDataArray, args...) = iterate(data(a), args...)
Base.length(a::GiftiDataArray) = length(data(a))
Base.axes(a::GiftiDataArray, args...) = axes(data(a), args...)
Base.lastindex(a::GiftiDataArray) = lastindex(data(a))
Base.axes(a::GiftiDataArray) = axes(data(a))

intent(a::GiftiDataArray) = metadata(a).intent
intents(g::GiftiStruct)= [intent(a) for a in data(g)]

# plural accessors that always return a vector of matching arrays:
pointsets(g::GiftiStruct) = data(g, "NIFTI_INTENT_POINTSET")
triangles(g::GiftiStruct) = data(g, "NIFTI_INTENT_TRIANGLE")

transforms(a::GiftiDataArray) = metadata(a).coordinate_transforms

# singular accessors that return only one matching array:
pointset(g::GiftiStruct) = first(pointsets(g))
triangle(g::GiftiStruct) = first(triangles(g))

has_pointset(g::GiftiStruct) = haskey(g.intent_lookup, "NIFTI_INTENT_POINTSET")
has_triangle(g::GiftiStruct) = haskey(g.intent_lookup, "NIFTI_INTENT_TRIANGLE")
has_pointsets(g::GiftiStruct) = has_pointset(g)
has_triangles(g::GiftiStruct) = has_triangle(g)
has_time_series(g::GiftiStruct) = haskey(g.intent_lookup, "NIFTI_INTENT_TIME_SERIES")
has_timeseries(g::GiftiStruct) = has_time_series(g)

## todo: handling of sparse data
is_sparse(g::GiftiStruct) = !isnothing(g["NIFTI_INTENT_NODE_INDEX"])
function node_indices(g::GiftiStruct)
	arr = data(g, "NIFTI_INTENT_NODE_INDEX")
	isnothing(arr) && return nothing
	return arr.data .+ 1 # convert from 0-based to 1-based
end

