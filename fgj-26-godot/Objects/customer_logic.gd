extends CharacterBody3D
class_name Customer

signal arrived_to_location

@onready var speed : float = 2.5

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
var spawn_location : Node3D = null
var front_desk_location : Node3D = null
var bed_location : Node3D = null
var on_bed_location : Node3D = null
var player_camera : Node3D = null

@onready var interactable: Interactiable = %Interactable
@onready var navigation_agent_3d: NavigationAgent3D = %NavigationAgent3D

var state : State = State.REUSABLE
var nr_of_asks_left : int = MAX_NR_OF_QUESTIONS

const MIN_DISTANCE_M : float = 0.8
const COLLISION_MASK : int = 7
const MAX_NR_OF_QUESTIONS : int = 2

func _ready() -> void:
	self.show()
	set_interactability(false)
	Def.subscribe_to_debug(self.move_state)

func move_state() -> void:
	match state:
		State.REUSABLE:
			self.show()
			navigation_agent_3d.set_target_position(front_desk_location.global_position)
		State.GO_TO_COUNTER:
			set_interactability(true)
		State.INTERACTABLE:
			set_interactability(false)
		State.WAITING:
			navigation_agent_3d.set_target_position(bed_location.global_position)
		State.GOING_TO_BED:
			self.global_transform = on_bed_location.global_transform
			self.collision_mask = 0
		State.LOTIONABLE:
			self.collision_mask = COLLISION_MASK
			self.global_transform = bed_location.global_transform
			navigation_agent_3d.set_target_position(spawn_location.global_position)
		_:
			self.hide()
			nr_of_asks_left = MAX_NR_OF_QUESTIONS
		
	state = (state + 1) % State.MAX_NR_OF_STATES as State
	print(State.keys()[state])
	
func _physics_process(delta: float) -> void:
	
	var target_distance : float = 500.0
	
	match state:
		State.GO_TO_COUNTER, State.GOING_TO_BED, State.LEAVE:
			var destination : Vector3 = navigation_agent_3d.get_next_path_position()
			velocity = ((destination - self.global_position)*Vector3(1.0, 0.0, 1.0)).normalized() * speed
			
			var direction : Vector3 = navigation_agent_3d.get_target_position() - self.global_position
			if velocity.length() > 0.01:
				self.look_at(self.global_position-velocity, Vector3.UP)
			target_distance = direction.length()
		State.WAITING, State.INTERACTABLE:
			var direction : Vector3 = player_camera.global_position - self.global_position
			self.look_at(self.global_position-(direction * Vector3(1.0, 0.0, 1.0)), Vector3.UP)
			velocity = Vector3.ZERO
		_:
			velocity = Vector3.ZERO
	
	if not is_on_floor() and state != State.LOTIONABLE:
		velocity += get_gravity() * delta
	move_and_slide()
	
	if target_distance < MIN_DISTANCE_M:
		emit_signal("arrived_to_location")
	
func set_interactability(is_interactable : bool) -> void:
	interactable.enable(is_interactable)
	
func get_text() -> String:
	self.nr_of_asks_left -= 1
	match self.nr_of_asks_left:
		1:
			return "TODO: Polite answer"
		0:
			return "TODO: Straight answer"
		_:
			self.nr_of_asks_left = max(self.nr_of_asks_left, -1)
			return "I already told you everything you need to know."
	
	print(self.nr_of_asks_left)
