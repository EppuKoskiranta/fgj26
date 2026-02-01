extends Resource
class_name LotionEffects

@export var hydration : int
@export var cleansing : int
@export var anti_aging : int
@export var soothing_calming : int
@export var brightening : int

func _init() -> void:
	hydration = 0
	cleansing = 0
	anti_aging = 0
	soothing_calming = 0
	brightening = 0


func get_ratio() -> Array:
	var total = float(hydration + cleansing + anti_aging + soothing_calming + brightening)
	var arr = []
	var ratio = 0.0
	#hydration ratio
	ratio = float(hydration) / total
	arr.push_back(ratio)
	
	#cleasing ratio
	ratio = float(cleansing) / total
	arr.push_back(ratio)
	
	#anti_aging ratio
	ratio = float(anti_aging) / total
	arr.push_back(ratio)
	
	#soothing ratio
	ratio = float(soothing_calming) / total
	arr.push_back(ratio)
	
	#brightening ratio
	ratio = float(brightening) / total
	arr.push_back(ratio)
	
	return arr
