extends Node3D
class_name LotionPot

@export var current_lotion_effects : LotionEffects
@export var current_ratio : LotionRatio

var max_ingredients : int = 5
var current_ingredient_count : int = 0

@onready var lotion_scene = preload("res://LotionObject/lotion_object_scene.tscn")

func _init() -> void:
	current_lotion_effects = LotionEffects.new()
	current_ratio = LotionRatio.new()

func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	Def.subscribe_to_interaction(self._interaction)


func _apply_ingredient_effects(ingredient_effects: LotionEffects) -> void:
	current_lotion_effects.hydration += ingredient_effects.hydration
	current_lotion_effects.cleansing += ingredient_effects.cleansing
	current_lotion_effects.anti_aging += ingredient_effects.anti_aging
	current_lotion_effects.soothing_calming += ingredient_effects.soothing_calming
	current_lotion_effects.brightening += ingredient_effects.brightening
	print("Lotion Pot effects updated: ")
	print("Hydration: ", current_lotion_effects.hydration)
	print("Cleansing: ", current_lotion_effects.cleansing)
	print("Anti-Aging: ", current_lotion_effects.anti_aging)
	print("Soothing/Calming: ", current_lotion_effects.soothing_calming)
	print("Brightening: ", current_lotion_effects.brightening)

func _interaction(object: Node) -> void:
	if object == self:
		print("Lotion Pot interacted with")

		# Get the ingredient in player's hand
		var player = Def.get_player() as Player

		var item_from_player = player.get_item_in_hand()
		if item_from_player == null:
			print("Player is not holding any item.")
			# handle lotion object creation in player.gd::try_to_get_lotion()
			return

		if item_from_player is Ingredient:
			var ingredient = item_from_player as Ingredient
			var ingredient_data: IngredientData = ingredient.ingredient_data

			# Remove the ingredient from player's hand
			player.remove_item_in_hand()

			if current_ingredient_count >= max_ingredients:
				print("Lotion Pot is full. Cannot add more ingredients.")
				return

			current_ingredient_count += 1
			# Apply the lotion effects from the ingredient to the lotion pot
			_apply_ingredient_effects(ingredient_data.lotion_effects)

			update_ratios()
			print("Applied ingredient effects to lotion pot from ", ingredient_data.name)
		else:
			print("Item in hand is not an Ingredient.")

func update_ratios():
	current_ratio.calculate_from_effects(current_lotion_effects)
	print("Updated Lotion Ratios: ")
	print("Hydration Ratio: ", current_ratio.hydration)
	print("Cleansing Ratio: ", current_ratio.cleansing)
	print("Anti-Aging Ratio: ", current_ratio.anti_aging)
	print("Soothing/Calming Ratio: ", current_ratio.soothing_calming)
	print("Brightening Ratio: ", current_ratio.brightening)

func get_current_lotion_effects() -> LotionEffects:
	return current_lotion_effects

			
func reset_lotion_pot() -> void:
	current_lotion_effects = LotionEffects.new()
	current_ingredient_count = 0
	print("Lotion Pot has been reset.")

func lotion_ready() -> bool:
	return current_ingredient_count > 0

func instantiate_lotion_object_scene() -> Node3D:
	var instance = lotion_scene.instantiate()
	var lotion_object = (instance as LotionObject)
	lotion_object.initialize(current_lotion_effects, 100.0, Color.GREEN)
	return instance
