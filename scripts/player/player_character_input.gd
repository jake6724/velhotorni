class_name PlayerCharacterInput
extends Node

var movement_input: Vector2
var aim_input: Vector2

signal spell_cast
signal dash_cast

func get_movement_input() -> Vector2:
	movement_input.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	movement_input.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return movement_input.normalized()

func get_aim_input() -> Vector2: 
	aim_input.x = Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left")
	aim_input.y = Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	return aim_input.normalized()

func _process(_delta):
	if Input.is_action_pressed("cast_spell"): # Check every frame since it can be held. _input will only detect the first call
		spell_cast.emit()

func _input(_event):
	if Input.is_action_just_pressed("dash"):
		dash_cast.emit()