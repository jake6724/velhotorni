class_name PlayerInput
extends Node2D

var move_input: Vector2
var aim_input: Vector2

var get_aim_input_func: Callable = get_aim_input_mouse

var primary_action_pressed: bool
var primary_action_charge: float

var upgrade_action_pressed: bool
var upgrade_action_charge: float 
var tower_action_press_multiplier_normal: float = 1.0
var tower_action_press_multiplier_fast: float = 6.0
var tower_action_press_multiplier: float = tower_action_press_multiplier_fast

var controller_active: bool = true

signal special_action_pressed
signal switch_selection_pressed
signal switch_player_mode_pressed
signal switch_tower_action_pressed
signal ui_interact_pressed

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	var connected_joypads = Input.get_connected_joypads()
	for device_id in connected_joypads:
		var joy_name = Input.get_joy_name(device_id)
		print("Joypad ", device_id, " name: ", joy_name)

## Returns raw input data, not normalized
func get_move_input() -> Vector2:
	move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return move_input

## Wrapper
func get_aim_input() -> Vector2:
	return get_aim_input_func.call()

## Returns raw input data, not normalized
func get_aim_input_controller() -> Vector2: 
	aim_input = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	print(aim_input)
	return aim_input

func get_aim_input_mouse() -> Vector2: 
	aim_input = get_owner().global_position.direction_to(get_global_mouse_position())
	return aim_input

func _process(delta):
	if primary_action_pressed:
		primary_action_charge += delta

	if upgrade_action_pressed:
		upgrade_action_charge += delta * tower_action_press_multiplier
		
func _input(event):
	check_primary_action_input(event)
	check_upgrade_action_input(event)
	if Input.is_action_just_pressed("secondary_action"):
		special_action_pressed.emit()

	if event.is_action("switch_selection_right") and event.is_pressed() and not event.is_echo():
		switch_selection_pressed.emit(1)

	if event.is_action("switch_selection_left") and event.is_pressed() and not event.is_echo():
		switch_selection_pressed.emit(-1)

	if event.is_action("switch_player_mode") and event.is_pressed() and not event.is_echo():
		switch_player_mode_pressed.emit()

	if event.is_action("switch_tower_action") and event.is_pressed() and not event.is_echo():
		switch_tower_action_pressed.emit()
		
	if event.is_action("ui_interact") and event.is_pressed() and not event.is_echo():
		ui_interact_pressed.emit()
		
	# set_latest_input_type(event)

func check_primary_action_input(event) -> void:
	if Input.is_action_just_pressed("primary_action"):
		primary_action_pressed = true

	if event.is_action_released("primary_action"):
		primary_action_pressed = false
		primary_action_charge = 0

func check_upgrade_action_input(event) -> void:
	if Input.is_action_just_pressed("upgrade_action"):
		upgrade_action_pressed = true

	if event.is_action_released("upgrade_action"):
		upgrade_action_pressed = false
		upgrade_action_charge = 0

# func set_latest_input_type(event) -> void:
# 	if event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion:
# 		is_latest_input_controller = false
# 		# print("Mouse/Keyboard")

# 	elif event is InputEventJoypadButton:
# 		is_latest_input_controller = true
# 		# print("Controller Button")
	
# 	elif event is InputEventJoypadMotion and abs(move_input) > Vector2(.2,.2):
# 		is_latest_input_controller = true
# 		# print("Left Joystick")

# 	elif event is InputEventJoypadMotion and abs(aim_input) > Vector2(.2,.2):
# 		is_latest_input_controller = true
# 		# print("Right Joystick")
