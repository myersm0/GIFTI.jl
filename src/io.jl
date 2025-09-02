
"""
    load(filename::String)

Load a GIFTI file from disk.

Returns a GiftiStruct containing its data arrays and metadata.
"""
function load(filename::AbstractString)
	isfile(filename) || throw(ArgumentError("File does not exist: $filename"))
	
	doc = parse_file(filename)
	root_elem = root(doc)
	
	name(root_elem) == "GIFTI" || 
		throw(
			GiftiFormatError(
				"Not a valid GIFTI file: root element is $(name(root_elem))"
			)
		)
	
	metadata = parse_global_metadata(root_elem)
	version = pop!(metadata, "version", "1.0") # todo: ?
	
	arrays = GiftiDataArray[]
	intent_lookup = Dict{String, Vector{Int}}()
	elements = get_elements_by_tagname(root_elem, "DataArray")
	for (i, element) in enumerate(elements)
		array = parse_data_array(element)
		push!(arrays, array)
		array_counter = get!(intent_lookup, intent(array), Int[])
		push!(array_counter, i)
	end
	
	free(doc)
	return test = GiftiStruct(
		arrays, intent_lookup, metadata, version, filename
	)
end

