extends CharacterBody3D
class_name Player

@onready var fps_view: CameraDockingStation = %FPSView

@onready var speed : float = 10.0
@onready var look_deg_limits : Vector2 = Vector2(-60.0, 45.0)

var move_dir : Vector2 = Vector2(0.0, 0.0)
var turn_speed_deg_per_sec : float = 0.0
var look_speed_deg_per_sec : float = 0.0
var look_angle_deg : float = 0.0

func _ready() -> void:
	Def.subscribe_to_movement(self._move_player, self._turn_player, self._look_up_down)

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_apply_turn_and_look(delta)
	_apply_movement()
	
func _apply_gravity(delta: float) -> void :
	if not is_on_floor():
		velocity += get_gravity() * delta
		
func _apply_movement() -> void :
	
	var direction := (self.transform.basis * Vector3(move_dir.y, 0, move_dir.x)).normalized()
	velocity.x = move_toward(velocity.x, direction.x * speed, speed)
	velocity.z = move_toward(velocity.z, direction.z * speed, speed)
	
	move_and_slide()
	
func _apply_turn_and_look(delta: float) -> void :
	rotate_y(deg_to_rad(turn_speed_deg_per_sec*delta))
	
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
