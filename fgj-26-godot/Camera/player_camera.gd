extends Camera3D
class_name PlayerCamera

@export var tracking_time_constant: float = 25.0

var default_attachment : CameraDockingStation = null
var current_attachment : CameraDockingStation = null

func _ready() -> void:
	set_process(false)
	set_physics_process(true)

func init(player_camera_attachment : CameraDockingStation) -> void:
	default_attachment = player_camera_attachment
	current_attachment = default_attachment

func _physics_process(delta: float) -> void:
	assert(null != default_attachment, "Forgot to call init!")
	if null == current_attachment :
		current_attachment = default_attachment
	
	var tracking_weight: float = (1.0 - exp(-tracking_time_constant*delta))
	global_transform = global_transform.interpolate_with( \
		current_attachment.global_transform, tracking_weight)

func attach_to(viewpoint : CameraDockingStation) -> void:
	current_attachment = viewpoint

func detach_from_viewpoint() -> void:
	current_attachment = default_attachment
