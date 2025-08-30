module GIFTI

using LightXML
using CodecZlib
using Base64
using CIFTI

include("gifti_spec.jl")
include("types.jl")
include("parsers.jl")
include("io.jl")
include("accessors.jl")

export GiftiStruct, GiftiDataArray, GiftiFormatError
export load, save

export coordinates, triangles, medial_wall
export shape_data, time_series, anatomical_structure
export to_hemisphere
export find_arrays, array_names, array_intents
export has_coordinates, has_triangles, has_time_series
export n_vertices, n_triangles
export is_sparse, node_indices

export is_coordinate_array, is_triangle_array, is_shape_array
export is_label_array, is_time_series_array

end
