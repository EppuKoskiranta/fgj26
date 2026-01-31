extends Node

@onready var player: Player = %Player
@onready var input_handler: InputHandler = %InputHandler
@onready var player_camera: PlayerCamera = %PlayerCamera
@onready var game_manager: GameManager = $GameManager

func _ready() -> void:
	player_camera.init(player.fps_view)
	# TODO: Remove this and make menu visible
	Def.set_input_mapping(Def.INPUT_MAPPING_FPS_MOVEMENT)

func _process(_delta: float) -> void:
	pass

func _on_start_menu_start_game() -> void:
	Def.set_input_mapping(Def.INPUT_MAPPING_FPS_MOVEMENT)

func _on_start_menu_quit_game() -> void:
	if is_inside_tree():
		get_tree().paused = true
	if is_inside_tree():
		get_tree().quit()
