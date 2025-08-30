# if we factor our BrainStructure etc to a shared dependency pkg
# called CiftiGiftiSpecs or similar, this is what it could look like:

module CiftiGiftiCore

export BrainStructure, L, R, LR
export NiftiIntent, NiftiDataType
export intent_from_string, intent_to_string
export datatype_from_code, datatype_from_string

# Brain structures enum
@enum BrainStructure begin
    CORTEX_LEFT
    CORTEX_RIGHT
    ACCUMBENS_LEFT
    ACCUMBENS_RIGHT
    AMYGDALA_LEFT
    AMYGDALA_RIGHT
    BRAIN_STEM
    CAUDATE_LEFT
    CAUDATE_RIGHT
    CEREBELLUM_LEFT
    CEREBELLUM_RIGHT
    DIENCEPHALON_VENTRAL_LEFT
    DIENCEPHALON_VENTRAL_RIGHT
    HIPPOCAMPUS_LEFT
    HIPPOCAMPUS_RIGHT
    PALLIDUM_LEFT
    PALLIDUM_RIGHT
    PUTAMEN_LEFT
    PUTAMEN_RIGHT
    THALAMUS_LEFT
    THALAMUS_RIGHT
    CORTEX
    CEREBELLUM
    ALL_WHITE_MATTER
    ALL_GREY_MATTER
    OTHER
end

const L = CORTEX_LEFT
const R = CORTEX_RIGHT
const LR = [L, R]

# NIFTI data types enum
@enum NiftiDataType::Int16 begin
    NIFTI_TYPE_BOOL = 1
    NIFTI_TYPE_UINT8 = 2
    NIFTI_TYPE_INT16 = 4
    NIFTI_TYPE_INT32 = 8
    NIFTI_TYPE_FLOAT32 = 16
    NIFTI_TYPE_COMPLEX64 = 32
    NIFTI_TYPE_FLOAT64 = 64
    NIFTI_TYPE_RGB24 = 128
    NIFTI_TYPE_INT8 = 256
    NIFTI_TYPE_UINT16 = 512
    NIFTI_TYPE_UINT32 = 768
    NIFTI_TYPE_INT64 = 1024
    NIFTI_TYPE_UINT64 = 1280
end

# NIFTI intent codes enum
@enum NiftiIntent::Int16 begin
    NIFTI_INTENT_NONE = 0
    NIFTI_INTENT_CORREL = 2
    NIFTI_INTENT_TTEST = 3
    NIFTI_INTENT_FTEST = 4
    NIFTI_INTENT_ZSCORE = 5
    NIFTI_INTENT_CHISQ = 6
    NIFTI_INTENT_BETA = 7
    NIFTI_INTENT_BINOM = 8
    NIFTI_INTENT_GAMMA = 9
    NIFTI_INTENT_POISSON = 10
    NIFTI_INTENT_NORMAL = 11
    NIFTI_INTENT_FTEST_NONC = 12
    NIFTI_INTENT_CHISQ_NONC = 13
    NIFTI_INTENT_LOGISTIC = 14
    NIFTI_INTENT_LAPLACE = 15
    NIFTI_INTENT_UNIFORM = 16
    NIFTI_INTENT_TTEST_NONC = 17
    NIFTI_INTENT_WEIBULL = 18
    NIFTI_INTENT_CHI = 19
    NIFTI_INTENT_INVGAUSS = 20
    NIFTI_INTENT_EXTVAL = 21
    NIFTI_INTENT_PVAL = 22
    NIFTI_INTENT_LOGPVAL = 23
    NIFTI_INTENT_LOG10PVAL = 24
    NIFTI_INTENT_ESTIMATE = 1001
    NIFTI_INTENT_LABEL = 1002
    NIFTI_INTENT_NEURONAME = 1003
    NIFTI_INTENT_GENMATRIX = 1004
    NIFTI_INTENT_SYMMATRIX = 1005
    NIFTI_INTENT_DISPVECT = 1006
    NIFTI_INTENT_VECTOR = 1007
    NIFTI_INTENT_POINTSET = 1008
    NIFTI_INTENT_TRIANGLE = 1009
    NIFTI_INTENT_QUATERNION = 1010
    NIFTI_INTENT_DIMLESS = 1011
    NIFTI_INTENT_TIME_SERIES = 2001
    NIFTI_INTENT_NODE_INDEX = 2002
    NIFTI_INTENT_RGB_VECTOR = 2003
    NIFTI_INTENT_RGBA_VECTOR = 2004
    NIFTI_INTENT_SHAPE = 2005
end

# Mappings for data types
const datatype_to_julia = Dict{NiftiDataType, DataType}(
    NIFTI_TYPE_BOOL => Bool,
    NIFTI_TYPE_UINT8 => UInt8,
    NIFTI_TYPE_INT8 => Int8,
    NIFTI_TYPE_INT16 => Int16,
    NIFTI_TYPE_UINT16 => UInt16,
    NIFTI_TYPE_INT32 => Int32,
    NIFTI_TYPE_UINT32 => UInt32,
    NIFTI_TYPE_INT64 => Int64,
    NIFTI_TYPE_UINT64 => UInt64,
    NIFTI_TYPE_FLOAT32 => Float32,
    NIFTI_TYPE_FLOAT64 => Float64
)

# String mappings for GIFTI compatibility
const intent_string_map = Dict{String, NiftiIntent}(
    string(intent) => intent for intent in instances(NiftiIntent)
)

const datatype_string_map = Dict{String, NiftiDataType}(
    string(dtype) => dtype for dtype in instances(NiftiDataType)
)

# Helper functions
function intent_from_string(s::String)
    get(intent_string_map, s, NIFTI_INTENT_NONE)
end

function intent_to_string(intent::NiftiIntent)
    string(intent)
end

function datatype_from_code(code::Integer)
    NiftiDataType(code)
end

function datatype_from_string(s::String)
    get(datatype_string_map, s) do
        error("Unknown data type: $s")
    end
end

function julia_type(dtype::NiftiDataType)
    datatype_to_julia[dtype]
end

# Structure name mappings for GIFTI
const gifti_structure_names = Dict{String, BrainStructure}(
    "CortexLeft" => CORTEX_LEFT,
    "CortexRight" => CORTEX_RIGHT,
    "CortexRightAndLeft" => CORTEX,
    "CerebellumLeft" => CEREBELLUM_LEFT,
    "CerebellumRight" => CEREBELLUM_RIGHT,
    "Cerebellum" => CEREBELLUM
)

function structure_from_gifti_name(name::String)
    get(gifti_structure_names, name, OTHER)
end

end # module
