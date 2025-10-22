class_name PlayerSpecial
extends Node

var active: bool = false
@onready var player: PlayerCharacter = get_owner()

# Go into data file eventually
@export var dash_velocity: float = 250.0
@export var dash_duration: float = .1

var charge_max: int = 3
var charges: int = 3
var charge_cooldown_duration: float = 2

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
		special_cooldown_timer.start(charge_cooldown_duration)

func dash(_move_input: Vector2, _aim_input: Vector2) -> void:
	camera_shake_requested.emit(1)
	hurtbox_update_requested.emit(true)
	player.set_collision_mask_value(28, false)
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
	await get_tree().create_timer(.5).timeout
	hurtbox_update_requested.emit(false)
	player.set_collision_mask_value(28, true)

func on_special_cooldown_timeout() -> void:
	charges = charge_max
	special_charge_sprite_update_requested.emit(charges)