extends Node3D


@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var player_in_range: bool = false

func _ready() -> void:
	audio_player.play()


func next_station() -> void:
	var stations = [
		preload("res://audio/ost/intensity_1.mp3"),
		preload("res://audio/ost/intensity_2.mp3"),
		preload("res://audio/ost/intensity_3.mp3"),
		preload("res://audio/ost/intensity_4.mp3"),
		preload("res://audio/ost/intensity_5.mp3"),
		preload("res://audio/ost/alien.mp3"),
		preload("res://audio/ost/drone.mp3"),
	]
	var current_index = stations.find(audio_player.stream)
	var next_index = (current_index + 1) % stations.size()
	audio_player.stream = stations[next_index]
	audio_player.play()

func _process(_delta: float) -> void:
	if player_in_range:
		# Show some UI prompt to the player (not implemented here)
		pass

	# Get the ui_accept key press to change the station
	if Input.is_action_just_pressed("ui_accept") and player_in_range:
		next_station()


func _on_body_entered(body: Node3D) -> void:
	player_in_range = true
	print("Entered radio range.")


func _on_body_exited(body: Node3D) -> void:
	player_in_range = false
	print("Exited radio range.")
