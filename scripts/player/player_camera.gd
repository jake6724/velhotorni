class_name PlayerCamera
extends Camera2D

@export var power: float
@export var decay: float 

@onready var player: PlayerCharacter = get_owner()

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var curr_power: float
var shake_offset: Vector2 = Vector2.ZERO

var aim_follow_offset: Vector2 = Vector2.ZERO
var aim_follow_multiplier: float = 40.0
var aim_follow_speed: float = .3
var prev_aim_input: Vector2 = Vector2(INF, INF)

var look_ahead_func: Callable = look_ahead_mouse

const MOUSE_LOOK_AHEAD_SCALE: float = .15

func _ready():
	position_smoothing_enabled = true
	position_smoothing_speed = 8.0

func apply_shake(power_scale: float) -> void:
	var new_power: float = power * power_scale
	if new_power >= curr_power:
		curr_power = new_power

func _process(delta):
	if not player.building:
		look_ahead_func.call()
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "aim_follow_offset", Vector2(0,0), aim_follow_speed)

	# Handle camera shake if power left
	if curr_power > .1:
		curr_power = snappedf(lerpf(curr_power, 0, decay * delta), 0.01)
		shake_offset = get_random_offset()
	else:
		shake_offset = Vector2.ZERO

	#print(aim_follow_offset)
	offset = shake_offset + aim_follow_offset

func look_ahead_controller() -> void:
	if player.player_aim.aim_input != prev_aim_input:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "aim_follow_offset", (player.player_aim.aim_input * aim_follow_multiplier), aim_follow_speed)
		prev_aim_input = player.player_aim.aim_input

## Mouse-based look ahead is based on the direction and distance of the mouse compared to the player, multiplied by a 
## scaling constant which determines how far out the camera moves
func look_ahead_mouse() -> void:
	aim_follow_offset = (player.global_position.direction_to(get_global_mouse_position())
	* (player.global_position.distance_to(get_global_mouse_position()) * MOUSE_LOOK_AHEAD_SCALE))

## Used in camera shake
func get_random_offset() -> Vector2:
	return Vector2(rng.randf_range(-curr_power, curr_power), rng.randf_range(-curr_power, curr_power))

func swap_input_type() -> void:
	if GlobalSettings.controller_active:
		look_ahead_func = look_ahead_controller
	else:
		look_ahead_func = look_ahead_mouse
