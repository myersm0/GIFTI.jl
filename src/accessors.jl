# Convenience functions for accessing GIFTI data

Base.getindex(g::GiftiStruct, i::Int) = g.arrays[i]

function Base.getindex(g::GiftiStruct, intent::String)
	matching = filter(arr -> arr.metadata.intent == intent, g.arrays)
	if length(matching) == 0
		return nothing
	elseif length(matching) == 1
		return first(matching)
	else
		return matching
	end
end

Base.length(g::GiftiStruct) = length(g.arrays)

function is_sparse(g::GiftiStruct)
	return !isnothing(g["NIFTI_INTENT_NODE_INDEX"])
end

function node_indices(g::GiftiStruct)
	arr = g["NIFTI_INTENT_NODE_INDEX"]
	isnothing(arr) && return nothing
	# Convert from 0-based to 1-based indexing
	return arr.data .+ 1
end

function coordinates(g::GiftiStruct)
	arr = g["NIFTI_INTENT_POINTSET"]
	isnothing(arr) && throw(GiftiFormatError("No coordinate array found"))
	
	# Check for required CoordinateSystemTransformMatrix
	if isnothing(arr.metadata.coordinate_system_transform)
		@warn "GIFTI spec requires CoordinateSystemTransformMatrix for POINTSET data, but none found"
	end
	
	coords = arr.data
	# Ensure 3×N format
	if size(coords, 1) != 3 && size(coords, 2) == 3
		coords = coords'
	elseif size(coords, 1) != 3
		throw(GiftiFormatError("Coordinate array must have 3 dimensions"))
	end
	
	return coords
end

function triangles(g::GiftiStruct; one_indexed = true)
	arr = g["NIFTI_INTENT_TRIANGLE"] 
	isnothing(arr) && return nothing
	
	tris = arr.data
	# Ensure 3×M format
	if size(tris, 1) != 3 && size(tris, 2) == 3
		tris = tris'
	elseif size(tris, 1) != 3
		throw(GiftiFormatError("Triangle array must have 3 columns"))
	end
	
	# Convert to 1-based indexing for Julia
	if one_indexed && minimum(tris) == 0
		tris = tris .+ 1
	end
	
	return tris
end

function medial_wall(g::GiftiStruct; threshold = 0.5)
	n_vertices = size(coordinates(g), 2)
	
	# Strategy 1: Look for shape array named "medial_wall" or similar
	shape_arrays = filter(arr -> is_shape_array(arr), g.arrays)
	for arr in shape_arrays
		if !isnothing(arr.metadata.name) && 
		   occursin(r"medial"i, arr.metadata.name)
			# Assume values > threshold indicate medial wall
			return arr.data .> threshold
		end
	end
	
	# Strategy 2: Look for label array with medial wall labels
	label_arrays = filter(arr -> is_label_array(arr), g.arrays)
	for arr in label_arrays
		if haskey(g.global_metadata, "label_table")
			labels = g.global_metadata["label_table"]
			# Look for labels containing "medial" or "wall"
			mw_keys = Int32[]
			for (key, (name, _)) in labels
				if occursin(r"medial|wall"i, name)
					push!(mw_keys, key)
				end
			end
			if !isempty(mw_keys)
				return [v in mw_keys for v in arr.data]
			end
		end
	end
	
	# Strategy 3: Check for vertices at origin or with invalid coordinates
	coords = coordinates(g)
	is_invalid = vec(
		all(coords .== 0, dims = 1) .|| 
		any(isnan.(coords), dims = 1) .||
		any(isinf.(coords), dims = 1)
	)
	
	if any(is_invalid)
		return BitVector(is_invalid)
	end
	
	# Default: no medial wall
	@warn "No medial wall information found in GIFTI file"
	return falses(n_vertices)
end

function shape_data(g::GiftiStruct, name::Union{Nothing, String} = nothing)
	shape_arrays = filter(arr -> is_shape_array(arr), g.arrays)
	
	if !isnothing(name)
		for arr in shape_arrays
			if arr.metadata.name == name
				return arr.data
			end
		end
		return nothing
	else
		return isempty(shape_arrays) ? nothing : first(shape_arrays).data
	end
end

function time_series(g::GiftiStruct)
	arr = g["NIFTI_INTENT_TIME_SERIES"]
	isnothing(arr) && return nothing
	return arr.data
end

function anatomical_structure(g::GiftiStruct)
	return get(g.global_metadata, "AnatomicalStructurePrimary", nothing)
end

function to_hemisphere(g::GiftiStruct, label::BrainStructure)
	# Get required components
	coords = coordinates(g) ./ 100.0f0  # Convert from mm to cm
	mw = medial_wall(g)
	tris = triangles(g; one_indexed = true)
	
	# Create hemisphere
	return Hemisphere(label, coords, mw; triangles = tris)
end

function find_arrays(g::GiftiStruct, predicate::Function)
	return filter(predicate, g.arrays)
end

function array_names(g::GiftiStruct)
	names = String[]
	for arr in g.arrays
		if !isnothing(arr.metadata.name)
			push!(names, arr.metadata.name)
		end
	end
	return names
end

function array_intents(g::GiftiStruct)
	return unique([arr.metadata.intent for arr in g.arrays])
end

has_coordinates(g::GiftiStruct) = !isnothing(g["NIFTI_INTENT_POINTSET"])

has_triangles(g::GiftiStruct) = !isnothing(g["NIFTI_INTENT_TRIANGLE"])

has_time_series(g::GiftiStruct) = !isnothing(g["NIFTI_INTENT_TIME_SERIES"])

function n_vertices(g::GiftiStruct)
	has_coordinates(g) && return size(coordinates(g), 2)
	isempty(g.arrays) && return 0
	# todo: maybe better to return 0 or ...?
	# try to infer from first 1d array
	for arr in g.arrays
		if ndims(arr.data) == 1
			return length(arr.data)
		end
	end
end

function n_triangles(g::GiftiStruct)
	has_triangles(g) && return size(triangles(g), 2)
	return 0
end



