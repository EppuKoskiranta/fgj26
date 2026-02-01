extends Control
class_name DialogueWindow

@onready var customer_label: Label = %CustomerText

func _ready() -> void:
	set_process(true)
	set_physics_process(false)

func set_customer_text(txt : String) -> void:
	customer_label.text = txt
