
data(g::GiftiStruct) = g.data
data(d::GiftiDataArray) = d.data

Base.length(g::GiftiStruct) = length(data(g))

Base.getindex(g::GiftiStruct, i::Int) = data(g)[i] # todo: is g.data[i] faster?

function Base.getindex(g::GiftiStruct, intent::String)
	indices = get(g.lookup, intent, Int[])
	return data(g)[indices] # todo: is g.data[indices] faster?
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
Base.size(a::GiftiDataArray) = size(data(a))

# plural accessors that always returns a vector of matching arrays:
pointsets(g::GiftiStruct) = g["NIFTI_INTENT_POINTSET"]
triangles(g::GiftiStruct) = g["NIFTI_INTENT_TRIANGLE"]

# singular accessors that assume only one matching array:
pointset(g::GiftiStruct) = only(pointsets(g))
triangle(g::GiftiStruct) = only(triangles(g))

intents(g::GiftiStruct)= [arr.metadata.intent for arr in data(g)]

has_pointset(g::GiftiStruct) = !isnothing(g["NIFTI_INTENT_POINTSET"])
has_triangle(g::GiftiStruct) = !isnothing(g["NIFTI_INTENT_TRIANGLE"])
has_pointsets(g::GiftiStruct) = has_pointest(g)
has_triangles(g::GiftiStruct) = has_triangle(g)
has_time_series(g::GiftiStruct) = !isnothing(g["NIFTI_INTENT_TIME_SERIES"])
has_timeseries(g::GiftiStruct) = has_timeseries(g)



