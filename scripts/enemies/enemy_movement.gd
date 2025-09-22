class_name EnemyMovement
extends Node2D

# TODO: DEV ONLY
var pathfinder_debug_line = Line2D.new()
@onready var debug_parent = %EnemyMovementDebugParent

var direction: Vector2
var path_to_player: PackedVector2Array
var path_to_player_index: int = 0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
var next_path_position
var frame_count: int = 0
var desired_frame: int = 10

## Handles enemy movement. Each function takes the same standard args, which are passed in parent enemy's _physics_process

signal animation_requested
signal sprite_flip_requested
signal global_position_change_requested
signal attach_to_path_requested
signal damage_base_requested
signal death_requested
signal attack_requested

func _ready():
	#debug_parent.add_child(pathfinder_debug_line)
	pathfinder_debug_line.width = 1
	pathfinder_debug_line.default_color = Color.RED

func move_along_path(delta: float, speed: float, slow_percent: float, is_alive: bool, is_frozen: bool,
is_stunned: bool, is_taking_damage: bool, _enemy_global_position: Vector2, _path_exit_position: Vector2,
_return_point: Vector2, _player: PlayerCharacter, _path_follow: PathFollow2D, _path: Path2D, _is_attacking) -> void:

	if is_alive:
		if not is_frozen and not is_stunned:
			if not is_taking_damage:
				animation_requested.emit("walk")

			sprite_flip_requested.emit(_path_follow.rotation_degrees >= 91)
				
			if _path_follow.progress_ratio < .99:
				_path_follow.progress += (speed - ((speed * (slow_percent/100)))) * delta
			else:
				damage_base_requested.emit()
				death_requested.emit()
		else:
			animation_requested.emit("idle")

func move_to_path(delta: float, speed: float, slow_percent: float, is_alive: bool, is_frozen: bool,
is_stunned: bool, is_taking_damage: bool, _enemy_global_position: Vector2, _path_exit_position: Vector2,
_return_point: Vector2, _player: PlayerCharacter, _path_follow: PathFollow2D, _path: Path2D, _is_attacking) -> void:

	direction = _enemy_global_position.direction_to(_return_point)
	if is_alive:
		if not is_frozen and not is_stunned:
			if not is_taking_damage:
				animation_requested.emit("walk")

			sprite_flip_requested.emit(direction.x < .5)

			var global_position_change: Vector2 = ((speed - ((speed * (slow_percent/100)))) * delta) * direction
			global_position_change_requested.emit(global_position_change)

		# Check if enemy should reattach to path
		if _enemy_global_position.distance_to(_return_point) <= 2:
			attach_to_path_requested.emit()

func move_to_player(delta: float, speed: float, slow_percent: float, is_alive: bool, is_frozen: bool,
is_stunned: bool, is_taking_damage: bool, _enemy_global_position: Vector2, _path_exit_position: Vector2,
_return_point: Vector2, _player: PlayerCharacter, _path_follow: PathFollow2D, _path: Path2D, _is_attacking) -> void:

	# print(_enemy_global_position.distance_to(_player.global_position))
	# if _enemy_global_position.distance_to(_player.global_position) < 20:
	# 	if not _is_attacking:
	# 		print("test")
	# 		enemy_attack_requested.emit(true)
	# 		animation_requested.emit("wind_up")

	# 	return
	
	# if not _is_attacking:


	if path_to_player.size() > 1:
		direction = _enemy_global_position.direction_to(path_to_player[path_to_player_index])
		if _enemy_global_position.distance_squared_to(path_to_player[path_to_player_index]) < 16:
			path_to_player_index += 1
	else:
		direction = _enemy_global_position.direction_to(_player.global_position)

	pathfinder_debug_line.points = path_to_player

	if is_alive:
		if not is_frozen and not is_stunned:
			if not is_taking_damage:
				animation_requested.emit("walk")

			sprite_flip_requested.emit(direction.x < .5)

			var global_position_change: Vector2 = ((speed - ((speed * (slow_percent/100)))) * delta) * direction
			global_position_change_requested.emit(global_position_change)

func update_path_to_player(_enemy_global_position: Vector2, _player_global_position, _pathfinder: PathFinder) -> void:
	var new_path_to_player = _pathfinder.get_astar_path(WorldGrid.world_to_grid(_enemy_global_position), WorldGrid.world_to_grid(_player_global_position))
	
	if new_path_to_player != path_to_player: # Only update path if it is different than current, prevents losing progress
		if path_to_player:
			path_to_player[0] = _enemy_global_position

		path_to_player_index = 1
		path_to_player = new_path_to_player

# func move_to_player(delta: float, speed: float, slow_percent: float, is_alive: bool, is_frozen: bool,
# is_stunned: bool, is_taking_damage: bool, _enemy_global_position: Vector2, _path_exit_position: Vector2,
# _return_point: Vector2, _player: PlayerCharacter, _path_follow: PathFollow2D, _path: Path2D) -> void:
	
# 	# if frame_count == desired_frame:
# 	# 	frame_count = 0
# 	# 	next_path_position = nav_agent.get_next_path_position()
# 	# else:
# 	# 	frame_count += 1

# 	next_path_position = nav_agent.get_next_path_position()

# 	if nav_agent.is_navigation_finished():
# 		print("FINISHED")
# 		return

# 	direction = _enemy_global_position.direction_to(next_path_position)
# 	print(direction)
# 	var global_position_change = ((speed - ((speed * (slow_percent/100)))) * delta) * direction
# 	global_position_change_requested.emit(global_position_change)

# func update_path_to_player(_player_global_position) -> void:
# 	if _player_global_position:
# 		print("CREATING NEW PATH")
# 		nav_agent.target_position = _player_global_position
# 		next_path_position = nav_agent.get_next_path_position()
