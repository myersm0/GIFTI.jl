using GIFTI
using Test
using Pkg.Artifacts
using GeometryBasics

data_dir = artifact"msc_gifti_data_32k"
filelist = readdir(data_dir)

@testset "GIFTI.jl" begin

	for file in filelist
		g = GIFTI.load("$data_dir/$file")
		@test g isa GiftiStruct
		for i in 1:length(g)
			a = g[i]
			@test data(a) isa AbstractArray
		end
		if has_pointset(g)
			@test size(pointset(g)) == (32492, 3)
		end
		if has_triangle(g)
			@test size(triangle(g)) == (32492 * 2 - 4, 3)
		end
		if has_pointset(g) && has_triangle(g)
			mesh = GeometryBasics.Mesh(g)
			@test mesh isa GeometryBasics.Mesh
		end
	end

end
