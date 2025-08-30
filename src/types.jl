# Core GIFTI data structures

struct ArrayMetadata
	name::Union{Nothing, String}
	data_type::DataType
	intent::String
	dimensions::Vector{Int}
	encoding::String
	endian::String
	external_file::Union{Nothing, String}
	external_offset::Int
	coordinate_system_transform::Union{Nothing, Matrix{Float64}}
	metadata_dict::Dict{String, String}  # For additional metadata key-value pairs
end

struct GiftiDataArray{T, N}
	data::Array{T, N}
	metadata::ArrayMetadata
end

struct GiftiStruct
	arrays::Vector{GiftiDataArray}
	global_metadata::Dict{String, Any}
	version::String
	filename::Union{Nothing, String}
end

# Custom error types
struct GiftiFormatError <: Exception
	msg::String
end

# Constructor helpers
function GiftiDataArray(data::Array{T, N}, metadata::ArrayMetadata) where {T, N}
	# Validate that data type matches metadata
	if T != metadata.data_type
		throw(GiftiFormatError(
			"Data type mismatch: array is $(T) but metadata specifies $(metadata.data_type)"
		))
	end
	# Validate dimensions
	if size(data) != Tuple(metadata.dimensions)
		throw(GiftiFormatError(
			"Dimension mismatch: array is $(size(data)) but metadata specifies $(Tuple(metadata.dimensions))"
		))
	end
	return GiftiDataArray{T, N}(data, metadata)
end

# Type detection helpers
function array_type(arr::GiftiDataArray)
	return arr.metadata.intent
end

function is_coordinate_array(arr::GiftiDataArray)
	return arr.metadata.intent == "NIFTI_INTENT_POINTSET"
end

function is_triangle_array(arr::GiftiDataArray)
	return arr.metadata.intent == "NIFTI_INTENT_TRIANGLE"
end

function is_shape_array(arr::GiftiDataArray)
	return arr.metadata.intent == "NIFTI_INTENT_SHAPE"
end

function is_label_array(arr::GiftiDataArray)
	return arr.metadata.intent == "NIFTI_INTENT_LABEL"
end

function is_time_series_array(arr::GiftiDataArray)
	return arr.metadata.intent == "NIFTI_INTENT_TIME_SERIES"
end

# Pretty printing
function Base.show(io::IO, ::MIME"text/plain", g::GiftiStruct)
	println(io, "GiftiStruct")
	println(io, "  version:     ", g.version)
	println(io, "  num arrays:  ", length(g.arrays))
	if !isnothing(g.filename)
		println(io, "  source:      ", basename(g.filename))
	end
	if length(g.arrays) > 0
		println(io, "  arrays:")
		for (i, arr) in enumerate(g.arrays)
			intent = arr.metadata.intent
			dims = arr.metadata.dimensions
			dtype = arr.metadata.data_type
			println(io, "    [$i] $intent: $(dims) $(dtype)")
		end
	end
end

function Base.show(io::IO, ::MIME"text/plain", arr::GiftiDataArray)
	println(io, "GiftiDataArray{$(eltype(arr.data)), $(ndims(arr.data))}")
	println(io, "  intent:     ", arr.metadata.intent)
	println(io, "  dimensions: ", size(arr.data))
	println(io, "  data type:  ", eltype(arr.data))
	if !isnothing(arr.metadata.name)
		println(io, "  name:       ", arr.metadata.name)
	end
end
