extends Node

# Add global signals here
signal input_mapping_changed(new_state : GameInputState)
signal move_player(move_dir : Vector2)
signal turn_player(turn_left_deg_per_sec : float)
signal look_up_down(pitch_angle_deg_per_sec : float)
signal interact()
signal menu_toggled()
signal back_to_previous()

# Add global enums here
enum GameInputState {MENU, FPS_MOVEMENT, CONVERSATION, LOTION_MIXING, MASK_LOTION_APPLY}
const INPUT_MAPPING_MENU : GameInputState = GameInputState.MENU
const INPUT_MAPPING_FPS_MOVEMENT : GameInputState = GameInputState.FPS_MOVEMENT
const INPUT_MAPPING_CONVERSATION : GameInputState = GameInputState.CONVERSATION
const INPUT_MAPPING_LOTION_MIXING : GameInputState = GameInputState.LOTION_MIXING
const INPUT_MAPPING_MASK_LOTION_APPLY : GameInputState = GameInputState.MASK_LOTION_APPLY

# Add global constants and parameters here
var game_input_state : GameInputState = GameInputState.FPS_MOVEMENT

func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	
func subscribe_to_movement(move_callback : Callable, turn_callback : Callable, look_callback: Callable) -> void:
	move_player.connect(move_callback)
	turn_player.connect(turn_callback)
	look_up_down.connect(look_callback)
	
func subscribe_to_input_mapping_changed(callback : Callable) -> void:
	input_mapping_changed.connect(callback)
	
func subscribe_to_interaction(callback : Callable) -> void:
	interact.connect(callback)
	
func subscribe_to_menu_toggle(callback : Callable) -> void:
	menu_toggled.connect(callback)
	
func subscribe_to_going_back(callback : Callable) -> void:
	back_to_previous.connect(callback)

func set_input_mapping(new_mapping : GameInputState) -> void:
	game_input_state = new_mapping
	emit_signal("input_mapping_changed", new_mapping)
	
func set_movement(move_dir : Vector2) -> void:
	emit_signal("move_player", move_dir)
	
func set_turn_speed(turn_left_deg_per_sec : float) -> void:
	emit_signal("turn_player", turn_left_deg_per_sec)
	
func set_look_speed(pitch_angle_deg_per_sec : float) -> void:
	emit_signal("look_up_down", pitch_angle_deg_per_sec)
	
func report_interact() -> void:
	emit_signal("interact")
	
func toggle_menu() -> void:
	emit_signal("menu_toggled")

func go_back() -> void:
	emit_signal("back_to_previous")
	
