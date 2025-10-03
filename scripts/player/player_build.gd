class_name PlayerBuild
extends Node

var tower_scene: PackedScene = preload("res://scenes/towers/Tower.tscn")
var preview_tower: Tower

## Creates a new instance of `tower_scene`, fully initialized. Modulated to be transparent.
## This is an active and ready tower that just needs to be placed.
func create_preview_tower(element: Constants.Element):
	# Reset previous selection
	preview_tower = tower_scene.instantiate()
	add_child(preview_tower)
	preview_tower.initialize(element)
	preview_tower.modulate.a = .75

## Update the `global_position` of `preview_tower`, which is calculated based on
## the position of `PlayerCharacter` and the current `aim_input`
func update_preview_tower_position(player_global_position: Vector2, aim_input: Vector2) -> void:
	aim_input = Constants.get_closest_cardinal_direction_normalized(aim_input)
	var preview_tower_grid_position = WorldGrid.world_to_grid(player_global_position + (aim_input * 16))
	preview_tower.global_position = WorldGrid.grid_to_world(preview_tower_grid_position)

	#preview_tower.global_position = WorldGrid.grid_to_world(WorldGrid.world_to_grid(player_global_position + (aim_input* 16)))

func place_tower() -> void:	
	# Check if placement position is valid
	var tower_grid_position: Vector2 = WorldGrid.world_to_grid(preview_tower.global_position)

	if tower_grid_position in WorldGrid.data and WorldGrid.data[tower_grid_position]:
		preview_tower.modulate.a = 1
	
		# Update WorldGrid
		WorldGrid.data[tower_grid_position] = false

		# Get a new preview tower
		create_preview_tower(Constants.Element.FIRE) # TODO: This needs to be the currently selected type