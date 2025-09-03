
# Standard NIFTI intent codes used in GIFTI
# Note: NODE_INDEX appears in spec but not in the DTD - it's used for sparse data storage
const gifti_intent_codes = Dict(
	"NIFTI_INTENT_NONE" => 0,
	"NIFTI_INTENT_CORREL" => 2,
	"NIFTI_INTENT_TTEST" => 3,
	"NIFTI_INTENT_FTEST" => 4,
	"NIFTI_INTENT_ZSCORE" => 5,
	"NIFTI_INTENT_CHISQ" => 6,
	"NIFTI_INTENT_BETA" => 7,
	"NIFTI_INTENT_BINOM" => 8,
	"NIFTI_INTENT_GAMMA" => 9,
	"NIFTI_INTENT_POISSON" => 10,
	"NIFTI_INTENT_NORMAL" => 11,
	"NIFTI_INTENT_FTEST_NONC" => 12,
	"NIFTI_INTENT_CHISQ_NONC" => 13,
	"NIFTI_INTENT_LOGISTIC" => 14,
	"NIFTI_INTENT_LAPLACE" => 15,
	"NIFTI_INTENT_UNIFORM" => 16,
	"NIFTI_INTENT_TTEST_NONC" => 17,
	"NIFTI_INTENT_WEIBULL" => 18,
	"NIFTI_INTENT_CHI" => 19,
	"NIFTI_INTENT_INVGAUSS" => 20,
	"NIFTI_INTENT_EXTVAL" => 21,
	"NIFTI_INTENT_PVAL" => 22,
	"NIFTI_INTENT_LOGPVAL" => 23,
	"NIFTI_INTENT_LOG10PVAL" => 24,
	"NIFTI_INTENT_ESTIMATE" => 1001,
	"NIFTI_INTENT_LABEL" => 1002,
	"NIFTI_INTENT_NEURONAME" => 1003,
	"NIFTI_INTENT_GENMATRIX" => 1004,
	"NIFTI_INTENT_SYMMATRIX" => 1005,
	"NIFTI_INTENT_DISPVECT" => 1006,
	"NIFTI_INTENT_VECTOR" => 1007,
	"NIFTI_INTENT_POINTSET" => 1008,
	"NIFTI_INTENT_TRIANGLE" => 1009,
	"NIFTI_INTENT_QUATERNION" => 1010,
	"NIFTI_INTENT_DIMLESS" => 1011,
	"NIFTI_INTENT_TIME_SERIES" => 2001,
	"NIFTI_INTENT_NODE_INDEX" => 2002,  # For sparse data storage
	"NIFTI_INTENT_RGB_VECTOR" => 2003,
	"NIFTI_INTENT_RGBA_VECTOR" => 2004,
	"NIFTI_INTENT_SHAPE" => 2005
)

const intent_code_to_string = Dict(v => k for (k, v) in gifti_intent_codes)

const anatomical_structure_primary = Dict(
	"CortexLeft" => "CORTEX_LEFT",
	"CortexRight" => "CORTEX_RIGHT",
	"CortexRightAndLeft" => "CORTEX",  # Note: spec uses "RightAndLeft"
	"CerebellumLeft" => "CEREBELLUM_LEFT", 
	"CerebellumRight" => "CEREBELLUM_RIGHT",
	"Cerebellum" => "CEREBELLUM",
	"Head" => "HEAD",
	"HippocampusLeft" => "HIPPOCAMPUS_LEFT",
	"HippocampusRight" => "HIPPOCAMPUS_RIGHT"
)

const anatomical_structure_secondary = Dict(
	"GrayWhite" => "The white/gray boundary",
	"Pial" => "The pial (gray/CSF) boundary",
	"MidThickness" => "Middle layer of cortex (layer 4)"
)

const topological_types = Dict(
	"Closed" => "A closed surface",
	"Open" => "Typically medial wall removed",
	"Cut" => "Cuts have been made for flattening"
)

