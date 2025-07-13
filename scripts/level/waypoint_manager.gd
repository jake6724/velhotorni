class_name WaypointManager
extends Node2D

func _ready():
	hide()

func get_waypoint_path() -> PackedVector2Array:
	var waypoint_path: PackedVector2Array

	for child in get_children():
		waypoint_path.append(GameManager.world_to_grid(child.position)) # Does world to grid because that is the original implementation for manually entered paths

	return waypoint_path
