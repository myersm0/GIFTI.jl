
Base.length(g::GiftiStruct) = length(g.arrays)

Base.getindex(g::GiftiStruct, i::Int) = g.arrays[i]

function Base.filter(g::GiftiStruct, intent::String)
	return filter(x -> x.metadata.intent == intent, g.arrays)
end

function Base.filter(f::Function, g::GiftiStruct)
	return filter(f, g.arrays)
end

function Base.getindex(g::GiftiStruct, intent::String)
	temp = filter(g, intent)
	length(temp) == 0 && error("intent $intent not found")
	length(temp) > 1 && error("multiple arrays found with intent $intent")
	return only(temp)
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
pointset(g::GiftiStruct) = g["NIFTI_INTENT_POINTSET"]
coordinates(g::GiftiStruct) = pointset(g)
triangles(g::GiftiStruct) = g["NIFTI_INTENT_TRIANGLE"] 
time_series(g::GiftiStruct) = g["NIFTI_INTENT_TIME_SERIES"]
timeseries(g::GiftiStruct) = time_series(g)
anatomical_structure(g::GiftiStruct) = metadata(g, "AnatomicalStructurePrimary")
brainstructure(g::GiftiStruct) = anatomical_structure(g)
intents(g::GiftiStruct)= [arr.metadata.intent for arr in g.arrays]
has_coordinates(g::GiftiStruct) = !isnothing(g["NIFTI_INTENT_POINTSET"])
has_triangles(g::GiftiStruct) = !isnothing(g["NIFTI_INTENT_TRIANGLE"])
has_time_series(g::GiftiStruct) = !isnothing(g["NIFTI_INTENT_TIME_SERIES"])
has_timeseries(g::GiftiStruct) = has_timeseries(g)

