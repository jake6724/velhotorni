class_name PlayerSpecial
extends Node

var active: bool = false
@onready var player: PlayerCharacter = get_owner()

# Go into data file eventually
@export var dash_velocity: float = 250.0
@export var dash_duration: float = .1

var player_clone_scene: PackedScene = preload("res://scenes/player/PlayerClone.tscn")
var player_scene: PackedScene = preload("res://scenes/player/PlayerCharacter.tscn")

var clone: PlayerClone

signal camera_shake_requested
signal hurtbox_update_requested
signal special_charge_sprite_update_requested

var special_func: Callable = spawn_clone
var special_cooldown_timer: Timer = Timer.new()

func _ready():
	special_cooldown_timer.autostart = false
	special_cooldown_timer.one_shot = true
	special_cooldown_timer.timeout.connect(on_special_cooldown_timeout)
	add_child(special_cooldown_timer)

func special(_move_input: Vector2, _aim_input: Vector2) -> void:
	if player.player_stats.special_charges > 0:	
		player.player_stats.special_charges -= 1
		special_func.call(_move_input, _aim_input)
		special_charge_sprite_update_requested.emit(player.player_stats.special_charges)
		special_cooldown_timer.start(player.player_stats.special_charge_cooldown_duration)

func dash(_move_input: Vector2, _aim_input: Vector2) -> void:
	active = true
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

func spawn_clone(_move_input: Vector2, _aim_input: Vector2) -> void:
	if not clone:
		clone = player_clone_scene.instantiate()
		clone.global_position = player.global_position
		clone.player = player
		add_child(clone)
		player.player_spell_spawner.spell_spawn_points.append(clone.spell_spawn_point)
		player.player_spell_spawner.melee_spell_spawn_points.append(clone)
		player.player_spell_spawner.staff_switched.connect(clone.on_staff_switched)
		player.player_spell_spawner.melee_spell_cast.connect(clone.swing_staff)
		player.spell_cast.connect(clone.on_spell_cast)
	
	else:
		player.global_position = clone.global_position
		var index: int = player.player_spell_spawner.spell_spawn_points.find(clone.spell_spawn_point)
		var index_2: int = player.player_spell_spawner.melee_spell_spawn_points.find(clone)
		if index != -1: player.player_spell_spawner.spell_spawn_points.remove_at(index)
		if index_2 != -1: player.player_spell_spawner.melee_spell_spawn_points.remove_at(index_2)

		clone.queue_free()
		clone = null

func on_special_cooldown_timeout() -> void:
	player.player_stats.special_charges = player.player_stats.special_charges_max
	special_charge_sprite_update_requested.emit(player.player_stats.special_charges)
