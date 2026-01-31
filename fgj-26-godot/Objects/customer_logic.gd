extends CharacterBody3D
class_name Customer

@onready var speed : float = 10.0

enum State {
	REUSABLE = 0,
	GO_TO_COUNTER = 1,
	INTERACTABLE = 2,
	WAITING = 3,
	GOING_TO_BED = 4,
	LOTIONABLE = 5,
	LEAVE = 6,
	MAX_NR_OF_STATES = 7
}

@onready var interactable: Interactiable = %Interactable

var state : State = State.REUSABLE

func _ready() -> void:
	self.show()
	set_interactability(false)

func 

func move_state() -> void:
	match state:
		State.REUSABLE:
			self.show()
		
	state = (state + 1) % State.MAX_NR_OF_STATES
	
func set_interactability(is_interactable : bool) -> void:
	interactable.enable(is_interactable)
