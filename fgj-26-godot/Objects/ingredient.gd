class_name Ingredient
extends Node3D


@export var ingredient_data: IngredientData
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

@onready var is_looked_at: bool = false

func _ready() -> void:
	mesh_instance.mesh = ingredient_data.mesh
