
metadata(g::GiftiStruct) = g.metadata
metadata(a::GiftiDataArray) = a.metadata
metadata(m::ArrayMetadata) = m.metadata

data(g::GiftiStruct) = g.data
data(g::GiftiStruct, intent::String) = data(g)[get(g.intent_lookup, intent, Int[])]
data(g::GiftiStruct, regex::Regex) = filter(d -> occursin(regex, intent(d)), data(g))

data(d::GiftiDataArray) = d.data

Base.length(g::GiftiStruct) = length(data(g))
Base.getindex(g::GiftiStruct, i::Int) = data(g)[i]

Base.size(a::GiftiDataArray) = size(data(a))

Base.iterate(g::GiftiStruct) = iterate(g.data)
Base.iterate(g::GiftiStruct, state) = iterate(g.data, state)
Base.eltype(::Type{GiftiStruct}) = GiftiDataArray
Base.lastindex(g::GiftiStruct) = length(g)

intent(a::GiftiDataArray) = metadata(a).intent
intents(g::GiftiStruct)= [intent(a) for a in data(g)]

# plural accessors that always return a vector of matching arrays:
pointsets(g::GiftiStruct) = data(g, "NIFTI_INTENT_POINTSET")
triangles(g::GiftiStruct) = data(g, "NIFTI_INTENT_TRIANGLE")

# singular accessors that assume only one matching array:
pointset(g::GiftiStruct) = only(pointsets(g))
triangle(g::GiftiStruct) = only(triangles(g))

has_pointset(g::GiftiStruct) = haskey(g.intent_lookup, "NIFTI_INTENT_POINTSET")
has_triangle(g::GiftiStruct) = haskey(g.intent_lookup, "NIFTI_INTENT_TRIANGLE")
has_pointsets(g::GiftiStruct) = has_pointest(g)
has_triangles(g::GiftiStruct) = has_triangle(g)
has_time_series(g::GiftiStruct) = haskey(g.intent_lookup, "NIFTI_INTENT_TIME_SERIES")
has_timeseries(g::GiftiStruct) = has_timeseries(g)

## todo: handling of sparse data
is_sparse(g::GiftiStruct) = !isnothing(g["NIFTI_INTENT_NODE_INDEX"])
function node_indices(g::GiftiStruct)
	arr = g["NIFTI_INTENT_NODE_INDEX"]
	isnothing(arr) && return nothing
	return arr.data .+ 1 # convert from 0-based to 1-based
end

