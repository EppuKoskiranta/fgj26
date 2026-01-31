extends Node3D
class_name LotionPot

@export var current_lotion_effects : LotionEffects

func _init() -> void:
	current_lotion_effects = LotionEffects.new()

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
			return

		if item_from_player is Ingredient:
			var ingredient = item_from_player as Ingredient
			var ingredient_data: IngredientData = ingredient.ingredient_data

			# Apply the lotion effects from the ingredient to the lotion pot
			_apply_ingredient_effects(ingredient_data.lotion_effects)

			# Remove the ingredient from player's hand
			player.remove_item_in_hand()

			print("Applied ingredient effects to lotion pot from ", ingredient_data.name)
		else:
			print("Item in hand is not an Ingredient.")
			


			
