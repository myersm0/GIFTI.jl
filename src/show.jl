
function Base.show(io::IO, ::MIME"text/plain", g::GiftiStruct)
	println(io, "GiftiStruct")
	println(io, "  version:     ", g.version)
	println(io, "  num arrays:  ", length(g))
	if !isnothing(g.filename)
		println(io, "  source:      ", basename(g.filename))
	end
	if length(g) > 0
		println(io, "  arrays:")
		for (i, arr) in enumerate(data(g))
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

function Base.show(io::IO, ::MIME"text/plain", m::ArrayMetadata)
	println(io, "ArrayMetadata")
	println(io, "  intent:      ", m.intent)
	println(io, "  data_type:   ", m.data_type)
	println(io, "  dimensions:  ", join(m.dimensions, " × "))
	!isnothing(m.name) && println(io, "  name:        ", m.name)
	println(io, "  encoding:    ", m.encoding)
	println(io, "  endian:      ", m.endian)
	
	if !isnothing(m.external_file)
		println(io, "  external:    ", m.external_file)
		if m.external_offset > 0
			println(io, "  offset:      ", m.external_offset)
		end
	end
	
	println(io, "  transform:   ", size(m.coordinate_system_transform), " matrix")
	
	if !isempty(m.metadata)
		println(io, "  metadata:    ", length(m.metadata), " entries")
		if length(m.metadata) <= 3
			for (k, v) in m.metadata
				# Truncate long values
				v_display = length(v) > 50 ? v[1:47] * "..." : v
				println(io, "    ", k, ": ", v_display)
			end
		end
	end
end

