extends Node
class_name GameManager

var previous_input_state : Def.GameInputState = Def.INPUT_MAPPING_START

@export var player_camera : PlayerCamera

func _ready() -> void:
	assert(player_camera)
	set_process(false)
	set_physics_process(false)
	Def.subscribe_to_menu_toggle(self._menu_toggle)
	Def.subscribe_to_going_back(self._back_from_station)
	Def.subscribe_to_input_mapping_changed(self._input_mapping_changed)
	Def.subscribe_to_interaction(self._interacted_with)
	
func _back_from_station() -> void:
	Def.set_input_mapping(Def.INPUT_MAPPING_FPS_MOVEMENT)
	player_camera.detach_from_viewpoint()
	
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
	if object is FaceLotionApply:
		var lotionStation = object as FaceLotionApply
		Def.set_input_mapping(Def.GameInputState.MASK_LOTION_APPLY)
		player_camera.attach_to(lotionStation.get_docking_station())
