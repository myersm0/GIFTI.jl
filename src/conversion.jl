
function GeometryBasics.Mesh(g::GiftiStruct)
	pointset_arrays = pointsets(g)
	triangle_arrays = triangles(g)
	length(pointset_arrays)  > 0 || error("Could not find any arrays with intent NIFTI_INTENT_POINTSET")
	length(triangle_arrays)  > 0 || error("Could not find any arrays with intent NIFTI_INTENT_TRIANGLE")
	length(pointset_arrays) == 1 || @warn "Found multiple pointset arrays, using only the first."
	length(triangle_arrays) == 1 || @warn "Found multiple triangle arrays, using only the first."

	vert_array = data(pointset_arrays[1])
	vertices = reshape(reinterpret(Point3f, vert_array'), (size(vert_array, 1),))
	face_array = data(triangle_arrays[1])
	faces = reinterpret(GLTriangleFace, vec(face_array'))
	return GeometryBasics.Mesh(vertices, faces)
end




