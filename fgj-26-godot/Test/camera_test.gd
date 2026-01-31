extends Node3D

@onready var viewpoint_1: CameraDockingStation = %Viewpoint1
@onready var viewpoint_2: CameraDockingStation = %Viewpoint2
@onready var viewpoint_3: CameraDockingStation = %Viewpoint3
@onready var dummy_character: CharacterBody3D = %DummyCharacter
@onready var player_camera: PlayerCamera = %PlayerCamera
@onready var input_handler: InputHandler = %InputHandler
@onready var dummy_menu: Control = %DummyMenu

var current_viewpoint : int = 0

func _ready() -> void:
	player_camera.init(dummy_character.fps_view)

	if not InputMap.has_action("SwitchCamera"):
		InputMap.add_action("SwitchCamera")
	var key_event := InputEventKey.new()
	key_event.keycode = KEY_TAB
	InputMap.action_add_event("SwitchCamera", key_event)
	
	Def.set_input_mapping(Def.INPUT_MAPPING_FPS_MOVEMENT)
	
	input_handler.is_test = true
	
	Def.subscribe_to_menu_toggle(_toggle_menu)

func _process(_delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("SwitchCamera"):
		match current_viewpoint:
			0:
				player_camera.attach_to(viewpoint_1)
			1:
				player_camera.attach_to(viewpoint_2)
			2:
				player_camera.attach_to(viewpoint_3)
			_:
				player_camera.detach_from_viewpoint()
		current_viewpoint = (current_viewpoint+1) % 4
		
func _toggle_menu() -> void:
	if dummy_menu.is_visible_in_tree():
		Def.set_input_mapping(Def.INPUT_MAPPING_FPS_MOVEMENT)
		dummy_menu.hide()
	else:
		Def.set_input_mapping(Def.INPUT_MAPPING_MENU)
		dummy_menu.show()
