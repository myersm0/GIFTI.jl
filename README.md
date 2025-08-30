# GIFTI

Just a mockup of a framework for working with GIFTI files, under development.

## Usage
```julia
julia> using GIFTI
julia> filename = "./HCPpipelines/global/templates/standard_mesh_atlases/fs_L/fs_L-to-fs_LR_fsaverage.L_LR.spherical_std.164k_fs_L.surf.gii"
julia> test = GIFTI.load(filename)
GiftiStruct
  version:     1
  num arrays:  2
  source:      fs_L-to-fs_LR_fsaverage.L_LR.spherical_std.164k_fs_L.surf.gii
  arrays:
    [1] NIFTI_INTENT_POINTSET: [163842, 3] Float32
    [2] NIFTI_INTENT_TRIANGLE: [327680, 3] Int32


julia> test.arrays[1]
GiftiDataArray{Float32, 2}
  intent:     NIFTI_INTENT_POINTSET
  dimensions: (163842, 3)
  data type:  Float32


julia> test.arrays[2]
GiftiDataArray{Int32, 2}
  intent:     NIFTI_INTENT_TRIANGLE
  dimensions: (327680, 3)
  data type:  Int32
```
[![Build Status](https://github.com/myersm0/GIFTI.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/myersm0/GIFTI.jl/actions/workflows/CI.yml?query=branch%3Amain)
