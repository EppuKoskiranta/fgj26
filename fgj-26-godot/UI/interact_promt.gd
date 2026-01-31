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
	set_physics_process(false)
	Def.subscribe_to_interactable(_show_promt)
	_set_label()
	self.hide()

func _process(_delta: float) -> void:
	_set_label()

func _set_label() -> void:
	var promt_str : String = "Interact ["
	for event in InputMap.action_get_events("interact"):
		if event is InputEventKey:
			promt_str += OS.get_keycode_string(event.physical_keycode) + "/"
		elif event is InputEventMouseButton:
			promt_str += mouse_button_names[event.button_index] + "/"
	promt_str = promt_str.left(- 1)
	promt_str += "]"
	promt_label.text = promt_str

func _show_promt(object : Node) -> void:
	nr_of_interactables += 1 if null != object else -1
	if nr_of_interactables > 0:
		self.show()
	else:
		self.hide()
