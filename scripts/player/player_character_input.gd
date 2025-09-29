class_name PlayerCharacterInput
extends Node

var movement_input: Vector2
var aim_input: Vector2

signal spell_input_pressed
signal dash_input_pressed
signal switch_selection_pressed

## Returns raw input data, not normalized
func get_movement_input() -> Vector2:
	movement_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return movement_input

## Returns raw input data, not normalized
func get_aim_input() -> Vector2: 
	aim_input = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	return aim_input

func _process(_delta):
	if Input.is_action_pressed("cast_spell"): # Check every frame since it can be held. _input will only detect the first call
		spell_input_pressed.emit()

func _input(_event):
	if Input.is_action_just_pressed("dash"):
		dash_input_pressed.emit()

	if Input.is_action_just_pressed("switch_selection_right"):
		switch_selection_pressed.emit(1)

	if Input.is_action_just_pressed("switch_selection_left"):
		switch_selection_pressed.emit(-1)