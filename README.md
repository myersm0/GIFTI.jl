# GIFTI

Just a mockup of a framework for working with GIFTI files, under development.

## TODO
- Factor out specification-related constants to a shared dependency package between this package and existing package CIFTI.jl (and maybe also NIfTI.jl)?
- I'm not sure that we need GiftiDataArray to store the data components of a GiftiStruct; why not simly use a Matrix?
- I think the arrays should not be transposed, they should reflect the data ordering on disk
- I favor using `data` instead of `arrays` as the accessor and property name
- `medial_wall` function is bad, needs to be totally reworked
- need to support easier-to-read- and easier-to-type alternatives, such as `pointset` instead of "NIFTI_INTENT_POINTSET" etc
- need constructors for GeometryBasics.Mesh
- add a `save` function


## Usage
```julia
julia> using GIFTI
julia> filename = "./HCPpipelines/global/templates/standard_mesh_atlases/colin.cerebral.L.flat.59k_fs_LR.surf.gii"
julia> test = GIFTI.load(filename)
GiftiStruct
  version:     1
  num arrays:  2
  source:      colin.cerebral.L.flat.59k_fs_LR.surf.gii
  arrays:
    [1] NIFTI_INTENT_POINTSET: [59292, 3] Float32
    [2] NIFTI_INTENT_TRIANGLE: [107792, 3] Int32


julia> intents(test)
2-element Vector{String}:
 "NIFTI_INTENT_POINTSET"
 "NIFTI_INTENT_TRIANGLE"


julia> test["NIFTI_INTENT_POINTSET"]
GiftiDataArray{Float32, 2}
  intent:     NIFTI_INTENT_POINTSET
  dimensions: (59292, 3)
  data type:  Float32


julia> test["NIFTI_INTENT_TRIANGLE"]
GiftiDataArray{Int32, 2}
  intent:     NIFTI_INTENT_TRIANGLE
  dimensions: (107792, 3)
  data type:  Int32


julia> coordinates(test)
3×59292 adjoint(::Matrix{Float32}) with eltype Float32:
 134.377   59.6532  -5.30742  -60.2108  166.427   76.1341  …  113.921   113.104   115.412   114.538   115.918
 169.593  123.086   44.7124   108.924    76.0323  43.3052     -28.3706  -28.0343  -26.9869  -26.7919  -25.5343
   0.0      0.0      0.0        0.0       0.0      0.0          0.0       0.0       0.0       0.0       0.0

julia> triangles(test)
3×107792 Matrix{Int64}:
 13   13   14   14   15   15   16   16   17   17   18  …  59290  59291  59291  15253  59292  59292  15252  15251
  1   89   13  241   14  242   15  243   16  244   17     38964  59290  59292  59291  38964  38963  59292  38963
 89  241  241  242  242  243  243  244  244  245  245     59292  59292  15252  15252  38963  15251  15251     10

```
[![Build Status](https://github.com/myersm0/GIFTI.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/myersm0/GIFTI.jl/actions/workflows/CI.yml?query=branch%3Amain)
