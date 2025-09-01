module GIFTI

using LightXML
using CodecZlib: transcode, GzipDecompressor
using Base64
import GeometryBasics.Mesh

include("gifti_spec.jl")
include("types.jl")
include("parsers.jl")
include("io.jl")
include("accessors.jl")
include("conversion.jl")
include("show.jl")

end
