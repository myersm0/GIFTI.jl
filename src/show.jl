
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

