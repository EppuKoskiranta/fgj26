class_name CollisionMeshData
var vertices: PackedVector3Array = []
var uvs: Array = []  # Array of Array[Vector2] (3 per triangle)

func build_from_mesh(mesh: Mesh):
	for surface_idx in mesh.get_surface_count():
		var arrays := mesh.surface_get_arrays(surface_idx)

		var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var tex_uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
		var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]

		if verts.is_empty():
			continue

		# Case 1: Indexed mesh (most imported meshes)
		if not indices.is_empty():
			for i in range(0, indices.size(), 3):
				var i0 := indices[i]
				var i1 := indices[i + 1]
				var i2 := indices[i + 2]

				vertices.append(verts[i0])
				vertices.append(verts[i1])
				vertices.append(verts[i2])

				uvs.append([
					tex_uvs[i0],
					tex_uvs[i1],
					tex_uvs[i2],
				])

		# Case 2: Already deindexed
		else:
			for i in range(0, verts.size(), 3):
				vertices.append(verts[i])
				vertices.append(verts[i + 1])
				vertices.append(verts[i + 2])

				uvs.append([
					tex_uvs[i],
					tex_uvs[i + 1],
					tex_uvs[i + 2],
				])
