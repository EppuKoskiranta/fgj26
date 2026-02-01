extends CharacterBody3D
class_name Customer

signal arrived_to_location

@onready var speed : float = 2.5

enum State {
	REUSABLE = 0,
	GO_TO_COUNTER = 1,
	INTERACTABLE = 2,
	GOING_TO_BED = 3,
	LOTIONABLE = 4,
	LEAVE = 5,
	MAX_NR_OF_STATES = 6
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
var preferences : Dictionary[String, int] = {
	"hydration" : 0,
	"cleansing" : 0,
	"anti_aging" : 0,
	"soothing_and_calming" : 0,
	"brightening" : 0
}
var adjectives : Dictionary[String, String] = {
	"hydration" : "dry",
	"cleansing" : "dirty",
	"anti_aging" : "old",
	"soothing_and_calming" : "irritated",
	"brightening" : "dull"
}
var preference_rate : Array[String] = [" ", "little", "some", "decent", "lot of" ]
var nr_of_important_properties : int = 0

const MIN_DISTANCE_M : float = 0.8
const COLLISION_MASK : int = 7
const MAX_NR_OF_QUESTIONS : int = 2

func _ready() -> void:
	self.show()
	set_interactability(false)
	Def.subscribe_to_debug(self.move_state)
	generate_preferences()
	
func generate_preferences() -> void:
	nr_of_important_properties = (randi() % 3) + 1
	var randomized_categories : Array[String] = preferences.keys().duplicate()
	randomized_categories.shuffle()
	var random_values : Array[int] = [4]
	match nr_of_important_properties:
		2:
			random_values[0] = (randi() % 3) + 1
			random_values.push_back(4-random_values[0])
		3:
			random_values[0] = 1
			random_values.push_back(1)
			random_values.push_back(1)
			random_values[randi() % 3] = 2
	
	for idx in range(nr_of_important_properties):
		preferences[randomized_categories[idx]] = random_values[idx]

	nr_of_asks_left = MAX_NR_OF_QUESTIONS
	
func get_preferences() -> Array[float]:
	var retval : Array[float] = []
	for value : int in preferences.values():
		retval.push_back(float(value) / 4.0)
	return retval

func move_state() -> State:
	match state:
		State.REUSABLE:
			self.show()
			navigation_agent_3d.set_target_position(front_desk_location.global_position)
		State.GO_TO_COUNTER:
			set_interactability(true)
		State.INTERACTABLE:
			set_interactability(false)
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
			generate_preferences()
		
	state = (state + 1) % State.MAX_NR_OF_STATES as State
	print(State.keys()[state])
	return state
	
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
		State.INTERACTABLE:
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
	var customer_say : String = "I already told you everything you need to know."

	match self.nr_of_asks_left:
		2:
			customer_say = _get_casual_answer()
		1:
			customer_say = _get_straight_answer()
		_:
			pass
	self.nr_of_asks_left -= 1
	self.nr_of_asks_left = max(self.nr_of_asks_left, 0)
	return customer_say

func _get_casual_answer() -> String:
	var possible_answers : Array[String] = []
	match nr_of_important_properties:
		1:
			var preference : String = preferences.find_key(4)
			var adjective : String = adjectives[preference]
			possible_answers.push_back("Could you provide an intense %s treatment please?\nMy skin is %s." % [preference, adjective])
			possible_answers.push_back("Hello there!\nI need some serious %s!\nJust look at my face..." % preference)
		2:
			var str_format : Array[String] = []
			for key in preferences.keys():
				if preferences[key] > 0:
					str_format.push_back(key)
					str_format.push_back(preference_rate[preferences[key]])
					str_format.push_back(adjectives[key])
			possible_answers.push_back("Good day!\nAm I in the right place for a %s %s\nand %s %s?" % [str_format[1], str_format[0], str_format[4], str_format[3]])
			possible_answers.push_back("Please help!\nMy skin is %s and %s.\nI need a %s %s\nand perhaps %s %s." % [str_format[2], str_format[5], str_format[1], str_format[0], str_format[4], str_format[3]])
		_:
			var str_format : Array[String] = []
			for key in preferences.keys():
				if preferences[key] > 0:
					str_format.push_back(key)
					str_format.push_back(preference_rate[preferences[key]])
					str_format.push_back(adjectives[key])
			possible_answers.push_back("Hi there!\nAm I in the right place for %s %s,\n%s %s\nand %s %s?" % [str_format[1], str_format[0], str_format[4], str_format[3], str_format[7], str_format[6]])
	return possible_answers.pick_random()

func _get_straight_answer() -> String:
	var possible_answers : Array[String] = []
	match nr_of_important_properties:
		1:
			var preference : String = preferences.find_key(4)
			var adjective : String = adjectives[preference]
			possible_answers.push_back("Like I said, extreme %s." % preference)
		2:
			var str_format : Array[String] = []
			for key in preferences.keys():
				if preferences[key] > 0:
					str_format.push_back(key)
					str_format.push_back(preference_rate[preferences[key]])
					str_format.push_back(adjectives[key])
			possible_answers.push_back("I need %s and %s.\nCan you make it quick?" % [str_format[0], str_format[3]])
			possible_answers.push_back("Like I said,\n%s %s\nand %s %s." % [str_format[1], str_format[0], str_format[4], str_format[3]])
		_:
			var str_format : Array[String] = []
			for key in preferences.keys():
				if preferences[key] > 0:
					str_format.push_back(key)
					str_format.push_back(preference_rate[preferences[key]])
					str_format.push_back(adjectives[key])
			possible_answers.push_back("So, %s, %s \nand %s %s please!" % [str_format[0], str_format[3], str_format[7], str_format[6]])
	print(preferences, possible_answers)
	return possible_answers.pick_random()
