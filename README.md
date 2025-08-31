# GIFTI

Just a mockup of a framework for working with GIFTI files, under development.

## TODO
- Factor out specification-related constants to a shared dependency package between this package and existing package CIFTI.jl (and maybe also NIfTI.jl)?
- need a `medial_wall` accessor function (medial wall def is not always present)
- need constructors for GeometryBasics.Mesh
- add a `save` function


## Usage
Supposing you have `filename` that's the path of a gifti file, load it in as follows:
```
using GIFTI
filename = "./HCPpipelines/global/templates/standard_mesh_atlases/colin.cerebral.L.flat.59k_fs_LR.surf.gii"
g = GIFTI.load(filename)
```

The resulting GiftiStruct `g` contains primarily two things:
- global metadata
- arrays in the form of `GiftiDataArray`s (each of which itself contains a `Matrix` and additional metadata).

The metadata of a GiftiStruct can be accessed simply with `metadata(g)`.

To query and access the data arrays in a GiftiStruct, several tools are available:

Get a vector the "intents" representing the arrays stored in g:
```
intents(g)  # returns something like ["NIFTI_INTENT_POINTSET", "NIFTI_INTENT_TRIANGLE"]
```

Get the 1st array contained in g, and get some information about it:
```
a = g[1]     # returns a GiftiDataArray
intent(a)    # "NIFTI_INTENT_POINTSET" in my example case
metadata(a)  # access various metadata key/value pairs about the array
size(a)      # (59292, 3) in my examle case
data(a)      # get the raw Array{T, N}
```

Get a vector of all arrays `a` in `g` having `intent(a) == "NIFTI_INTENT_POINTSET"`:
```
g["NIFTI_INTENT_POINTSET"]   # returns a Vector{GiftiDataArray}

# similarly for NIFTI_INTENT_TRIANGLES:
g["NIFTI_INTENT_TRIANGLES"]  # returns a Vector{GiftiDataArray}
```

Or, to conveniently get a _single_ array:
```
pointset(g)   # returns just the pointset AKA coordinates array
triangles(g)  # returns just the array of triangles AKA faces
```

The latter two accessors above will fail, however, in the event that there's not exactly one matching array existing in `g`. To robustly handle the case of multiple matching arrays (including none), you can use the plural form, for example:
```
pointsets(g)   # returns a (possibly empty) vector of all pointset arrays in g
```

(Note: this pluralization of the accessor unfortunately doesn't extend to `triangles`, since that word is already plural. I've never seen a GIFTI file that has multiple triangle arrays but it's possible based on the specs.)

```
[![Build Status](https://github.com/myersm0/GIFTI.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/myersm0/GIFTI.jl/actions/workflows/CI.yml?query=branch%3Amain)
