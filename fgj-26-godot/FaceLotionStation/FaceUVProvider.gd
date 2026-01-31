extends Area3D
class_name FaceUVProvider

@export var mesh_instance: MeshInstance3D

var triangle_mesh: TriangleMesh
var mdt: MeshDataTool


func _ready() -> void:
	assert(mesh_instance)
	
	# Triangle mesh for ray testing
	triangle_mesh = mesh_instance.mesh.generate_triangle_mesh()

	# Mesh data for UV lookup
	mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh_instance.mesh, 0)
	
func build_face_uv_mask(
	size: int
) -> Image:
	var mask_img := Image.create(size, size, false, Image.FORMAT_RF)
	mask_img.fill(Color(0, 0, 0))

	var mesh := mesh_instance.mesh
	assert(mesh)

	var mdt := MeshDataTool.new()
	mdt.create_from_surface(mesh, 0) # surface 0

	for face in range(mdt.get_face_count()):
		# Get vertex indices
		var i0 := mdt.get_face_vertex(face, 0)
		var i1 := mdt.get_face_vertex(face, 1)
		var i2 := mdt.get_face_vertex(face, 2)

		# Get UVs (0–1)
		var uv0 := mdt.get_vertex_uv(i0)
		var uv1 := mdt.get_vertex_uv(i1)
		var uv2 := mdt.get_vertex_uv(i2)

		# Convert UVs → pixel space
		var p0 := uv0 * size
		var p1 := uv1 * size
		var p2 := uv2 * size

		# Rasterize triangle
		_rasterize_uv_triangle(mask_img, p0, p1, p2)

	mdt.clear()
	mask_img.save_png("res://face_mask_debug.png")
	return mask_img

func _rasterize_uv_triangle(
	img: Image,
	p0: Vector2,
	p1: Vector2,
	p2: Vector2
) -> void:
	var min_x := int(floor(min(p0.x, p1.x, p2.x)))
	var max_x := int(ceil (max(p0.x, p1.x, p2.x)))
	var min_y := int(floor(min(p0.y, p1.y, p2.y)))
	var max_y := int(ceil (max(p0.y, p1.y, p2.y)))

	min_x = clamp(min_x, 0, img.get_width()  - 1)
	max_x = clamp(max_x, 0, img.get_width()  - 1)
	min_y = clamp(min_y, 0, img.get_height() - 1)
	max_y = clamp(max_y, 0, img.get_height() - 1)

	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var p := Vector2(x + 0.5, y + 0.5)
			if _point_in_triangle(p, p0, p1, p2):
				img.set_pixel(x, y, Color(1.0, 0, 0))
				
func _point_in_triangle(p: Vector2, a: Vector2, b: Vector2, c: Vector2) -> bool:
	var v0 := c - a
	var v1 := b - a
	var v2 := p - a

	var dot00 := v0.dot(v0)
	var dot01 := v0.dot(v1)
	var dot02 := v0.dot(v2)
	var dot11 := v1.dot(v1)
	var dot12 := v1.dot(v2)

	var inv_denom := 1.0 / (dot00 * dot11 - dot01 * dot01)
	var u := (dot11 * dot02 - dot01 * dot12) * inv_denom
	var v := (dot00 * dot12 - dot01 * dot02) * inv_denom

	return u >= 0.0 and v >= 0.0 and (u + v) <= 1.0
	
func world_to_uv(world_pos: Vector3) -> Vector2:
	# Convert world position to mesh local space
	var inv_transform = mesh_instance.global_transform.affine_inverse()
	var local_pos = inv_transform * world_pos

	# Cast a tiny ray along the normal direction
	var ray_from = local_pos + Vector3.UP * 0.001
	var ray_to   = local_pos - Vector3.UP * 0.001

	var hit = triangle_mesh.intersect_ray(ray_from, ray_to)
	if not hit:
		return Vector2.ZERO

	var face : int = hit.face_index
	if face < 0:
		return Vector2.ZERO

	# Triangle vertices
	var i0 = mdt.get_face_vertex(face, 0)
	var i1 = mdt.get_face_vertex(face, 1)
	var i2 = mdt.get_face_vertex(face, 2)

	var v0 = mdt.get_vertex(i0)
	var v1 = mdt.get_vertex(i1)
	var v2 = mdt.get_vertex(i2)

	# Barycentric coordinates
	var bary = Geometry3D.get_triangle_barycentric_coords(local_pos, v0, v1, v2)

	# UV interpolation
	var uv0 = mdt.get_vertex_uv(i0)
	var uv1 = mdt.get_vertex_uv(i1)
	var uv2 = mdt.get_vertex_uv(i2)

	return uv0 * bary.x + uv1 * bary.y + uv2 * bary.z
