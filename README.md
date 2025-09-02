# GIFTI

Just a mockup of a framework for working with GIFTI files, under development.

## TODO
- Factor out specification-related constants to a shared dependency package between this package and existing package CIFTI.jl (and maybe also NIfTI.jl)?
- add a `save` function
- should be able to index into a GiftiDataArray with square brackets


## Usage
Supposing you have `filename` that's the path of a gifti file, load it in as follows:
```
using GIFTI
g = GIFTI.load(filename)
```

The resulting GiftiStruct `g` contains primarily two things:
- metadata
- some number of `GiftiDataArray`s (each of which itself contains an `Array` and additional metadata)

To access these components:
```
metadata(g)  # returns a Dict of key, value pairs
data(g)      # returns a Vector of `GiftiDataArray`s
```

To query and access the data arrays in a GiftiStruct, several tools are available:

Get a vector the "intents" representing the arrays stored in g:
```
intents(g)  # returns something like ["NIFTI_INTENT_POINTSET", "NIFTI_INTENT_TRIANGLE"]
```

Square bracket indexing is available for accessing the arrays by number. For example, to get the first array contained in g:
```
a = g[1]     # returns a GiftiDataArray
intent(a)    # "NIFTI_INTENT_POINTSET" in my example case
metadata(a)  # access various metadata key/value pairs about the array
size(a)      # (59292, 3) in my example case
data(a)      # get the raw Array{T, N}
```

Get a vector of all arrays `a` in `g` having `intent(a) == "NIFTI_INTENT_POINTSET"`:
```
data(g, "NIFTI_INTENT_POINTSET")   # returns a Vector{GiftiDataArray}

# similarly for NIFTI_INTENT_TRIANGLES:
data(g, "NIFTI_INTENT_TRIANGLES")  # returns a Vector{GiftiDataArray}

# a regex also works (may match multiple intents):
data(g, r"nifti_intent_"i)
```

Or, to conveniently get a _single_ array:
```
pointset(g)  # returns just the pointset array (AKA coordinates)
triangle(g)  # returns just the triangle array (AKA faces)
```

The latter two accessors above will fail, however, in the event that there's not exactly one matching array existing in `g`. To robustly handle the case of multiple matching arrays (or none), you can use the plural forms, for example:
```
pointsets(g)   # returns a (possibly empty) vector of all pointset arrays in g
triangles(g)   # returns a (possibly empty) vector of all triangle arrays in g
```

The singular and plural syntaxes just shown may be a little confusing at first glance. But the following semantics motivating their design should help. For the singular case, when you use `pointset(g)`, you're saying, "get _the_ pointset array from `g`." Or equivalently, `triangle(g)` should be taken to mean "get _the_ triangle array from `g`". Such an array is expected to exist, and only one of them; otherwise you get an error. For the plural case on the other hand, `pointsets(g)` means "get _all_ pointset arrays from `g`", and equivalently for `triangles(g)`. If it happens that none such arrays exist in `g`, you'll just get an empty vector.

## Acknowledgments
For testing and demonstration purposes, this package uses surface data from the MSC dataset (described in [Gordon et al 2017](https://www.cell.com/neuron/fulltext/S0896-6273(17)30613-X)). This data was obtained from the OpenfMRI database. Its accession number is ds000224. 

[![Build Status](https://github.com/myersm0/GIFTI.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/myersm0/GIFTI.jl/actions/workflows/CI.yml?query=branch%3Amain)
