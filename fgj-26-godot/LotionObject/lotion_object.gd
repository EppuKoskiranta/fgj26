class_name LotionObject
extends MeshInstance3D

@export var full_bowl : Mesh
@export var half_bowl : Mesh
@export var empty_bowl : Mesh


var color : Color = Color.BLACK
var total_amount : float
var amount : float

var lotion_effects : LotionEffects
var lotion_ratio : LotionRatio


func initialize(lotion_effects : LotionEffects, amount : float, color : Color):
	assert(full_bowl)
	assert(half_bowl)
	assert(empty_bowl)
	self.mesh = full_bowl
	self.color = color
	self.lotion_effects = lotion_effects
	self.amount = amount
	self.total_amount = amount
	self.lotion_ratio = LotionRatio.new()
	self.lotion_ratio.calculate_from_effects(lotion_effects)


func get_lotion(a : float) -> float:
	var return_amount = 0
	if a < amount:
		amount -= a
		return_amount = a
	else:
		return_amount = amount
		amount = 0
	
	if amount == 0:
		_switch_to_empty()
	elif a < (total_amount / 2):
		_switch_to_half_full()
	return return_amount

func _switch_to_half_full():
	mesh = half_bowl

func _switch_to_empty():
	mesh = empty_bowl

func print_lotion_info():
	print("Lotion Color: ", color)
	print("Lotion Amount: ", amount, "/", total_amount)
	print("Lotion Effects: ")
	print("  Hydration: ", lotion_effects.hydration)
	print("  Cleansing: ", lotion_effects.cleansing)
	print("  Anti-Aging: ", lotion_effects.anti_aging)
	print("  Soothing/Calming: ", lotion_effects.soothing_calming)
	print("  Brightening: ", lotion_effects.brightening)
	print("Lotion Ratios: ")
	print("  Hydration Ratio: ", lotion_ratio.hydration)
	print("  Cleansing Ratio: ", lotion_ratio.cleansing)
	print("  Anti-Aging Ratio: ", lotion_ratio.anti_aging)
	print("  Soothing/Calming Ratio: ", lotion_ratio.soothing_calming)
	print("  Brightening Ratio: ", lotion_ratio.brightening)
