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
		@test metadata(g) isa Dict
		@test data(g) isa Vector{GiftiDataArray}
		@test data(g) == data(g, r".*")
		@test first(g) == g[1]
		@test last(g) == g[end]

		for (i, a) in enumerate(g)
			@test a == g[i]
			@test metadata(a) isa GIFTI.ArrayMetadata
			@test data(a) isa AbstractArray
			@test size(a) == size(data(a)) == Tuple(metadata(a).dimensions)
			@test intent(a) == intents(g)[i]
		end

		if has_pointset(g)
			a = pointset(g)
			@test intent(a) == "NIFTI_INTENT_POINTSET"
			@test size(a) == (32492, 3)
		end

		if has_triangle(g)
			a = triangle(g)
			@test intent(a) == "NIFTI_INTENT_TRIANGLE"
			@test size(a) == (32492 * 2 - 4, 3)
		end

		if has_pointset(g) && has_triangle(g)
			mesh = GeometryBasics.Mesh(g)
			@test mesh isa GeometryBasics.Mesh
		end

		if occursin(r".surf.gii$", file)
			@test length(pointsets(g)) > 0
			@test length(triangles(g)) > 0
		end

		if occursin(r".label.gii$", file)
			label_table = metadata(g)["label_table"]
			label_arrays = data(g, "NIFTI_INTENT_LABEL")
			dtype = metadata(label_arrays[1]).data_type
			@test label_table isa Dict{dtype, Tuple{String, Vector{Float32}}}
			for label_array in label_arrays
				array_vals = unique(data(label_array))
				@test all(v in keys(label_table) for v in array_vals)
			end
		end

	end

end
