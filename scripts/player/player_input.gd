class_name PlayerInput
extends Node

var move_input: Vector2
var aim_input: Vector2

var primary_action_pressed
var primary_action_charge: float

var is_latest_input_controller: bool = true

signal secondary_action_pressed
signal switch_selection_pressed
signal switch_player_mode_pressed

## Returns raw input data, not normalized
func get_move_input() -> Vector2:
	# if is_latest_input_controller:
	move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return move_input
	
	# else:
	# 	move_input = Vector2(Input.get_axis("move_left_key", "move_right_key"), Input.get_axis("move_up_key", "move_down_key"))
	# 	return move_input

## Returns raw input data, not normalized
func get_aim_input() -> Vector2: 
	aim_input = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	return aim_input

func _process(_delta):
	if primary_action_pressed:
		primary_action_charge += _delta
		
func _input(event):
	check_primary_action_input(event)
	if Input.is_action_just_pressed("secondary_action"):
		secondary_action_pressed.emit()

	if event.is_action("switch_selection_right") and event.is_pressed() and not event.is_echo():
		switch_selection_pressed.emit(1)

	if event.is_action("switch_selection_left") and event.is_pressed() and not event.is_echo():
		switch_selection_pressed.emit(-1)

	if event.is_action("switch_player_mode") and event.is_pressed() and not event.is_echo():
		switch_player_mode_pressed.emit()

	set_latest_input_type(event)

func check_primary_action_input(event) -> void:
	if Input.is_action_just_pressed("primary_action"):
		primary_action_pressed = true

	if event.is_action_released("primary_action"):
		primary_action_pressed = false
		primary_action_charge = 0

func set_latest_input_type(event) -> void:
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion:
		is_latest_input_controller = false
		# print("Mouse/Keyboard")

	elif event is InputEventJoypadButton:
		is_latest_input_controller = true
		# print("Controller Button")
	
	elif event is InputEventJoypadMotion and abs(move_input) > Vector2(.2,.2):
		is_latest_input_controller = true
		# print("Left Joystick")

	elif event is InputEventJoypadMotion and abs(aim_input) > Vector2(.2,.2):
		is_latest_input_controller = true
		# print("Right Joystick")
