class_name ScoreSystem
extends Node





func get_score(customer_lotion_ratio : Array, lotion_ratio : Array, face_covered_ratio : float) -> String:
	var score = _calculate_score(customer_lotion_ratio, lotion_ratio, face_covered_ratio)
	
	if customer_lotion_ratio.size() != 5:
		print("Wrong customer lotion array size")
		return "WTF"
	
	if score >= 1.0:
		return "S"
	elif score >= 0.80:
		return "A"
	elif score >= 0.60:
		return "B"
	elif score >= 0.40:
		return "C"
	elif score >= 0.20:
		return "D"
	
	return "E"


func _calculate_score(customer_lotion_ratio : Array, lotion_ratio : Array, face_covered_ratio : float) -> float:
	var score = 0.0

	# Calculate delta for each value between customer and lotion ratios
	for i in range(customer_lotion_ratio.size()):
		var delta = abs(customer_lotion_ratio[i] - lotion_ratio[i])
		# Deduct score based on delta
		score += max(0.0, 0.2 - delta * 0.2)  # Max 0.2 per attribute, scaled by delta

	#half of points from face covered ratio
	score += (face_covered_ratio / 2)
	
	return score
