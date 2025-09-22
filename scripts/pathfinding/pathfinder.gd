class_name PathFinder
extends Node

var a_star = AStarGrid2D.new()

## PathFinder MUST be initialized after WorldGrid
func initialize():
	a_star.cell_size = Vector2i(16,16)
	a_star.region = Rect2(0, 0, WorldGrid.dimensions.x, WorldGrid.dimensions.y)
	a_star.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	a_star.update()
	set_path_weights()

## Set the weights of all points in WorldGrid. Solid points are untraversable. 
## `AStarGrid2D.update()` is NOT required after calling this, infact it will erase all information
func set_path_weights(): 
	for grid_point: Vector2 in WorldGrid.data:
		if WorldGrid.data[grid_point] == WorldGrid.TileType.OCCUPIED:
			a_star.set_point_solid(grid_point)

## Main interface for the pathfinder. Returned point seems to be in world format?
func get_astar_path(grid_pos_a: Vector2, grid_pos_b: Vector2) -> PackedVector2Array:
	return a_star.get_point_path(grid_pos_a, grid_pos_b)