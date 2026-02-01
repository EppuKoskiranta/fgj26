extends CharacterBody3D
class_name Player

@onready var fps_view: CameraDockingStation = %FPSView

@onready var speed: float = 10.0
@onready var look_deg_limits: Vector2 = Vector2(-60.0, 45.0)

var move_dir: Vector2 = Vector2(0.0, 0.0)
var turn_speed_deg_per_sec: float = 0.0
var look_speed_deg_per_sec: float = 0.0
var look_angle_deg: float = 0.0

var lotion_object : LotionObject

var item_in_hand : Node3D = null

func _ready() -> void:
	Def.subscribe_to_movement(self._move_player, self._turn_player, self._look_up_down)
	Def.subscribe_to_interaction(self.try_pick_up, Def.SUB_INTERACT_EVENT_ONLY)
	Def.subscribe_to_interaction(self.try_to_get_lotion, Def.SUB_INTERACT_EVENT_ONLY)
	Def.subscribe_to_pick_up(self._on_item_picked_up)

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_apply_turn_and_look(delta)
	_apply_movement()
	
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
func _apply_movement() -> void:
	var direction := (self.transform.basis * Vector3(move_dir.y, 0, move_dir.x)).normalized()
	velocity.x = move_toward(velocity.x, direction.x * speed, speed)
	velocity.z = move_toward(velocity.z, direction.z * speed, speed)
	
	move_and_slide()
	
func _apply_turn_and_look(delta: float) -> void:
	rotate_y(deg_to_rad(turn_speed_deg_per_sec * delta))
	
	look_angle_deg += look_speed_deg_per_sec * delta
	look_angle_deg = clampf(look_angle_deg, look_deg_limits.x, look_deg_limits.y)
	fps_view.rotation.x = deg_to_rad(look_angle_deg)
	
	turn_speed_deg_per_sec = 0.0
	look_speed_deg_per_sec = 0.0
	
func _move_player(new_move_dir: Vector2) -> void:
	move_dir = new_move_dir
	
func _turn_player(new_turn_speed_deg_per_sec: float) -> void:
	turn_speed_deg_per_sec = new_turn_speed_deg_per_sec
	
func _look_up_down(pitch_angle_deg_per_sec: float) -> void:
	look_speed_deg_per_sec = pitch_angle_deg_per_sec

func try_to_get_lotion() -> void:
	if lotion_object != null:
		return
	
	var ray_result: Dictionary = shoot_ray_from_camera(3.0)
	if ray_result and ray_result.collider is CollisionObject3D:
		var parent : Node = ray_result.collider.get_parent()
		if parent.is_in_group("lotion"):
			print("Picked up lotion? %s" % parent)
			lotion_object = parent as LotionObject
			if lotion_object.lotion_ready():
				lotion_object.position = Vector3.ZERO
				lotion_object.rotation = Vector3.ZERO
				lotion_object.get_parent().remove_child(lotion_object)
				$Hand.add_child(lotion_object)

func try_pick_up() -> void:
	if item_in_hand != null:
		print("Already holding an item.")
		return

	var ray_result: Dictionary = shoot_ray_from_camera(3.0)
	if ray_result and ray_result.collider is CollisionObject3D:
		var parent : Node = ray_result.collider.get_parent()
		if parent.is_in_group("pickable"):
			print("Picked up: %s" % parent)
			Def.report_pick_up(parent)

func shoot_ray_from_camera(ray_length: float = 100.0) -> Dictionary:
	var from: Vector3 = fps_view.global_transform.origin
	var to: Vector3 = from + fps_view.global_transform.basis.z * -ray_length
	var ray_params: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	ray_params.from = from
	ray_params.to = to
	ray_params.collide_with_areas = true
	ray_params.collide_with_bodies = true
	var result := get_world_3d().direct_space_state.intersect_ray(ray_params)
	return result

func _on_item_picked_up(object : Node) -> void:
	print("Player received item: ", object.name)
	# instanciate an item to the player's hand.
	var item_instance := object.duplicate() as Node3D
	item_instance.position = Vector3.ZERO
	item_instance.rotation = Vector3.ZERO
	item_in_hand = item_instance

	$Hand.add_child(item_in_hand)

func get_item_in_hand() -> Node3D:
	return item_in_hand

func remove_item_in_hand() -> void:
	if item_in_hand != null:
		item_in_hand.get_parent().remove_child(item_in_hand)
		item_in_hand = null	
