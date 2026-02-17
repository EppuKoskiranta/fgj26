extends Node3D

class_name IngredientFloatingDisplay

@onready var display_mesh_container: Node3D = $DisplayMeshContainer
@export var ingredient_data: IngredientData
@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# For each different kind of lotion effect,
# this node will create a mesh instance

# If the ingredient_data hydration 1, cleansing 2,
# the node will create a hydration icon mesh and 2 cleansing 
# icon meshes

# When the player looks at this node, the icons pop up and become
# visible in the game world above the hovered ingredient

var is_showing_effects = false

func initialize() -> void:
	# Create mesh instances based on lotion effects
	var effects = ingredient_data.lotion_effects
	var values = effects.get_absolute_values()
	
	timer.timeout.connect(hide_effects)

	# For demonstration, let's assume we have a predefined icon mesh for each effect
	var icon_meshes = {
		"hydration": preload("res://Assets/Meshes/hydration_icon.tres"),
		"cleansing": preload("res://Assets/Meshes/cleansing_icon.tres"),
		"anti_aging": preload("res://Assets/Meshes/anti_aging_icon.tres"),
		"soothing_calming": preload("res://Assets/Meshes/soothing_calming_icon.tres"),
		"brightening": preload("res://Assets/Meshes/brightening_icon.tres")
	}
	
	# Create mesh instances based on the ratio of each effect
	var offset = Vector3(0, 0.4, 0) # Adjust as needed for spacing
	var offset_per_icon = Vector3(0.0, 0.1, 0) # Adjust as needed for spacing
	var icon_index = 0
	for effect_name in icon_meshes.keys():
		var count = values[effect_name]
		for i in range(count):
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.mesh = icon_meshes[effect_name]
			mesh_instance.position = offset + (offset_per_icon * icon_index)
			display_mesh_container.add_child(mesh_instance)
			icon_index += 1
	
	display_mesh_container.visible = false # Start hidden

func _process(_delta: float) -> void:
	# This should always be parallel to the camera, so we can do that here
	# It should ignore the parent node's rotation
	var camera = get_viewport().get_camera_3d()
	if camera:
		var to_camera = (camera.global_transform.origin - global_transform.origin).normalized()
		var up = Vector3.UP
		var right = to_camera.cross(up).normalized()
		up = right.cross(to_camera).normalized()
		var billboard_transform = Transform3D(right, up, to_camera, global_transform.origin)
		display_mesh_container.global_transform = billboard_transform
		display_mesh_container.global_scale(Vector3(0.5, 0.5, 0.5))

func start_show_effects():
	if not is_showing_effects:
		is_showing_effects = true
		display_mesh_container.visible = true

	timer.start()


func hide_effects():
	display_mesh_container.visible = false
	is_showing_effects = false
