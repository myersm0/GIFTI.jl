
function parse_data_type(type_str::String)
	haskey(nifti_to_julia_type, type_str) || 
		throw(GiftiFormatError("Unknown data type: $type_str"))
	return nifti_to_julia_type[type_str]
end

function parse_dimensions(xml_element::XMLElement)
	n_dims = parse(Int, attribute(xml_element, "Dimensionality"))
	dims = Int[]
	for i in 0:(n_dims-1)
		dim_attr = "Dim$i"
		has_attribute(xml_element, dim_attr) || 
			throw(GiftiFormatError("Missing dimension attribute: $dim_attr"))
		push!(dims, parse(Int, attribute(xml_element, dim_attr)))
	end
	return dims
end

function parse_coordinate_system_transform(xml_element::XMLElement)
	transform_elements = get_elements_by_tagname(xml_element, "CoordinateSystemTransformMatrix")
	isempty(transform_elements) && return nothing
	
	transforms = Matrix{Float64}[]
	for transform_elem in transform_elements
		# Parse DataSpace and TransformedSpace (for documentation)
		data_space_elem = get_elements_by_tagname(transform_elem, "DataSpace")
		transformed_space_elem = get_elements_by_tagname(transform_elem, "TransformedSpace")
		
		matrix_data = get_elements_by_tagname(transform_elem, "MatrixData")
		isempty(matrix_data) && continue
		data_str = content(first(matrix_data))
		values = parse.(Float64, split(data_str))
		length(values) == 16 || throw(GiftiFormatError("Transform matrix must have 16 elements"))
		# todo: reconsider this transpose
		matrix = reshape(values, 4, 4)'  # Transpose for row-major to column-major
		push!(transforms, matrix)
	end
	
	# todo: saner handling of conditions
	# Return the first transform if more than one exists
	if length(transforms) > 1
		@warn "Multiple coordinate transforms found, using only the first"
	end
	return isempty(transforms) ? nothing : transforms[1]
end

function parse_metadata_dict(xml_element::XMLElement)
	metadata = Dict{String, String}()
	meta_elements = get_elements_by_tagname(xml_element, "MetaData")
	for meta_elem in meta_elements
		md_elements = get_elements_by_tagname(meta_elem, "MD")
		for md in md_elements
			name_elem = get_elements_by_tagname(md, "Name")
			value_elem = get_elements_by_tagname(md, "Value")
			if !isempty(name_elem) && !isempty(value_elem)
				metadata[content(first(name_elem))] = content(first(value_elem))
			end
		end
	end
	return metadata
end

function decode_data(data_string::String, encoding::String)
	if encoding == "ASCII"
		return data_string
	elseif encoding == "Base64Binary"
		return base64decode(data_string)
	elseif encoding == "GZipBase64Binary"
		gzipped = base64decode(data_string)
		return transcode(GzipDecompressor, gzipped)
	else
		throw(GiftiFormatError("Unsupported encoding: $encoding"))
	end
end

function parse_array_data(xml_element::XMLElement, metadata::ArrayMetadata)
	data_elements = get_elements_by_tagname(xml_element, "Data")
	isempty(data_elements) && throw(GiftiFormatError("No Data element found"))
	
	data_elem = first(data_elements)
	raw_data = content(data_elem)
	
	if metadata.encoding == "ExternalFileBinary"
		if isnothing(metadata.external_file)
			throw(GiftiFormatError("External file reference missing"))
		end
		throw(GiftiFormatError("External file reading not yet implemented"))
	end
	
	if metadata.encoding == "ASCII"
		values = parse.(metadata.data_type, split(raw_data))
	else
		bytes = decode_data(raw_data, metadata.encoding)
		values = reinterpret(metadata.data_type, bytes)
		if metadata.endian == "BigEndian"
			values = ntoh.(values)
		else
			values = ltoh.(values)
		end
	end
	
	total_elements = prod(metadata.dimensions)
	length(values) == total_elements || 
		throw(GiftiFormatError("Data size mismatch: expected $total_elements, got $(length(values))"))
	
	if attribute(xml_element, "ArrayIndexingOrder") == "RowMajorOrder"
		# todo: reconsider whether we want to do this conversion
		# Convert from row-major to column-major
		array = reshape(values, tuple(reverse(metadata.dimensions)...))
		# todo: make this more general
		n_dims = length(metadata.dimensions)
		if n_dims == 2
			array = permutedims(array, (2, 1))
		elseif n_dims == 3
			array = permutedims(array, (3, 2, 1))
		end
	else
		array = reshape(values, metadata.dimensions...)
	end
	
	return array
end

function parse_data_array(xml_element::XMLElement)
	intent = attribute(xml_element, "Intent")
	data_type = parse_data_type(attribute(xml_element, "DataType"))
	dimensions = parse_dimensions(xml_element)
	encoding = attribute(xml_element, "Encoding")
	endian = attribute(xml_element, "Endian")
	
	# optional attributes
	name = has_attribute(xml_element, "ArrayName") ? 
		attribute(xml_element, "ArrayName") : nothing
	external_file = has_attribute(xml_element, "ExternalFileName") ?
		attribute(xml_element, "ExternalFileName") : nothing
	external_offset = has_attribute(xml_element, "ExternalFileOffset") ?
		parse(Int, attribute(xml_element, "ExternalFileOffset")) : 0
	
	transform = parse_coordinate_system_transform(xml_element)
	metadata_dict = parse_metadata_dict(xml_element)
	metadata = ArrayMetadata(
		name, data_type, intent, dimensions,
		encoding, endian, external_file, external_offset,
		transform, metadata_dict
	)
	data = parse_array_data(xml_element, metadata)
	return GiftiDataArray(data, metadata)
end

function parse_global_metadata(xml_root::XMLElement)
	metadata = Dict{String, Any}()
	metadata["version"] = has_attribute(xml_root, "Version") ?
		attribute(xml_root, "Version") : "1.0"
	metadata["num_data_arrays"] = has_attribute(xml_root, "NumberOfDataArrays") ?
		parse(Int, attribute(xml_root, "NumberOfDataArrays")) : 0
	
	meta_dict = parse_metadata_dict(xml_root)
	for (k, v) in meta_dict
		metadata[k] = v
	end
	
	label_tables = get_elements_by_tagname(xml_root, "LabelTable")
	if !isempty(label_tables)
		metadata["label_table"] = parse_label_table(first(label_tables))
	end
	
	return metadata
end

function parse_label_table(xml_element::XMLElement)
	labels = Dict{Int32, Tuple{String, Vector{Float32}}}()
	label_elements = get_elements_by_tagname(xml_element, "Label")
	for label in label_elements
		key = parse(Int32, attribute(label, "Key"))
		name = content(label)
		color = if has_attribute(label, "Red")
			[
				parse(Float32, attribute(label, "Red")),
				parse(Float32, attribute(label, "Green")),
				parse(Float32, attribute(label, "Blue")),
				parse(Float32, attribute(label, "Alpha"))
			]
		else
			Float32[1.0, 1.0, 1.0, 1.0]
		end
		labels[key] = (name, color)
	end
	return labels
end

