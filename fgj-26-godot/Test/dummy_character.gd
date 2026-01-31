extends CharacterBody3D

@onready var camera_attachment: CameraDockingStation = %CameraAttachment
@onready var fps_view: CameraDockingStation = %FPSView

@onready var speed : float = 5.0
@onready var look_deg_limits : Vector2 = Vector2(-75.0, 45.0)

var move_dir : Vector2 = Vector2(0.0, 0.0)
var turn_speed_deg_per_sec : float = 0.0
var look_speed_deg_per_sec : float = 0.0
var look_angle_deg : float = 0.0

func _ready() -> void:
	Def.subscribe_to_movement(self._move_player, self._turn_player, self._look_up_down)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	rotate_y(deg_to_rad(turn_speed_deg_per_sec*delta))

	var direction := (transform.basis * Vector3(move_dir.y, 0, move_dir.x)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	
	look_angle_deg += look_speed_deg_per_sec*delta
	look_angle_deg = clampf(look_angle_deg, look_deg_limits.x, look_deg_limits.y)
	fps_view.rotation.x = deg_to_rad(look_angle_deg)
	
	turn_speed_deg_per_sec = 0.0
	look_speed_deg_per_sec = 0.0
	
func _move_player(new_move_dir : Vector2) -> void:
	move_dir = new_move_dir
	
func _turn_player(new_turn_speed_deg_per_sec : float) -> void:
	turn_speed_deg_per_sec = new_turn_speed_deg_per_sec
	
func _look_up_down(pitch_angle_deg_per_sec : float) -> void:
	look_speed_deg_per_sec = pitch_angle_deg_per_sec
