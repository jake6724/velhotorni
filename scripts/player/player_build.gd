class_name PlayerBuild
extends Node2D

@export var grid_follow_tower: bool = true # Debugging, should go awawy

var tower_parent: Node = Node.new()

var active_towers: Array[Tower] = []

var player_build_ui: PlayerBuildUI # Set by PlayerCharacter
var build_grid_sprite: Sprite2D # Set by PlayerCharacter
var tower_detect_area: Area2D # Set by PlayerCharacter
var tower_to_upgrade: Tower

const TOWER_PLACEMENT_RANGE: int = 16

var tower_scene: PackedScene = preload("res://scenes/towers/Tower.tscn")
var preview_tower: Tower
var preview_tower_grid_position: Vector2
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

		player_build_ui.tower_index = tower_index

signal tower_mana_spent

func _ready():
	add_child(tower_parent)

func initialize(_player_build_ui: PlayerBuildUI, _build_grid_sprite: Sprite2D, _tower_detect_area: Area2D) -> void:
	player_build_ui = _player_build_ui
	build_grid_sprite = _build_grid_sprite
	tower_detect_area = _tower_detect_area
	tower_detect_area.area_entered.connect(on_tower_detect_area_entered)
	tower_detect_area.area_exited.connect(on_tower_detect_area_exited)

func show_active_tower_ranges(_value: bool) -> void:
	for tower: Tower in active_towers:
		tower.can_show_range = _value

func run(_delta, player_input: PlayerInput, player_mana: PlayerMana, upgrade_action_charge_cirlce: TextureProgressBar) -> void:
	if player_input.upgrade_action_charge and tower_to_upgrade:
		if check_can_ugprade(player_mana.tower_mana):
			upgrade_action_charge_cirlce.show()
			upgrade_action_charge_cirlce.value = player_input.upgrade_action_charge * 100
			if player_input.upgrade_action_charge >= 1:
				upgrade_tower()
				player_input.upgrade_action_charge = 0
				player_input.upgrade_action_pressed = false
	else:
		upgrade_action_charge_cirlce.hide()
		upgrade_action_charge_cirlce.value = 0

## Creates a new instance of `tower_scene`, fully initialized. Modulated to be transparent.
## This is an active and ready tower that just needs to be placed.
func create_preview_tower():
	# Reset previous selection
	preview_tower = tower_scene.instantiate()
	tower_parent.add_child(preview_tower)
	preview_tower.initialize(tower_element_options[tower_index])
	preview_tower.attack_collider.set_deferred("disabled", true)
	preview_tower.transform_collider.set_deferred("disabled", true)
	preview_tower.buff_collider.set_deferred("disabled", true)
	preview_tower.modulate.a = .75
	preview_tower.can_show_range = true	

	if not tower_to_upgrade:
		player_build_ui.update_tower_info_panel(preview_tower)
		preview_tower.show()
	else:
		preview_tower.hide()

## Update the `global_position` of `preview_tower`, which is calculated based on
## the position of `PlayerCharacter` and the current `aim_input`
func update_preview_tower_position(player_global_position: Vector2, aim_input: Vector2) -> void:
	aim_input = Constants.get_closest_cardinal_4_direction_normalized(aim_input)
	preview_tower_grid_position = WorldGrid.world_to_grid(player_global_position + (aim_input * TOWER_PLACEMENT_RANGE))
	preview_tower.global_position = WorldGrid.grid_to_world(preview_tower_grid_position)

	var target: Vector2
	if not grid_follow_tower:
		target = WorldGrid.grid_to_world(WorldGrid.world_to_grid(player_global_position)) + Vector2(8,8)
	else:
		target = preview_tower.global_position + Vector2(8,8)

	build_grid_sprite.global_position = target

func update_tower_detect_area_position() -> void:
	tower_detect_area.global_position = build_grid_sprite.global_position

## Check if placement is valid and place `preview_tower`. Update `WorldGrid` and `preview_tower` accordingly.
func place_tower(_tower_mana: float) -> void:	
	# Check can afford
	var cost: int = TowerGlobalData.tower_prices[preview_tower.data.element]
	if _tower_mana >= cost:

		# Check if placement position is valid
		var tower_grid_position: Vector2 = WorldGrid.world_to_grid(preview_tower.global_position)
		if tower_grid_position in WorldGrid.data and WorldGrid.data[tower_grid_position]:
			preview_tower.modulate.a = 1
			preview_tower.can_show_range = false
			preview_tower.attack_collider.set_deferred("disabled", false)
			preview_tower.transform_collider.set_deferred("disabled", false)
			preview_tower.buff_collider.set_deferred("disabled", false)
			# Update WorldGrid
			WorldGrid.data[tower_grid_position] = false
			active_towers.append(preview_tower)

			# Get a new preview tower
			create_preview_tower()

			tower_mana_spent.emit(cost)

func check_can_ugprade(_tower_mana) -> bool:
	if tower_to_upgrade:
		var cost: int = tower_to_upgrade.level_upgrade_price
		if tower_to_upgrade.level < Constants.TOWER_MAX_LEVEL and _tower_mana >= cost:
				return true
	return false

func upgrade_tower() -> void:
	if tower_to_upgrade:
		tower_mana_spent.emit(tower_to_upgrade.level_upgrade_price)
		tower_to_upgrade.upgrade()

func on_tower_detect_area_entered(intruder: Area2D) -> void:
	if preview_tower:
		preview_tower.hide()
	
	tower_to_upgrade = intruder.owner
	tower_to_upgrade.show_upgrade_info()	
	tower_to_upgrade.can_show_range = true
	player_build_ui.update_tower_info_panel(tower_to_upgrade)

func on_tower_detect_area_exited(_intruder: Area2D) -> void:
	if preview_tower:
		preview_tower.show()
		
	# var tower_to_upgrade: Tower = intruder.owner
	if tower_to_upgrade:
		tower_to_upgrade.hide_upgrade_info()
		tower_to_upgrade.can_show_range = false
		tower_to_upgrade = null

	if preview_tower:
		player_build_ui.update_tower_info_panel(preview_tower)