const nifti_type_codes = Dict(
	"NIFTI_TYPE_UINT8" => 2,
	"NIFTI_TYPE_INT16" => 4,
	"NIFTI_TYPE_INT32" => 8,
	"NIFTI_TYPE_FLOAT32" => 16,
	"NIFTI_TYPE_COMPLEX64" => 32,
	"NIFTI_TYPE_FLOAT64" => 64,
	"NIFTI_TYPE_RGB24" => 128,
	"NIFTI_TYPE_INT8" => 256,
	"NIFTI_TYPE_UINT16" => 512,
	"NIFTI_TYPE_UINT32" => 768,
	"NIFTI_TYPE_INT64" => 1024,
	"NIFTI_TYPE_UINT64" => 1280
)

const nifti_to_julia_type = Dict(
	"NIFTI_TYPE_UINT8" => UInt8,
	"NIFTI_TYPE_INT8" => Int8,
	"NIFTI_TYPE_INT16" => Int16,
	"NIFTI_TYPE_UINT16" => UInt16,
	"NIFTI_TYPE_INT32" => Int32,
	"NIFTI_TYPE_UINT32" => UInt32,
	"NIFTI_TYPE_INT64" => Int64,
	"NIFTI_TYPE_UINT64" => UInt64,
	"NIFTI_TYPE_FLOAT32" => Float32,
	"NIFTI_TYPE_FLOAT64" => Float64
)

abstract type EncodingType end
struct ASCII <: EncodingType end
struct Base64Binary <: EncodingType end
struct GZipBase64Binary <: EncodingType end
struct ExternalFileBinary <: EncodingType end

const encoding_types = Dict(
	"ASCII" => ASCII(),
	"Base64Binary" => Base64Binary(),
	"GZipBase64Binary" => GZipBase64Binary(),
	"ExternalFileBinary" => ExternalFileBinary(),
)

const endian_types = ["BigEndian", "LittleEndian"]

const indexing_order = ["RowMajorOrder", "ColumnMajorOrder"]

const coordinate_systems = [
	"NIFTI_XFORM_UNKNOWN",
	"NIFTI_XFORM_SCANNER_ANAT",
	"NIFTI_XFORM_ALIGNED_ANAT",
	"NIFTI_XFORM_TALAIRACH",
	"NIFTI_XFORM_MNI_152"
]

const geometric_types = ["Anatomical", "Inflated", "Flat", "Hull", "Pial", "White"]

const file_extensions = Dict(
	"generic" => ".gii",
	"coordinate" => ".coord.gii",
	"functional" => ".func.gii",
	"label" => ".label.gii",
	"rgba" => ".rgba.gii",
	"shape" => ".shape.gii",
	"surface" => ".surf.gii",
	"tensor" => ".tensor.gii",
	"time_series" => ".time.gii",
	"topology" => ".topo.gii",
	"vector" => ".vector.gii"
)


## Functions to categorize intent

function is_spatial_intent(intent::String)
	return intent in [
		"NIFTI_INTENT_POINTSET",
		"NIFTI_INTENT_TRIANGLE", 
		"NIFTI_INTENT_VECTOR"
	]
end

function is_morphometry_intent(intent::String)
	return intent in [
		"NIFTI_INTENT_SHAPE",
		"NIFTI_INTENT_ESTIMATE",
		"NIFTI_INTENT_LABEL"
	]
end

function is_functional_intent(intent::String)
	return intent in [
		"NIFTI_INTENT_TIME_SERIES",
		"NIFTI_INTENT_CORREL",
		"NIFTI_INTENT_ZSCORE",
		"NIFTI_INTENT_TTEST",
		"NIFTI_INTENT_FTEST",
		"NIFTI_INTENT_BETA"
	]
end

function is_statistical_intent(intent::String)
	code = get(gifti_intent_codes, intent, 1000)
	return 2 <= code <= 24  # Statistical parameter range
end

