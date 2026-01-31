extends Area3D
class_name Interactiable

signal player_enter
signal player_exit

@export var dimesions : Vector3 = Vector3(1.0, 1.0, 1.0)

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	collision_shape_3d.shape.size = dimesions
	Def.subscribe_to_interaction(self._interaction, Def.SUB_INTERACT_EVENT_ONLY)

func _on_body_entered(_body: Node3D) -> void:
	Def.report_interactable_is_near(self.get_parent())
	emit_signal("player_enter")

func _on_body_exited(_body: Node3D) -> void:
	Def.report_interactable_is_near(null)
	emit_signal("player_exit")

func _interaction() -> void:
	if false == self.get_overlapping_bodies().is_empty():
		Def.report_interact(self.get_parent())
