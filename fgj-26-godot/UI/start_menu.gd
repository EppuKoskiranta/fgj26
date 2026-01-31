extends Control

signal start_game
signal quit_game

func _ready() -> void:
	set_process(false)
	set_physics_process(false)


func _on_start_game_button_down() -> void:
	emit_signal("start_game")
	self.hide()

func _on_quit_button_down() -> void:
	emit_signal("quit_game")
