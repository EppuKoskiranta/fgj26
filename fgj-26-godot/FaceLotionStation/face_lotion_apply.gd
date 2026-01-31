class_name FaceLotionApply
extends Node


@export var face_lotion_shader : ShaderMaterial
@export var face_image : CompressedTexture2D
@export var max_lotion_in_hand = 10.0
@export var lotion_color : Color
@export var docking_station : CameraDockingStation

var size := 512

var lotion_in_hand : float = 0
var lotion_amount : float = 0
var coverage_img: Image
var lotion_img : Image
var targetUv = Image


var coverage_texture: ImageTexture
var height_texture: ImageTexture
var face_texture : ImageTexture
var lotion_texture : ImageTexture

func _ready() -> void:
	# Create images
	coverage_img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	lotion_img   = Image.create(size, size, false, Image.FORMAT_RGBA8)
	

	lotion_img.fill(lotion_color)

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
	
func _application() -> void:
	print("Spread that shit all over")

func get_docking_station() -> CameraDockingStation:
	return docking_station

func getRatio() -> float:
	if targetUv:
		return _calculateRatio()
	else:
		return 0.0
	
func set_target(image : Image):
	targetUv = image

func add_lotion(amount : float, color : Color):
	lotion_amount = amount
	lotion_color = color
	
func _calculateRatio() -> float:
	var total : int = 0
	var covered : int = 0
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
	var lotion_to_add = max_lotion_in_hand - lotion_in_hand
	if lotion_to_add > lotion_amount:
		lotion_in_hand += lotion_amount
		lotion_amount = 0
		return
		
	lotion_in_hand += lotion_to_add
	lotion_amount -= lotion_to_add

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
