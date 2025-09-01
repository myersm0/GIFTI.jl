module GIFTI

using LightXML
using CodecZlib
using Base64

include("gifti_spec.jl")
include("types.jl")
include("parsers.jl")
include("io.jl")
include("accessors.jl")
include("conversion.jl")
include("show.jl")

end
