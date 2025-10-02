class_name PlayerAim
extends Node2D

@onready var player: PlayerCharacter = get_owner()

const RETICLE_MAX_DISTANCE: float = 65

## The total duration of the tween_property call used to update the reticle's position, in seconds
const RETICLE_SPEED: float = .1
const RETICLE_MIN_MAGNITUDE: float = .3
const RETICLE_RESET_TIMER_DELAY: float = .25
const RETICLE_RESET_POSITION_DURATION: float = 3

const SWING_DEGREE_INCREMENT: float = 180.0
const SWING_DURATION: float = .01

const SPELL_SPAWN_POINT_DISTANCE: float = 12.0

## Controls how quickly the reticles moves back toward the player when no input is given
## Higher values will make the reticle move faster
@export var reset_speed_modifier: float = .65

var aim_input: Vector2 # Manually set by PlayerCharacter
var resetting_reticle: bool = false

var staff_rotation_offset_degrees: float = 0.0
var is_swinging: bool = false

var staff_rotation_sign: float = 1.0

func update_aim():
	update_spell_spawn_point()
	update_reticle()
	flip_sprite()
	rotate_staff()

# TODO: 
"""
When in melee mode, base the reticle position off the center of the player instead of the exact position of the spell
spawner. Maybe have multiple funcs and func ref for the update_reticle func
"""

func update_spell_spawn_point() -> void:
	if aim_input:
		player.spell_spawn_point.global_position = player.global_position + (aim_input.normalized() * SPELL_SPAWN_POINT_DISTANCE)
	
func update_reticle() -> void:
	if !aim_input:
		player.reticle_sprite.position = Vector2.ZERO
		return

	if aim_input.length() < RETICLE_MIN_MAGNITUDE:
		aim_input = aim_input.normalized() * RETICLE_MIN_MAGNITUDE

	var reticle_tween: Tween = get_tree().create_tween()

	# Position reticle based on spell_spawn_point position and aim_inputs UNORMALIZED value
	var target_position: Vector2 = player.spell_spawn_point.global_position + (aim_input * RETICLE_MAX_DISTANCE)
	reticle_tween.tween_property(player.reticle_sprite, "global_position", target_position, RETICLE_SPEED)

func reset_reticle_position(delta) -> void:
	aim_input -= aim_input.normalized() * delta * reset_speed_modifier
	
func rotate_staff() -> void:
	if aim_input and not is_swinging:
		# Rotate staff to point at aim direction
		# Melee version
		player.staff_sprite.rotation = aim_input.angle() + deg_to_rad(staff_rotation_offset_degrees) * staff_rotation_sign

		#player.staff_sprite.rotation = aim_input.angle() + deg_to_rad(staff_rotation_offset_degrees) # TODO: Could specify in rads to start

		# Set staff render order based on aim direction and horizontal axis
		if aim_input.normalized().y < 0:
			player.staff_sprite.z_index = player.character_sprite.z_index - 1
		else:
			player.staff_sprite.z_index = player.character_sprite.z_index + 1

	# Render staff behind player if moving up in all cases
	if player.velocity.y < 0:
		player.staff_sprite.z_index = player.character_sprite.z_index - 1

func swing_staff() -> void:
	staff_rotation_sign = -staff_rotation_sign
	var tween: Tween = get_tree().create_tween()
	var target = player.staff_sprite.rotation_degrees + SWING_DEGREE_INCREMENT
	tween.tween_property(player.staff_sprite, "rotation_degrees", target, .01)

func flip_sprite() -> void:
	if aim_input:
		var flip = aim_input.x <= -0.001
		player.character_sprite.flip_h = flip

# func _process(delta):
# 	queue_redraw()

# func _draw():
# 	draw_circle(to_local(player.spell_spawn_point.global_position), 5, Color.RED, true)
