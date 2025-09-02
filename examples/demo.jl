using GIFTI
using Pkg.Artifacts
using GeometryBasics
using Colors

# demo files from the MSC dataset
data_dir = artifact"msc_gifti_data_32k"
filename = joinpath(data_dir, "MSC01.L.inflated.32k_fs_LR.surf.gii")
g = GIFTI.load(filename)

# global metadata about the file itself:
metadata(g)

# for each array in g, get the intent code that describes what it represents:
intents(g)

# get all the data arrays from g, in the form of a Vector{GiftiDataArray}:
data(g)

# alternatively, get only the first array:
my_array = g[1]
intent(my_array)  # "NIFTI_INTENT_POINTSET"

# ... or the last:
my_array = g[end]
intent(my_array)  # "NIFTI_INTENT_TRIANGLE"

# you can also get GiftiDataArrays by name or by regex;
# note that these each return a (possibly empty) vector of results:
possibly_many_arrays = data(g, "NIFTI_INTENT_POINTSET")
possibly_even_more_arrays = data(g, r"nifti_intent_"i)

# index into the GiftiDataArray, like you would do with a regular Array:
my_array[1:5, 1]

# alternatively, just get the raw data from the GiftiDataArray:
my_data = data(my_array)
my_data[1:5, 1]

# get metadata associated with a GiftiDataArray:
metadata(my_array)

# there is even an additional level of optional metadata
# in the form of arbitrary key-value pairs; for example,
# we may be able to extract the anatomical label and 
# the type of geometric space (e.g. "Inflated", "Spherical"):
optional_kv_pairs = metadata(metadata(my_array))
optional_kv_pairs["AnatomicalStructurePrimary"]  # "CortexLeft"
optional_kv_pairs["GeometricType"]               # "Inflated"

# if your gifti file has a pointset array and a triangle array,
# you can construct a GeometryBasics.Mesh from that:
if has_pointset(g) && has_triangle(g)
	mesh = GeometryBasics.Mesh(g)
end

# some gifti files may have label data describing colors for display:
filename = joinpath(data_dir, "MSC01.L.BA.32k_fs_LR.label.gii")
g = GIFTI.load(filename)
label_table = metadata(g)["label_table"]
label_array = data(g, "NIFTI_INTENT_LABEL")[1]
my_colors = [RGBA(label_table[x][2]...) for x in label_array]







