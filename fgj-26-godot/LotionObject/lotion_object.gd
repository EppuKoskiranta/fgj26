class_name LotionObject
extends MeshInstance3D

@export var full_bowl : Mesh
@export var half_bowl : Mesh
@export var empty_bowl : Mesh


var color : Color = Color.BLACK
var total_amount : float
var amount : float

var effects : LotionEffects


func initialize(lotion_effects : LotionEffects, amount : float, color : Color) -> void:
	assert(full_bowl)
	assert(half_bowl)
	assert(empty_bowl)
	self.mesh = full_bowl
	self.color = color
	self.effects = lotion_effects
	self.amount = amount
	self.total_amount = amount


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
