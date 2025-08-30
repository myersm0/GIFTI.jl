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

julia> coordinates(test)
3×163842 adjoint(::Matrix{Float32}) with eltype Float32:
 -54.0527   30.7757  42.6325  -38.9732  -99.2546  -61.8615    38.8346  99.4424   55.0349   …   55.5277   55.1896   54.8557   55.7784   55.1623   54.5361   54.2231   53.9161
 -13.9328  -72.5002  29.1233   82.3006   10.453   -78.4881   -82.2094  -8.91542  83.2639       18.7977   18.1182   17.4457   16.6001   16.683    16.765    16.0801   15.3976
  82.971    61.6164  85.6405   41.3244   -6.2655    3.57357  -41.6351   5.63162  -6.18806     -81.0143  -81.3992  -81.771   -81.3216  -81.7239  -82.1264  -82.4699  -82.8007

julia> triangles(test)
3×327680 Matrix{Int64}:
     1      1      1      1      1      4      4      4      5      5      6      6  …  163840  163840  163840  163841  163841   92161  163842  163842  163842  163114  163114
 40965  40963  40966  40968  40970  40975  40973  40976  40982  40980  40987  40985     163837    9919   89730   89730   39991  163841  163841   39991  160927  160927      12
 40963  40966  40968  40970  40965  40973  40976  40978  40980  40983  40985  40988     163839  163837    9919  163840   89730   40962   92161  163841   39991  163842  160927
```
[![Build Status](https://github.com/myersm0/GIFTI.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/myersm0/GIFTI.jl/actions/workflows/CI.yml?query=branch%3Amain)
