class_name PlayerInput
extends Node2D

var move_input: Vector2
var aim_input: Vector2

var get_move_input_func: Callable = get_move_input_keyboard
var get_aim_input_func: Callable = get_aim_input_mouse

var primary_action_pressed: bool
var primary_action_charge: float

var upgrade_action_pressed: bool
var upgrade_action_charge: float 
var tower_action_press_multiplier_normal: float = 1.0
var tower_action_press_multiplier_fast: float = 3.0
var tower_action_press_multiplier: float = tower_action_press_multiplier_fast

var start_wave_action_pressed: bool = false
var start_wave_action_charge: float = 0.0
const START_WAVE_ACTION_CHARGE_MULTIPLIER: float = 150.0
const START_WAVE_ACTION_DISCHARGE_MULTIPLIER: float = 300.0

var heal_all_action_pressed: bool = false
var heal_all_action_charge: float = 0.0
const HEAL_ALL_ACTION_CHARGE_MULTIPLIER: float = 150.0
const HEAL_ALL_ACTION_DISCHARGE_MULTIPLIER: float = 300.0


var input_enabled: bool = true

var can_start_wave: bool = true # Set by Main

signal primary_action_just_pressed
signal primary_action_released
signal special_action_pressed
signal switch_selection_pressed
signal switch_player_mode_pressed
signal switch_tower_action_pressed
signal weapon_select_pressed
signal ui_interact_pressed
signal escape_pressed
signal start_wave_action_charge_updated
signal heal_all_action_charge_updated

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	#get_controller_info()

## Returns raw input data, not normalized
func get_move_input() -> Vector2:
	return get_move_input_func.call()

func get_move_input_keyboard() -> Vector2: 
	move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return move_input

func get_move_input_controller() -> Vector2:
	move_input = Input.get_vector("move_left_controller", "move_right_controller", "move_up_controller", "move_down_controller")
	return move_input

## Wrapper
func get_aim_input() -> Vector2:
	return get_aim_input_func.call()

## Returns raw input data, not normalized
func get_aim_input_controller() -> Vector2: 
	aim_input = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	return aim_input

func get_aim_input_mouse() -> Vector2: 
	aim_input = get_owner().global_position.direction_to(get_global_mouse_position())
	return aim_input

func _process(delta):
	if primary_action_pressed:
		primary_action_charge += delta

	if upgrade_action_pressed:
		upgrade_action_charge += delta * tower_action_press_multiplier
		
	# Build Phase Button input data
	if start_wave_action_pressed:
		start_wave_action_charge += (delta * START_WAVE_ACTION_CHARGE_MULTIPLIER)
		start_wave_action_charge_updated.emit(start_wave_action_charge)
		if start_wave_action_charge >= 100:
			WaveManager.start_wave()
			start_wave_action_charge = 0
			start_wave_action_pressed = false

	elif not start_wave_action_pressed and start_wave_action_charge > 0:
		start_wave_action_charge = max(0, start_wave_action_charge - (delta * START_WAVE_ACTION_DISCHARGE_MULTIPLIER))
		start_wave_action_charge_updated.emit(start_wave_action_charge)
	
	if heal_all_action_pressed:
		heal_all_action_charge += (delta * HEAL_ALL_ACTION_CHARGE_MULTIPLIER)
		heal_all_action_charge_updated.emit(heal_all_action_charge)

	elif not heal_all_action_pressed and heal_all_action_charge > 0:
		heal_all_action_charge = max(0, heal_all_action_charge - (delta * HEAL_ALL_ACTION_DISCHARGE_MULTIPLIER))
		heal_all_action_charge_updated.emit(heal_all_action_charge)

func _input(event):
	if input_enabled:
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

		if event.is_action("weapon_select_0") and event.is_pressed() and not event.is_echo():
			weapon_select_pressed.emit(0)
		
		if event.is_action("weapon_select_1") and event.is_pressed() and not event.is_echo():
			weapon_select_pressed.emit(1)
		
		if event.is_action("weapon_select_2") and event.is_pressed() and not event.is_echo():
			weapon_select_pressed.emit(2)
		
		if event.is_action("weapon_select_3") and event.is_pressed() and not event.is_echo():
			weapon_select_pressed.emit(3)

		if event.is_action("start_wave_action") and event.is_pressed() and WaveManager.can_start_wave:
			start_wave_action_pressed = true

		if event.is_action("start_wave_action") and event.is_released():
			start_wave_action_pressed = false

		if event.is_action("heal_all_action") and event.is_pressed():
			heal_all_action_pressed = true

		if event.is_action("heal_all_action") and event.is_released():
			heal_all_action_pressed = false 

		if event.is_action("escape") and event.is_pressed() and not event.is_echo():
			escape_pressed.emit()

		set_input_type(event)

func check_primary_action_input(event) -> void:
	if Input.is_action_just_pressed("primary_action"):
		primary_action_pressed = true
		primary_action_just_pressed.emit()

	if event.is_action_released("primary_action"):
		primary_action_pressed = false
		primary_action_charge = 0
		primary_action_released.emit()

func check_upgrade_action_input(event) -> void:
	if Input.is_action_just_pressed("upgrade_action"):
		upgrade_action_pressed = true

	if event.is_action_released("upgrade_action"):
		upgrade_action_pressed = false
		upgrade_action_charge = 0

## Set the input type between controller or keyboard, based on the latest input
func set_input_type(event) -> void:
	if (event is InputEventMouse or event is InputEventKey) and GlobalSettings.controller_active: # Switch to mouse
		GlobalSettings.controller_active = false
		swap_input_type()

	elif event is InputEventJoypadMotion and not GlobalSettings.controller_active: # Switch to controller
		var movement_joystick_input_strength = Input.get_vector("move_left_controller", "move_right_controller", "move_up_controller", "move_down_controller", 0.0)
		var aim_joystick_input_strength = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down", 0.0)

		if abs(movement_joystick_input_strength) > Vector2(.2, .2) or aim_joystick_input_strength > Vector2(.2, .2):
			GlobalSettings.controller_active = true			
			swap_input_type()

## `true` = controller active, 'false' = mouse active
func swap_input_type() -> void:
	print(GlobalSettings.controller_active)
	if GlobalSettings.controller_active:
		get_aim_input_func = get_aim_input_controller
		get_move_input_func = get_move_input_controller
	else:
		get_aim_input_func = get_aim_input_mouse
		get_move_input_func = get_move_input_keyboard

func get_controller_info() -> void:
	var connected_joypads = Input.get_connected_joypads()
	for device_id in connected_joypads:
		var joy_name = Input.get_joy_name(device_id)
		print("Joypad ", device_id, " name: ", joy_name)

func null_func() -> Vector2:
	return Vector2.ZERO