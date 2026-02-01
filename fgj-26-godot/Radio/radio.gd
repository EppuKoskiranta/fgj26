extends Node3D
class_name Radio

@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready() -> void:
	next_station()
	set_process(false)
	set_physics_process(false)
	Def.subscribe_to_interaction(self._interaction)

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

func _interaction(object: Node) -> void:
	if object == self:
		next_station()
	
