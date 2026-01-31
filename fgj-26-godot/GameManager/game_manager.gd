extends Node
class_name GameManager

var previous_input_state : Def.GameInputState = Def.INPUT_MAPPING_START

var ingredient_in_player_hand : Ingredient = null

func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	Def.subscribe_to_menu_toggle(self._menu_toggle)
	Def.subscribe_to_going_back(self._back_from_station)
	Def.subscribe_to_input_mapping_changed(self._input_mapping_changed)
	Def.subscribe_to_interaction(self._interacted_with)
	# TODO: only when we start from main menu
	Def.set_input_mapping(Def.INPUT_MAPPING_FPS_MOVEMENT)
	
func _back_from_station() -> void:
	Def.set_input_mapping(Def.INPUT_MAPPING_FPS_MOVEMENT)
	
func _menu_toggle() -> void:
	match Def.game_input_state:
		Def.INPUT_MAPPING_START:
			pass
		Def.INPUT_MAPPING_MENU:
			Def.set_input_mapping(previous_input_state)
			get_tree().paused = false
			Def.stop_player()
		_:
			Def.set_input_mapping(Def.INPUT_MAPPING_MENU)
			get_tree().paused = true
		
func _input_mapping_changed(_new_state : Def.GameInputState, prev_state : Def.GameInputState) -> void:
	self.previous_input_state = prev_state
	
func _interacted_with(object : Node) -> void:
	# TODO: change input mapping based on what we interacted with
	print("Interacted with ", object.name)
