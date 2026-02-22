class_name PitAreaPolygon
extends Area2D

@onready var fall_node_parent: Node = $FallNodeParent

func get_closest_fall_position(_received_pos: Vector2) -> Vector2:
	var min_distance: float = float(INF)
	var closest_position: Vector2 = Vector2.ZERO
	for fall_node in fall_node_parent.get_children():
		var _distance: float = fall_node.global_position.distance_squared_to(_received_pos)
		if _distance < min_distance:
			min_distance = _distance
			closest_position = fall_node.global_position
	return closest_position
