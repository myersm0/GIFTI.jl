
struct CoordinateTransform
	data_space::String
	transformed_space::String
	matrix::Matrix{Float64}
end

struct ArrayMetadata
	name::Union{Nothing, String}
	data_type::DataType
	intent::String
	dimensions::Tuple{Vararg{Int}}
	encoding::String
	endian::String
	external_file::Union{Nothing, String}
	external_offset::Int
	coordinate_transforms::Vector{CoordinateTransform}
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
		size(data) == metadata.dimensions || throw(
			GiftiFormatError(
				"array is $(size(data)) but metadata specifies $(metadata.dimensions)"
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

