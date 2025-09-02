using BenchmarkTools
using GIFTI
using Pkg.Artifacts
using LightXML

const SUITE = BenchmarkGroup()
SUITE["parsing"] = BenchmarkGroup()

const data_dir = artifact"msc_gifti_data_164k"
filelist = readdir(data_dir)
filename = joinpath(data_dir, filelist[3])

# parse once for component benchmarks
const doc = parse_file(filename)
const root_elem = root(doc)
const data_elements = get_elements_by_tagname(root_elem, "DataArray")
const first_data_elem = data_elements[1]

# Create metadata for parse_array_data benchmark
const test_metadata = let elem = first_data_elem
	intent = attribute(elem, "Intent")
	data_type = GIFTI.parse_data_type(attribute(elem, "DataType"))
	dimensions = GIFTI.parse_dimensions(elem)
	encoding = attribute(elem, "Encoding")
	endian = attribute(elem, "Endian")
	GIFTI.ArrayMetadata(
		nothing, data_type, intent, dimensions,
		encoding, endian, nothing, 0, nothing, Dict{String,String}()
	)
end

SUITE["parsing"]["full"] = BenchmarkGroup()
SUITE["parsing"]["components"] = BenchmarkGroup()
SUITE["parsing"]["metadata"] = BenchmarkGroup()

SUITE["parsing"]["full"]["load"] = @benchmarkable GIFTI.load($filename)
SUITE["parsing"]["full"]["parse_xml"] = @benchmarkable parse_file($filename)

SUITE["parsing"]["components"]["global_metadata"] = @benchmarkable GIFTI.parse_global_metadata($root_elem)
SUITE["parsing"]["components"]["data_array"] = @benchmarkable GIFTI.parse_data_array($first_data_elem)
SUITE["parsing"]["components"]["array_data"] = @benchmarkable GIFTI.parse_array_data($first_data_elem, $test_metadata)

SUITE["parsing"]["metadata"]["dimensions"] = @benchmarkable GIFTI.parse_dimensions($first_data_elem)
SUITE["parsing"]["metadata"]["coordinate_transform"] = @benchmarkable GIFTI.parse_coordinate_system_transform($first_data_elem)
SUITE["parsing"]["metadata"]["metadata_dict"] = @benchmarkable GIFTI.parse_metadata_dict($first_data_elem)
SUITE["parsing"]["metadata"]["data_type"] = @benchmarkable GIFTI.parse_data_type(attribute($first_data_elem, "DataType"))

SUITE["parsing"]["decoding"] = BenchmarkGroup()



