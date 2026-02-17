class_name Ingredient
extends Node3D


@export var mesh_scale: Vector3 = Vector3(1.0, 1.0, 1.0)
@export var ingredient_data: IngredientData

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var floating_display: IngredientFloatingDisplay = $IngredientFloatingDisplay

func _ready() -> void:
    mesh_instance.mesh = ingredient_data.mesh
    mesh_instance.scale = mesh_scale
    floating_display.ingredient_data = ingredient_data
    floating_display.initialize()
