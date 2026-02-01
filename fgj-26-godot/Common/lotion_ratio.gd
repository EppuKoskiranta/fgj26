extends Resource
class_name LotionRatio

@export var hydration : float
@export var cleansing : float
@export var anti_aging : float
@export var soothing_calming : float
@export var brightening : float


func _init() -> void:
    hydration = 0.0
    cleansing = 0.0
    anti_aging = 0.0
    soothing_calming = 0.0
    brightening = 0.0

func calculate_from_effects(effects: LotionEffects) -> void:
    var total = effects.hydration + effects.cleansing + effects.anti_aging + effects.soothing_calming + effects.brightening
    if total == 0:
        hydration = 0.0
        cleansing = 0.0
        anti_aging = 0.0
        soothing_calming = 0.0
        brightening = 0.0
        return

    hydration = float(effects.hydration) / float(total)
    cleansing = float(effects.cleansing) / float(total)
    anti_aging = float(effects.anti_aging) / float(total)
    soothing_calming = float(effects.soothing_calming) / float(total)
    brightening = float(effects.brightening) / float(total)
