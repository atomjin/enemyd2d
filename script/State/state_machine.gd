extends Node
class_name StateMachine

@export var InitialState: State


var current_state: State =null 

var states: Dictionary ={}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transitioned)
			
	if InitialState:
		current_state = InitialState
		InitialState.enter()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_state:
		current_state.process(delta)
		
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_process(delta)
	
	
func on_child_transitioned(state, new_state_name):
	if state != current_state:
		return

	var new_state = get_node_or_null(new_state_name)
	print("Switching to state:", new_state_name)

	if not new_state:
		push_error("❌ Could not find state: " + str(new_state_name))
		return

	if current_state:
		current_state.exit()

	new_state.enter()
	current_state = new_state
