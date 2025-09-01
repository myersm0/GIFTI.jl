module GIFTI

using LightXML
using CodecZlib: transcode, GzipDecompressor
using Base64
using GeometryBasics

include("gifti_spec.jl")

include("types.jl")
export GiftiStruct, GiftiDataArray

include("parsers.jl")

include("io.jl")

include("accessors.jl")
export arrays, data, metadata, intent, intents
export pointset, pointsets, triangle, triangles
export has_pointset, has_triangle, has_time_series, has_timeseries

include("conversion.jl")
export Mesh

include("show.jl")

end
