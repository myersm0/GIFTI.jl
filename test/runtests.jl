using GIFTI
using Test
using Pkg.Artifacts

data_dir = artifact"msc_gifti_data_32k"
filelist = readdir(data_dir)

@testset "GIFTI.jl" begin

	for file in filelist
		println(file)
		g = GIFTI.load("$data_dir/$file")
	end

end
