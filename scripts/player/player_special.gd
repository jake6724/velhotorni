class_name PlayerSpecial
extends Node

var active: bool = false
@onready var player: PlayerCharacter = get_owner()

# Go into data file eventually
@export var dash_velocity: float = 250.0
@export var dash_duration: float = .1

var charge_max: int = 3
var charges: int = 3
var charge_cooldown_duration: float = 1

signal velocity_update_requested
signal camera_shake_requested
signal hurtbox_update_requested
signal special_charge_sprite_update_requested
signal special_animation_requested

var special_func: Callable = Callable(dash)
var special_cooldown_timer: Timer = Timer.new()

func _ready():
	special_cooldown_timer.autostart = false
	special_cooldown_timer.one_shot = true
	special_cooldown_timer.timeout.connect(on_special_cooldown_timeout)
	add_child(special_cooldown_timer)

func special(_move_input: Vector2, _aim_input: Vector2) -> void:
	if charges > 0:	
		active = true
		charges -= 1
		special_func.call(_move_input, _aim_input)
		special_charge_sprite_update_requested.emit(charges)
		special_cooldown_timer.start(charge_cooldown_duration) # wrong probably

func dash(_move_input: Vector2, _aim_input: Vector2) -> void:
	camera_shake_requested.emit(1)
	hurtbox_update_requested.emit(true)
	var direction: Vector2
	if _move_input:
		direction = Constants.get_closest_cardinal_direction_normalized(_move_input)
	elif _aim_input:
		direction = Constants.get_closest_cardinal_direction_normalized(_aim_input)
	else:
		direction = Vector2(1,0)
		
	# var boost_velocity: Vector2 = player.velocity + (Vector2(dash_velocity*.25, dash_velocity*.25) * direction)
	player.velocity = player.velocity + (Vector2(200, 200) * direction)
	var target: Vector2 = player.velocity + (Vector2(dash_velocity, dash_velocity) * direction)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(player, "velocity", target, dash_duration)

	await tween.finished
	active = false

	# if _move_input:	
	# 	velocity_update_requested.emit(Constants.get_closest_cardinal_direction_normalized(_move_input) * dash_velocity)
	# elif _aim_input:
	# 	velocity_update_requested.emit(Constants.get_closest_cardinal_direction_normalized(_aim_input) * dash_velocity)
	# else:
	# 	velocity_update_requested.emit(Vector2(1,0) * dash_velocity)

func on_special_cooldown_timeout() -> void:
	charges += 1
	special_charge_sprite_update_requested.emit(charges)
	if charges < charge_max:
		special_cooldown_timer.start(charge_cooldown_duration)
	else:
		special_cooldown_timer.stop()
