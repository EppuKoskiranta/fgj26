extends Node

@onready var player: Player = %Player
@onready var input_handler: InputHandler = %InputHandler
@onready var player_camera: PlayerCamera = %PlayerCamera
@onready var game_manager: GameManager = $GameManager

func _ready() -> void:
	player_camera.init(player.fps_view)

func _process(_delta: float) -> void:
	pass
