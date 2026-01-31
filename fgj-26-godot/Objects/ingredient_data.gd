extends Resource

class_name IngredientData


@export var lotion_effects: LotionEffects
@export var name : String
@export var mesh : Mesh

func _init() -> void:
    lotion_effects = LotionEffects.new()
    name = ""
    mesh = null
