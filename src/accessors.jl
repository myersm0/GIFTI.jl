
data(g::GiftiStruct) = g.arrays

arrays(g::GiftiStruct) = data(g)

Base.length(g::GiftiStruct) = length(g.arrays)

Base.getindex(g::GiftiStruct, i::Int) = g.arrays[i]

function Base.filter(g::GiftiStruct, intent::String)
	return filter(a -> intent(a) == intent, g.arrays)
end

Base.filter(f::Function, g::GiftiStruct) = return filter(f, g.arrays)

function Base.getindex(g::GiftiStruct, intent::String)
	indices = g.lookup[intent]
	return g.arrays[indices]
end

function is_sparse(g::GiftiStruct)
	return !isnothing(g["NIFTI_INTENT_NODE_INDEX"])
end

# todo: not sure what this is for
function node_indices(g::GiftiStruct)
	arr = g["NIFTI_INTENT_NODE_INDEX"]
	isnothing(arr) && return nothing
	return arr.data .+ 1 # convert from 0-based to 1-based
end

metadata(g::GiftiStruct) = g.metadata
metadata(a::GiftiDataArray) = a.metadata
intent(a::GiftiDataArray) = metadata(a).intent
data(a::GiftiDataArray) = a.data
Base.size(a::GiftiDataArray) = size(data(a))

# singular accessors that assume only one matching array:
triangles(g::GiftiStruct) = only(g["NIFTI_INTENT_TRIANGLE"])
pointset(g::GiftiStruct) = only(g["NIFTI_INTENT_POINTSET"])

# a plural accessor that always returns a vector of matching arrays:
pointsets(g::GiftiStruct) = g["NIFTI_INTENT_POINTSET"]

time_series(g::GiftiStruct) = g["NIFTI_INTENT_TIME_SERIES"]
timeseries(g::GiftiStruct) = time_series(g)
anatomical_structure(g::GiftiStruct) = metadata(g, "AnatomicalStructurePrimary")
brainstructure(g::GiftiStruct) = anatomical_structure(g)
intents(g::GiftiStruct)= [arr.metadata.intent for arr in g.arrays]
has_coordinates(g::GiftiStruct) = !isnothing(g["NIFTI_INTENT_POINTSET"])
has_triangles(g::GiftiStruct) = !isnothing(g["NIFTI_INTENT_TRIANGLE"])
has_time_series(g::GiftiStruct) = !isnothing(g["NIFTI_INTENT_TIME_SERIES"])
has_timeseries(g::GiftiStruct) = has_timeseries(g)



