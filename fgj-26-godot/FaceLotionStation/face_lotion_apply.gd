class_name FaceLotionApply
extends Node

#var lotion_scene = preload("res://LotionObject/lotion_object_scene.tscn")

@export var face_lotion_shader : ShaderMaterial
@export var face_image : CompressedTexture2D
@export var max_lotion_in_hand = 10.0
@export var lotion_color : Color
@onready var docking_station: CameraDockingStation = %CameraDockingStation
@export var game_manager : GameManager
@onready var lotion_pos : Node3D = $Table/LotionPosition

@onready var lotion_table := $Table as MeshInstance3D


var size := 512

var lotion_in_hand : float = 0
var coverage_img: Image
var lotion_img : Image
var targetUv = Image
var mesh_rid : RID

var lotion_object : LotionObject

var coverage_texture: ImageTexture
var height_texture: ImageTexture
var face_texture : ImageTexture
var lotion_texture : ImageTexture

func _ready() -> void:
	
	#HOW to use
	#var instance = lotion_scene.instantiate()
	#var effects := LotionEffects.new()
	#var color := Color.DARK_GREEN
	#var amount := 100.0
	#add_child(instance)
	#var lotion = (instance as LotionObject)
	#lotion.initialize(effects, amount, color)
	#lotion.global_position = lotion_pos.global_position
	#HOW to use end
	#assert(game_manager)
	# Create images
	game_manager = Def.get_game_manager() as GameManager
	coverage_img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	lotion_img   = Image.create(size, size, false, Image.FORMAT_RGBA8)

	# Create textures from images
	coverage_texture = ImageTexture.create_from_image(coverage_img)
	lotion_texture = ImageTexture.create_from_image(lotion_img)
	face_texture = ImageTexture.create_from_image(Image.load_from_file("res://Assets/Textures/face_texture.png"))

	# Assign textures to shader ONCE
	face_lotion_shader.set_shader_parameter("coverage_mask", coverage_texture)
	face_lotion_shader.set_shader_parameter("height_mask", height_texture)
	face_lotion_shader.set_shader_parameter("skin_tex", face_texture)
	face_lotion_shader.set_shader_parameter("lotion_tex", lotion_texture)
	
	Def.subscribe_to_lotion_application(_application)
	Def.subscribe_to_interaction(_table_interaction)

	#DEBUG
	#var lotion : LotionObject = LotionObject.new(1, 1, 1 ,1, 1)
	#add_lotion(lotion)
	#add_lotion_to_hand()
	
func _application(delta_time : float) -> void:
	#print("Spread that shit all over")
	handle_station_input(game_manager.get_camera(), delta_time)

func get_docking_station() -> CameraDockingStation:
	return docking_station

func get_covered_ratio() -> float:
	if targetUv:
		return _calculateRatio()
	else:
		return 0.0
		
func get_location_ratio() -> Array:
	if lotion_object:
		return lotion_object.lotion_effects.get_ratio()
	
	return [0.0,0.0,0.0,0.0,0.0]
	
func set_target(image : Image):
	targetUv = image

func _table_interaction(object : Node):
	if object == lotion_table:
		var player = Def.get_player() as Player
		if player.lotion_object == null:
			print("Player doesn't have lotion")
			return
		add_lotion(player.lotion_object)
		player.lotion_object = null

func add_lotion(lotion_object : LotionObject):
	print("Adding lotion to the lotionStation")
	self.lotion_object = lotion_object
	lotion_object.get_parent().remove_child(lotion_object)
	lotion_table.add_child(lotion_object)
	lotion_img.fill(lotion_object.color)
	lotion_object.global_position = lotion_pos.global_position
	lotion_object.print_lotion_info()
	
func _calculateRatio() -> float:
	var total : int = 0
	var covered : int = 0
	if targetUv is Image and targetUv != null:
		for x in range(size):
			for y in range(size):	
				#check if targetUV.r value is set
				if targetUv.get_pixel(x, y).r > 0:
					total += 1
					if coverage_img.get_pixel(x, y).r > 0:
						covered += 1
	if total == 0:
		return 0.0
	return float(covered) / float(total)

func uv_to_pixel(uv : Vector2) -> Vector2i:
	uv.x = clampf(uv.x, 0.0, 1.0)
	uv.y = clampf(uv.y, 0.0, 1.0)
	
	var x = floori(uv.x * size)
	var y = floori(uv.y * size)
	return Vector2i(x, y)


func add_lotion_to_hand():
	#potential amount to add
	if lotion_in_hand > 9.5:
		return
	var lotion_to_add = max(max_lotion_in_hand - lotion_in_hand, 0)
	lotion_in_hand = lotion_object.get_lotion(lotion_to_add)

func apply_lotion(uv : Vector2, radius_px: int, strength : float, delta_time : float) -> void:
	if lotion_in_hand > 0:
		_apply_lotion(uv_to_pixel(uv), radius_px, strength)
		lotion_in_hand -= strength * delta_time

func _apply_lotion(pixel: Vector2i, radius_px: int, strength := 1.0) -> void:
	var img_size := coverage_img.get_size()
	
	for x in range(-radius_px, radius_px):
		for y in range(-radius_px, radius_px):
	
			var px = pixel.x + x
			var py = pixel.y + y

	#get pixel around the radius
	# Bounds check
			if px < 0 or py < 0:
				continue
			if px >= img_size.x or py >= img_size.y:
				continue	
			
			# Distance from brush center
			var dist_sq := x * x + y * y
			if dist_sq > radius_px * radius_px:
				continue

			var dist := sqrt(dist_sq)
			var d : float = 1.0 - dist / radius_px
			var falloff := clampf(d, 0.0, 1.0)
			
					# Coverage
			var c := coverage_img.get_pixel(px, py).r
			coverage_img.set_pixel(
				px,
				py,
				Color(minf(c + falloff, 1.0), 0, 0, .0)
			)

	

	# 🔑 Push changes to GPU
	coverage_texture.update(coverage_img)
	
func handle_station_input(camera : Camera3D, delta_time : float) -> void:
	if lotion_object:
		var hit = raycast_from_mouse(camera)
		if hit and hit.collider is FaceUVProvider:
			var face := hit.collider as FaceUVProvider
			if mesh_rid != hit.rid:
				set_target(face.build_face_uv_mask(512))
				mesh_rid = hit.rid
			var uv := face.world_to_uv(hit.position)
			apply_lotion(uv, 10, 1, delta_time)
		if hit and hit.collider.get_parent() is LotionObject:
			add_lotion_to_hand()
	else:
		print("NO LOTION")
	

func raycast_from_mouse(camera : Camera3D) -> Dictionary:
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_direction := camera.project_ray_normal(mouse_pos)
	var ray_end := ray_origin + ray_direction * 100
	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end
	)
	query.collide_with_areas = true
	var result := camera.get_world_3d().direct_space_state.intersect_ray(query)
	return result
