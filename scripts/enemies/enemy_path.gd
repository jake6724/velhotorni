class_name EnemyPath
extends Path2D

func get_return_point(enemy_global_position, enemy_exit_point) -> Vector2:
	var start_point: Vector2 = get_closest_point(enemy_exit_point)
	var start_idx: int = curve.get_baked_points().find(start_point)
	var valid_return_points: PackedVector2Array = curve.get_baked_points().slice(start_idx)
	
	var min_distance: float = enemy_global_position.distance_to(start_point) # Return to exit point by default
	var return_point: Vector2 = start_point
	for point: Vector2 in valid_return_points:
		var new_distance: float = enemy_global_position.distance_to(point)
		if new_distance < min_distance:
			min_distance = new_distance
			return_point = point

	return return_point

func get_return_point_progress_ratio(return_point: Vector2) -> float:
	var return_point_progress_ratio: float
	return_point_progress_ratio = curve.get_closest_offset(return_point) / curve.get_baked_length()
	return return_point_progress_ratio

## Returns the closest point on the `EnemyPath`'s Curve2D object to `to_point`. This method guarantees that the 
## returned point exists within `EnemyPath.curve.get_baked_points()`
func get_closest_point(to_point: Vector2) -> Vector2:
	var minimum_distance: float = INF
	var closest_point: Vector2

	for point: Vector2 in curve.get_baked_points():
		var distance: float = point.distance_squared_to(to_local(to_point))
		if distance < minimum_distance:
			minimum_distance = distance
			closest_point = point
	
	return closest_point
