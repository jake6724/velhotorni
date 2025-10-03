class_name PlayerInput
extends Node

var move_input: Vector2
var aim_input: Vector2

var primary_action_pressed

signal secondary_action_pressed
signal switch_selection_pressed
signal switch_player_mode_pressed

## Returns raw input data, not normalized
func get_move_input() -> Vector2:
	move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return move_input

## Returns raw input data, not normalized
func get_aim_input() -> Vector2: 
	aim_input = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	return aim_input

# func _process(_delta):
# 	if Input.is_action_pressed("cast_spell"): # Check every frame since it can be held. _input will only detect the first call
# 		spell_input_pressed.emit()

func _input(event):
	check_primary_action_input(event)

	if event.is_action_pressed("secondary_action"):
		secondary_action_pressed.emit() # TODO: Change this to secondary_action_pressed

	if event.is_action("switch_selection_right") and event.is_pressed() and not event.is_echo():
		switch_selection_pressed.emit(1)

	if event.is_action("switch_selection_left") and event.is_pressed() and not event.is_echo():
		switch_selection_pressed.emit(-1)

	if event.is_action("switch_player_mode") and event.is_pressed() and not event.is_echo():
		switch_player_mode_pressed.emit()

func check_primary_action_input(event) -> void:
	if Input.is_action_just_pressed("primary_action"):
		primary_action_pressed = true
	# if event.is_action_pressed("primary_action") and not event.is_echo():
	# 	primary_action_pressed = true

	if event.is_action_released("primary_action") and not event.is_echo():
		primary_action_pressed = false