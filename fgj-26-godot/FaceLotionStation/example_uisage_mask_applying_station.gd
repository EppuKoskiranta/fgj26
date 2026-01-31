extends Camera3D

var mesh_rid : RID
#var triangle_mesh : TriangleMesh


@export var applier : FaceLotionApply

var timeout: float = 3
var timer : float = 0.0

func _ready() -> void:
	assert(applier)
	
func _unhandled_input(event: InputEvent) -> void:
	pass

func on_timeout():
	print(applier.getRatio())

func _process(delta: float) -> void:
	timer += delta
	if timer > timeout:
		on_timeout()
		timer = 0
	var hit = raycast_from_mouse()
	#print(result)
	if hit and hit.collider is FaceUVProvider:
		var face := hit.collider as FaceUVProvider
		if mesh_rid != hit.rid:
			applier.set_target(face.build_face_uv_mask(512))
			mesh_rid = hit.rid
		var uv := face.world_to_uv(hit.position)
		applier.apply_lotion(uv, 10, 1, delta)
	
	
func raycast_from_mouse(max_distance := 10_000.0) -> Dictionary:
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_origin := project_ray_origin(mouse_pos)
	var ray_direction := project_ray_normal(mouse_pos)
	var ray_end := ray_origin + ray_direction * max_distance
	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end
	)
	query.collide_with_areas = true
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	return result
