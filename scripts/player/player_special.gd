class_name PlayerSpecial
extends Node

var active: bool = false
@onready var player: PlayerCharacter = get_owner()

# Go into data file eventually
@export var dash_velocity: float = 250.0
@export var dash_duration: float = .1

var after_image_scene: PackedScene = preload("res://scenes/player/PlayerAfterImage.tscn")
# This should always remain at 0, it is just a counter var
var after_image_create_time_count: float = 0

# How long between spawning afterimages
var dash_after_image_create_time: float = .01
# How long an afterimage lasts before despawning
var dash_after_image_lifetime: float = .15
# Random jitter min and max (so if value is 3 range will be -3 to 3)
var dash_after_image_position_jitter_range: float = 0

const SHADOW_DURATION: float = 1.4
var shadow_after_image_create_time: float = .001
var shadow_after_image_lifetime: float = .2
var shadow_after_image_position_jitter_range: float = 30

var player_clone_scene: PackedScene = preload("res://scenes/player/PlayerClone.tscn")
var player_scene: PackedScene = preload("res://scenes/player/PlayerCharacter.tscn")

var clone: PlayerClone
const CLONE_RESET_DURATION: float = 12.0

signal camera_shake_requested
signal hurtbox_update_requested
signal special_charge_sprite_update_requested
signal player_special_activated

var special_func: Callable = dash
var after_image_func: Callable = dash_run_after_image
var special_cooldown_timer: Timer = Timer.new()

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	special_cooldown_timer.autostart = false
	special_cooldown_timer.one_shot = true
	special_cooldown_timer.timeout.connect(on_special_cooldown_timeout)
	add_child(special_cooldown_timer)

func _physics_process(delta):
	if active:
		after_image_func.call(delta)

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
	
	AudioManager.create_2d_audio_at_location(player.global_position, SoundEffect.SOUND_EFFECT_TYPE.DASH)

	# var boost_velocity: Vector2 = player.velocity + (Vector2(dash_velocity*.25, dash_velocity*.25) * direction)
	player.velocity = player.velocity + (Vector2(200, 200) * direction)
	var target: Vector2 = player.velocity + (Vector2(dash_velocity, dash_velocity) * direction)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(player, "velocity", target, dash_duration)
	player_special_activated.emit()
	await tween.finished
	active = false
	await get_tree().create_timer(.5).timeout
	hurtbox_update_requested.emit(false)
	player.set_collision_mask_value(28, true)

func create_after_image(after_image_lifetime, after_image_position_jitter_range) -> void:
	var new_after_image: PlayerAfterImage = after_image_scene.instantiate()
	new_after_image.texture = player.character_sprite.texture
	new_after_image.vframes = player.character_sprite.vframes
	new_after_image.hframes = player.character_sprite.hframes
	new_after_image.frame = player.character_sprite.frame
	new_after_image.scale = Vector2(1,1)
	new_after_image.z_index = player.character_sprite.z_index - 1

	new_after_image.global_position = player.character_sprite.global_position
	new_after_image.global_position += Vector2(rng.randf_range(-after_image_position_jitter_range,after_image_position_jitter_range), rng.randf_range(-after_image_position_jitter_range,after_image_position_jitter_range))

	new_after_image.lifetime = after_image_lifetime
	add_child(new_after_image)	

func dash_run_after_image(delta: float) -> void:
	after_image_create_time_count += delta
	if after_image_create_time_count >= dash_after_image_create_time:
		after_image_create_time_count = 0
		create_after_image(dash_after_image_lifetime, dash_after_image_position_jitter_range)

func shadow_run_after_image(delta: float) -> void:
	after_image_create_time_count += delta
	if after_image_create_time_count >= dash_after_image_create_time:
		after_image_create_time_count = 0
		create_after_image(shadow_after_image_lifetime, shadow_after_image_position_jitter_range)
		create_after_image(shadow_after_image_lifetime, shadow_after_image_position_jitter_range)

func shadow(_move_input: Vector2=Vector2.ZERO, _aim_input: Vector2=Vector2.ZERO) -> void:
	active = true
	player.can_fire = false
	player.graphics_parent.hide()

	await get_tree().create_timer(SHADOW_DURATION).timeout
	player.graphics_parent.show()
	player.can_fire = true
	active = false 

## Spawn or remove clone, based on whether one already exists. _move_input and _aim_input and not used.
func spawn_clone(_move_input: Vector2=Vector2.ZERO, _aim_input: Vector2=Vector2.ZERO) -> void:
	if not clone: # Spawn a new clone
		clone = player_clone_scene.instantiate()
		clone.global_position = player.global_position
		clone.player = player
		add_child(clone)

		player.player_spell_spawner.spell_spawn_points.append(clone.spell_spawn_point)
		player.player_spell_spawner.melee_spell_spawn_points.append(clone)
		player.player_spell_spawner.shield_spell_spawn_points.append(clone)
		
		player.player_spell_spawner.staff_switched.connect(clone.on_staff_switched)
		player.player_spell_spawner.melee_spell_cast.connect(clone.swing_staff)
		player.spell_cast.connect(clone.on_spell_cast)

		clone.reset_timer.start(CLONE_RESET_DURATION)
		clone.reset_timer.timeout.connect(spawn_clone)
	
	else:   	# Remove active clone
		player.global_position = clone.global_position

		var index: int = player.player_spell_spawner.spell_spawn_points.find(clone.spell_spawn_point)
		var index_2: int = player.player_spell_spawner.melee_spell_spawn_points.find(clone)
		var index_3: int = player.player_spell_spawner.shield_spell_spawn_points.find(clone)

		if index != -1: player.player_spell_spawner.spell_spawn_points.remove_at(index)
		if index_2 != -1: player.player_spell_spawner.melee_spell_spawn_points.remove_at(index_2)
		if index_3 != -1: player.player_spell_spawner.shield_spell_spawn_points.remove_at(index_3)

		clone.reset_timer.stop()
		clone.reset_timer.timeout.disconnect(spawn_clone)

		clone.queue_free()
		clone = null
	player_special_activated.emit()

func on_special_cooldown_timeout() -> void:
	player.player_stats.special_charges = player.player_stats.special_charges_max
	special_charge_sprite_update_requested.emit(player.player_stats.special_charges)
