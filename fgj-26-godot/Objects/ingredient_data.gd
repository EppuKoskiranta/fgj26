extends Resource

class_name IngredientData


@export var hydration : int
@export var cleansing : int
@export var anti_aging : int
@export var soothing_calming : int
@export var brightening : int
@export var name : String
@export var mesh : Mesh

func _init() -> void:
    hydration = 0
    cleansing = 0
    anti_aging = 0
    soothing_calming = 0
    brightening = 0
    name = ""
    mesh = null
