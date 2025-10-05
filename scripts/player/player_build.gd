class_name PlayerBuild
extends Node

const TOWER_PLACEMENT_RANGE = 16

var tower_scene: PackedScene = preload("res://scenes/towers/Tower.tscn")
var preview_tower: Tower
var tower_element_options: Array[Constants.Element] = [
Constants.Element.FIRE, Constants.Element.WIND, 
Constants.Element.WATER, Constants.Element.EARTH,
Constants.Element.LIGHT, Constants.Element.DARK]

var tower_index: int = 0: 
	set(value):
		tower_index = value
		if tower_index < 0:
			tower_index = 5
		elif tower_index > 5:
			tower_index = 0

## Creates a new instance of `tower_scene`, fully initialized. Modulated to be transparent.
## This is an active and ready tower that just needs to be placed.
func create_preview_tower():
	# Reset previous selection
	preview_tower = tower_scene.instantiate()
	add_child(preview_tower)
	preview_tower.initialize(tower_element_options[tower_index])
	preview_tower.attack_collider.set_deferred("disabled", true)
	preview_tower.modulate.a = .75

## Update the `global_position` of `preview_tower`, which is calculated based on
## the position of `PlayerCharacter` and the current `aim_input`
func update_preview_tower_position(player_global_position: Vector2, aim_input: Vector2) -> void:
	aim_input = Constants.get_closest_cardinal_direction_normalized(aim_input)
	var preview_tower_grid_position = WorldGrid.world_to_grid(player_global_position + (aim_input * TOWER_PLACEMENT_RANGE))
	preview_tower.global_position = WorldGrid.grid_to_world(preview_tower_grid_position)

	#preview_tower.global_position = WorldGrid.grid_to_world(WorldGrid.world_to_grid(player_global_position + (aim_input* 16)))

func place_tower() -> void:	
	# Check if placement position is valid
	var tower_grid_position: Vector2 = WorldGrid.world_to_grid(preview_tower.global_position)

	if tower_grid_position in WorldGrid.data and WorldGrid.data[tower_grid_position]:
		preview_tower.modulate.a = 1
		preview_tower.attack_collider.set_deferred("disabled", false)
		# Update WorldGrid
		WorldGrid.data[tower_grid_position] = false

		# Get a new preview tower
		create_preview_tower() # TODO: This needs to be the currently selected type
