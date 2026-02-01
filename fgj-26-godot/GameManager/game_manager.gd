extends Node
class_name GameManager

var previous_input_state : Def.GameInputState = Def.INPUT_MAPPING_START

@onready var customer_logic: Customer = %CustomerLogic
@onready var pause_menu: Control = %PauseMenu
@onready var dialogue_with_customer: DialogueWindow = %DialogueWithCustomer
@onready var score_system : ScoreSystem = $ScoreSystem
@onready var fake_customer : Node3D = $fake_customer

var ingredient_in_player_hand : Ingredient = null
@export var player_camera : PlayerCamera
@export var game_map : GameMap = null

func _ready() -> void:
	assert(player_camera)
	assert(game_map)
	set_process(false)
	set_physics_process(false)
	Def.subscribe_to_menu_toggle(self._menu_toggle)
	Def.subscribe_to_going_back(self._back_from_station)
	Def.subscribe_to_input_mapping_changed(self._input_mapping_changed)
	Def.subscribe_to_interaction(self._interacted_with)
	Def.subscribe_to_mix_start(self._mix_started)
	Def.set_input_mapping(Def.INPUT_MAPPING_START)
	
	pause_menu.hide()
	dialogue_with_customer.hide()
	
	customer_logic.spawn_location = game_map.spawn_point
	customer_logic.front_desk_location = game_map.front_desk
	customer_logic.bed_location = game_map.bed_side
	customer_logic.on_bed_location = game_map.bed_top
	customer_logic.player_camera = player_camera
	
func start_game() -> void:
	Def.set_input_mapping(Def.INPUT_MAPPING_FPS_MOVEMENT)
	customer_logic.move_state()
	
func _back_from_station() -> void:
	Def.set_input_mapping(Def.INPUT_MAPPING_FPS_MOVEMENT)
	player_camera.detach_from_viewpoint()
	
func get_camera() -> PlayerCamera:
	return player_camera
	
func _menu_toggle() -> void:
	match Def.game_input_state:
		Def.INPUT_MAPPING_START:
			pass
		Def.INPUT_MAPPING_MENU:
			Def.set_input_mapping(previous_input_state)
			get_tree().paused = false
			Def.stop_player()
			pause_menu.hide()
		_:
			Def.set_input_mapping(Def.INPUT_MAPPING_MENU)
			get_tree().paused = true
			pause_menu.show()
		
func _input_mapping_changed(new_state : Def.GameInputState, prev_state : Def.GameInputState) -> void:
	self.previous_input_state = prev_state
	print( Def.GameInputState.keys()[new_state])
	if Def.INPUT_MAPPING_CONVERSATION == new_state:
		var customer_said : String = customer_logic.get_text()
		print(customer_said)
		dialogue_with_customer.set_customer_text(customer_said)
		dialogue_with_customer.show()
	else:
		dialogue_with_customer.hide()
	
	if Def.INPUT_MAPPING_MASK_LOTION_APPLY == prev_state \ 
		and Customer.State.LOTIONABLE == customer_logic.state:
		customer_logic.move_state()
	
func _interacted_with(object : Node) -> void:
	# TODO: change input mapping based on what we interacted with
	print("Interacted with ", object.name)
	if object is FaceLotionApply:
		var lotionStation = object as FaceLotionApply
		Def.set_input_mapping(Def.INPUT_MAPPING_MASK_LOTION_APPLY)
		player_camera.attach_to(lotionStation.get_docking_station())
	elif object is Customer:
		Def.set_input_mapping(Def.INPUT_MAPPING_CONVERSATION)
		
func _mix_started() -> void:
	if Customer.State.INTERACTABLE == customer_logic.state:
		customer_logic.move_state()

func _on_customer_logic_arrived_to_location() -> void:
	var state = customer_logic.move_state()
	if (state == Customer.State.REUSABLE):
		_get_score()
	
	if state == Customer.State.LOTIONABLE:
		_hide_customer_and_replace_with_fake()
	else:
		_revert_hide_customer_and_replace_with_fake()

func _hide_customer_and_replace_with_fake():
	customer_logic.visible = false
	fake_customer.visible = true

func _revert_hide_customer_and_replace_with_fake():
	customer_logic.visible = true
	fake_customer.visible = false

func _get_score():
	#score_system.get_score()
	var lotion_station = Def.get_lotion_station() as FaceLotionApply
	#var placeholder_customer_ratios = [0.0, 0.0, 0.5, 0.25, 0.25]
	var customer_ratios = customer_logic.get_preferences()
	var lotion_ratios = lotion_station.get_location_ratio()
	var covered_ratio = lotion_station.get_covered_ratio()
	var scoreString = score_system.get_score(customer_ratios, lotion_ratios, covered_ratio)
	print("Score: ", scoreString)

func _on_pause_menu_resume_game() -> void:
	Def.toggle_menu()
	
func _on_pause_menu_quit_game() -> void:
	if is_inside_tree():
		get_tree().paused = true
	if is_inside_tree():
		get_tree().quit()
