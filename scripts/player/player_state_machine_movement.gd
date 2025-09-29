class_name PlayerStateMachineMovement
extends Node

# Store a hashmap reference to each state 
var states: Dictionary[String, PlayerMovementState] = {}
var initial_state: PlayerMovementState = states.keys()[0]
var current_state: PlayerMovementState = initial_state

# Passed from PlayerCharacter
var player_move_input: Vector2

func initialize():
	# Initialize and store all child states
	var children: Array = get_children()
	for s in children:
		states[s.name.to_lower()] = s
		s.init_state()
		s.transition_state.connect(transition)

	# Configure current state
	if initial_state:
		current_state = initial_state
	else:
		push_error("initial_state not set; assign in the editor.")

func _process(_delta):
	if current_state:
		current_state.process_state(_delta, player_move_input)

func transition(prev_state, new_state):
	if prev_state == current_state:
		prev_state.exit_state()
		if new_state in states:
			current_state = states[new_state] # Used passed statename to look-up state ref 
			current_state.enter_state()

		else:
			push_error(str("State '" + new_state + "' does not exist as state machine child"))
