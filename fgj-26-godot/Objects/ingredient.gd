class_name Ingredient
extends Node3D


@export var mesh_scale: Vector3 = Vector3(1.0, 1.0, 1.0)
@export var ingredient_data: IngredientData

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	mesh_instance.mesh = ingredient_data.mesh
	mesh_instance.scale = mesh_scale
