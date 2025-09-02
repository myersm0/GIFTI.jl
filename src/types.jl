
struct ArrayMetadata
	name::Union{Nothing, String}
	data_type::DataType
	intent::String
	dimensions::Vector{Int} # todo: why not just determine from array?
	encoding::String
	endian::String
	external_file::Union{Nothing, String}
	external_offset::Int
	coordinate_system_transform::Union{Nothing, Matrix{Float64}}
	metadata::Dict{String, String}  # for additional metadata key-value pairs
end

struct GiftiDataArray{T, N}
	data::Array{T, N}
	metadata::ArrayMetadata
	function GiftiDataArray(data::Array{T, N}, metadata::ArrayMetadata) where {T, N}
		T == metadata.data_type || throw(
			GiftiFormatError(
				"array is $(T) but metadata specifies $(metadata.data_type)"
			)
		)
		size(data) == Tuple(metadata.dimensions) || throw(
			GiftiFormatError(
				"array is $(size(data)) but metadata specifies $(Tuple(metadata.dimensions))"
			)
		)
		return new{T, N}(data, metadata)
	end
end

struct GiftiStruct
	data::Vector{GiftiDataArray}
	intent_lookup::Dict{String, Vector{Int}}
	metadata::Dict{String, Any}
	version::String
	filename::Union{Nothing, String}
end

struct GiftiFormatError <: Exception
	msg::String
end

