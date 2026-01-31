extends Node

# Add global signals here
signal input_mapping_changed(new_state : GameInputState, previous_state : GameInputState)
signal move_player(move_dir : Vector2)
signal turn_player(turn_left_deg_per_sec : float)
signal look_up_down(pitch_angle_deg_per_sec : float)
signal interact()
signal interact_with(object : Node)
signal interactable_present(object : Node)
signal menu_toggled()
signal back_to_previous()
signal squirt()

# Add global enums here
enum GameInputState {START, MENU, FPS_MOVEMENT, CONVERSATION, LOTION_MIXING, MASK_LOTION_APPLY}
const INPUT_MAPPING_START : GameInputState = GameInputState.START
const INPUT_MAPPING_MENU : GameInputState = GameInputState.MENU
const INPUT_MAPPING_FPS_MOVEMENT : GameInputState = GameInputState.FPS_MOVEMENT
const INPUT_MAPPING_CONVERSATION : GameInputState = GameInputState.CONVERSATION
const INPUT_MAPPING_LOTION_MIXING : GameInputState = GameInputState.LOTION_MIXING
const INPUT_MAPPING_MASK_LOTION_APPLY : GameInputState = GameInputState.MASK_LOTION_APPLY

enum InteractSubscription {GET_OBJECT, EVENT_ONLY}
const SUB_INTERACT_OBJECT : InteractSubscription = InteractSubscription.GET_OBJECT
const SUB_INTERACT_EVENT_ONLY : InteractSubscription = InteractSubscription.EVENT_ONLY

# Add global constants and parameters here
var game_input_state : GameInputState = INPUT_MAPPING_START

var lotion_application : bool = false

func _ready() -> void:
	set_process(true)
	set_physics_process(false)
	
func _process(_delta: float) -> void:
	if lotion_application:
		emit_signal("squirt")
	
func subscribe_to_movement(move_callback : Callable, turn_callback : Callable, look_callback: Callable) -> void:
	move_player.connect(move_callback)
	turn_player.connect(turn_callback)
	look_up_down.connect(look_callback)
	
func subscribe_to_input_mapping_changed(callback : Callable) -> void:
	input_mapping_changed.connect(callback)
	
func subscribe_to_interaction(callback : Callable, mode : InteractSubscription = SUB_INTERACT_OBJECT) -> void:
	if SUB_INTERACT_EVENT_ONLY == mode:
		interact.connect(callback)
	else:
		interact_with.connect(callback)
	
func subscribe_to_menu_toggle(callback : Callable) -> void:
	menu_toggled.connect(callback)
	
func subscribe_to_going_back(callback : Callable) -> void:
	back_to_previous.connect(callback)

func subscribe_to_interactable(callback : Callable) -> void:
	interactable_present.connect(callback)

func subscribe_to_lotion_application(callback : Callable) -> void:
	squirt.connect(callback)

func set_input_mapping(new_mapping : GameInputState) -> void:
	var previous : GameInputState = game_input_state
	game_input_state = new_mapping
	emit_signal("input_mapping_changed", game_input_state, previous)
	
func set_movement(move_dir : Vector2) -> void:
	emit_signal("move_player", move_dir)
	
func set_turn_speed(turn_left_deg_per_sec : float) -> void:
	emit_signal("turn_player", turn_left_deg_per_sec)
	
func set_look_speed(pitch_angle_deg_per_sec : float) -> void:
	emit_signal("look_up_down", pitch_angle_deg_per_sec)
	
func stop_player() -> void:
	set_movement(Vector2(0.0, 0.0))
	set_turn_speed(0.0)
	set_look_speed(0.0)
	
func report_interact(object : Node) -> void:
	if null == object:
		emit_signal("interact")
	else:
		emit_signal("interact_with", object)
	
func report_interactable_is_near(object : Node) -> void:
	emit_signal("interactable_present", object)
	
func toggle_menu() -> void:
	emit_signal("menu_toggled")

func go_back() -> void:
	emit_signal("back_to_previous")
	
func start_spreading_lotion() -> void:
	lotion_application = true
	
func stop_spreading_lotion() -> void:
	lotion_application = false
	
	
