
function load(filename::String)::GiftiStruct
	isfile(filename) || throw(ArgumentError("File does not exist: $filename"))
	
	doc = parse_file(filename)
	root_elem = root(doc)
	
	name(root_elem) == "GIFTI" || 
		throw(
			GiftiFormatError(
				"Not a valid GIFTI file: root element is $(name(root_elem))"
			)
		)
	
	global_metadata = parse_global_metadata(root_elem)
	version = pop!(global_metadata, "version", "1.0")
	
	array_elements = get_elements_by_tagname(root_elem, "DataArray")
	arrays = GiftiDataArray[]
	
	for arr_elem in array_elements
		try
			push!(arrays, parse_data_array(arr_elem))
		catch e
			if e isa GiftiFormatError
				@warn "Failed to parse data array: $(e.msg)"
			else
				rethrow()
			end
		end
	end
	
	free(doc)
	return test = GiftiStruct(arrays, global_metadata, version, filename)
end


