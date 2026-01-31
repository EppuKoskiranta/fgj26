extends Node
class_name InputHandler

@export var mouse_sensitivity : float = 1.0

const MOUSE_REL_TO_TURN_DEG_PER_SEC : float = 4.0
const MOUSE_REL_TO_LOOK_DEG_DELTA : float = 3.0
const TURN_MIN_DEG_PER_SEC : float = 5.0
const LOOK_MIN_DEG_PER_SEC : float = 5.0

var is_test : bool = false

func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	Def.subscribe_to_input_mapping_changed(self._input_handling_changed)
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("move_forward") or event.is_action_pressed("move_backward") \
		or event.is_action_pressed("move_left") or event.is_action_pressed("move_right") \
		or event.is_action_released("move_forward") or event.is_action_released("move_backward") \
		or event.is_action_released("move_left") or event.is_action_released("move_right"):
		if Def.INPUT_MAPPING_FPS_MOVEMENT == Def.game_input_state:
			var movement_vector : Vector2 = Vector2(
				Input.get_axis("move_forward", "move_backward"),
				Input.get_axis("move_left", "move_right")
			)
			Def.set_movement(movement_vector)
	elif event is InputEventMouseMotion:
		var relative_mouse_motion: Vector2 = event.relative
		if Def.INPUT_MAPPING_FPS_MOVEMENT == Def.game_input_state:
			relative_mouse_motion *= Vector2(MOUSE_REL_TO_TURN_DEG_PER_SEC, MOUSE_REL_TO_LOOK_DEG_DELTA) \
				* mouse_sensitivity
			Def.set_turn_speed(-relative_mouse_motion.x if absf(relative_mouse_motion.x) > TURN_MIN_DEG_PER_SEC else 0.0)
			Def.set_look_speed(-relative_mouse_motion.y if absf(relative_mouse_motion.y) > LOOK_MIN_DEG_PER_SEC else 0.0)
	elif event.is_action("interact"):
		match Def.game_input_state:
			Def.INPUT_MAPPING_START, Def.INPUT_MAPPING_MENU:
				pass
			Def.INPUT_MAPPING_MASK_LOTION_APPLY:
				if event.is_action_pressed("interact"):
					Def.start_spreading_lotion()
				elif event.is_action_released("interact"):
					Def.stop_spreading_lotion()
			_:
				Def.report_interact(null) # Only report the event
	elif event.is_action_released("open_menu"):
		if Def.INPUT_MAPPING_START != Def.game_input_state:
			Def.toggle_menu()
	elif event.is_action_released("back"):
		match Def.game_input_state:
			Def.INPUT_MAPPING_CONVERSATION, Def.INPUT_MAPPING_LOTION_MIXING, Def.INPUT_MAPPING_MASK_LOTION_APPLY:
				Def.go_back()
		
	if not is_test:
		get_tree().root.set_input_as_handled()

func _input_handling_changed(new_mapping : Def.GameInputState, _previous_mapping : Def.GameInputState) -> void:
	if Def.INPUT_MAPPING_FPS_MOVEMENT == new_mapping:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
