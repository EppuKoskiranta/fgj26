extends Node3D
class_name Interactiable

@export var dimesions : Vector3 = Vector3(1.0, 1.0, 1.0)

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	collision_shape_3d.shape.size = dimesions

func _on_body_entered(_body: Node3D) -> void:
	Def.report_interactable_is_near(self.get_parent())

func _on_body_exited(_body: Node3D) -> void:
	Def.report_interactable_is_near(null)
