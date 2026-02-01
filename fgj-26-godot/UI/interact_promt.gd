extends Control
class_name InteractPromt

@onready var promt_label: Label = %PromtLabel

var mouse_button_names: Dictionary[MouseButton, String] = {
	 MouseButton.MOUSE_BUTTON_NONE : " ",
	 MouseButton.MOUSE_BUTTON_LEFT : "LMB",
	 MouseButton.MOUSE_BUTTON_RIGHT : "RMB",
	 MouseButton.MOUSE_BUTTON_MIDDLE : "MMB",
	 MouseButton.MOUSE_BUTTON_WHEEL_UP : "WheelUp",
	 MouseButton.MOUSE_BUTTON_WHEEL_DOWN : "WheelDown",
	 MouseButton.MOUSE_BUTTON_WHEEL_LEFT : " ",
	 MouseButton.MOUSE_BUTTON_WHEEL_RIGHT : " ",
	 MouseButton.MOUSE_BUTTON_XBUTTON1 : " ",
	 MouseButton.MOUSE_BUTTON_XBUTTON2 : " "
}

var nr_of_interactables : int = 0

func _ready() -> void:
	set_process(true)
	set_physics_process(false)
	Def.subscribe_to_interactable(_show_promt)
	Def.subscribe_to_input_mapping_changed(self._input_mapping_changed)
	self.hide()

func _show_promt(object : Node) -> void:
	nr_of_interactables += 1 if null != object else -1
	if nr_of_interactables > 0:
		self.show()
	else:
		self.hide()
	
func _input_mapping_changed(new_state : Def.GameInputState, _previous_state : Def.GameInputState) -> void:
	match new_state:
		Def.INPUT_MAPPING_START:
			promt_label.text = ""
		Def.INPUT_MAPPING_MENU:
			promt_label.text = ""
		Def.INPUT_MAPPING_FPS_MOVEMENT:
			promt_label.text = "Interact [E/LMB]"
		Def.INPUT_MAPPING_CONVERSATION, Def.INPUT_MAPPING_LOTION_MIXING, Def.INPUT_MAPPING_MASK_LOTION_APPLY:
			promt_label.text = "Back [RMB]"
		
		
