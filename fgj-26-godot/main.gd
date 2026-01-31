extends Node

@onready var player: Player = %Player
@onready var input_handler: InputHandler = %InputHandler
@onready var player_camera: PlayerCamera = %PlayerCamera

func _ready() -> void:
	player_camera.init(player.fps_view)
	# TODO: do it from GameManager
	Def.set_input_mapping(Def.INPUT_MAPPING_FPS_MOVEMENT)

func _process(_delta: float) -> void:
	pass
