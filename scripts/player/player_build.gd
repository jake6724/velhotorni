class_name PlayerBuild
extends Node2D

@export var grid_follow_tower: bool = true # Debugging, should go away

var tower_parent: Node = Node.new()

var active_towers: Array[Tower] = []
var max_towers: int: # Set manually by Main from active_level
	set(value):
		max_towers = value
		player_build_ui.update_tower_max_label(value)

var _tower_mana: int # Connected to player_mana's tower_mana_updated signal. This is player_build's local copy

var player_build_ui: PlayerBuildUI # Set by PlayerCharacter
var build_grid_sprite: Sprite2D # Set by PlayerCharacter
var tower_detect_area: Area2D # Set by PlayerCharacter
var hovered_tower: Tower

const TOWER_PLACEMENT_RANGE: int = 16
const TOWER_MANA_COST_PER_HEAL: int = 1

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

var tower_action: Callable = heal_tower
var tower_action_options: Array[Callable] = [] #TODO: better if this was a linked list

signal tower_mana_spent
signal reset_tower_action

func _ready():
	add_child(tower_parent)
	tower_action_options = [heal_tower, upgrade_tower, sell_tower]

func initialize(_player_build_ui: PlayerBuildUI, _build_grid_sprite: Sprite2D, _tower_detect_area: Area2D, player_mana: PlayerMana) -> void:
	player_build_ui = _player_build_ui
	build_grid_sprite = _build_grid_sprite
	tower_detect_area = _tower_detect_area
	tower_detect_area.area_entered.connect(on_tower_detect_area_entered)
	tower_detect_area.area_exited.connect(on_tower_detect_area_exited)
	player_build_ui.update_tower_count_label(0)
	player_build_ui.update_tower_max_label(max_towers)
	_tower_mana = player_mana.tower_mana

func show_active_tower_ranges(_value: bool) -> void:
	for tower: Tower in active_towers:
		tower.can_show_range = _value

func show_active_tower_healths(_value: bool) -> void:
	for tower: Tower in active_towers:
		tower.healthbar.visible = _value

func run(_delta, player_input: PlayerInput, upgrade_action_charge_cirlce: TextureProgressBar) -> void:
	if player_input.upgrade_action_charge and hovered_tower and check_can_perform_action():
		upgrade_action_charge_cirlce.show()
		upgrade_action_charge_cirlce.value = player_input.upgrade_action_charge * 100
		if player_input.upgrade_action_charge >= 1:
			tower_action.call()
			configure_hovered_tower_for_action(hovered_tower)
			match tower_action:
				heal_tower: reset_tower_action.emit(false)
				upgrade_tower: reset_tower_action.emit(true)
				sell_tower: reset_tower_action.emit(true)
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
	preview_tower.tower_obstacle_collider.set_deferred("disabled", true)
	preview_tower.buff_collider.set_deferred("disabled", true)
	preview_tower.hurtbox_collider.set_deferred("disabled", true)
	preview_tower.sprite.modulate.a = .75
	preview_tower.can_show_range = true	
	preview_tower.upgrade_button_hint.set_hint_icon("joypad_button_0")
	preview_tower.upgrade_price_label.text = str(TowerGlobalData.tower_prices[preview_tower.data.element])
	preview_tower.died.connect(on_tower_died)

	if not hovered_tower:
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
func place_tower() -> void:	
	# Check tower count
	if active_towers.size() < max_towers:

		# Check can afford
		var cost: int = TowerGlobalData.tower_prices[preview_tower.data.element]
		if _tower_mana >= cost:

			# Check if placement position is valid
			var tower_grid_position: Vector2 = WorldGrid.world_to_grid(preview_tower.global_position)
			if tower_grid_position in WorldGrid.data and WorldGrid.data[tower_grid_position]:
				preview_tower.sprite.modulate.a = 1
				preview_tower.can_show_range = false
				preview_tower.attack_collider.set_deferred("disabled", false)
				preview_tower.transform_collider.set_deferred("disabled", false)
				preview_tower.buff_collider.set_deferred("disabled", false)
				preview_tower.tower_obstacle_collider.set_deferred("disabled", false)
				preview_tower.hurtbox_collider.set_deferred("disabled", false)
				preview_tower.healthbar.visible = true	
				preview_tower.ap.play("summon")

				# Update WorldGrid
				WorldGrid.data[tower_grid_position] = false

				# Update internal data and BuildUI
				active_towers.append(preview_tower)
				player_build_ui.update_tower_count_label(active_towers.size())
				tower_mana_spent.emit(cost)

				# Get a new preview tower
				create_preview_tower()

func switch_tower_action(player_input: PlayerInput) -> void:
	tower_action_options.append(tower_action_options[0]) # Move front action to back 
	tower_action_options.remove_at(0)
	tower_action = tower_action_options[0]
	player_build_ui.animate_switch_tower_action()

	# Configure Hovered tower
	configure_hovered_tower_for_action(hovered_tower)

	# Set tower_action_press_multiplier
	if tower_action == heal_tower:
		player_input.tower_action_press_multiplier = player_input.tower_action_press_multiplier_fast
	else:
		player_input.tower_action_press_multiplier = player_input.tower_action_press_multiplier_normal

func heal_tower() -> void:
	if hovered_tower and hovered_tower.can_heal:
		tower_mana_spent.emit(TOWER_MANA_COST_PER_HEAL)
		hovered_tower.heal(10)

func upgrade_tower() -> void:
	if hovered_tower:
		tower_mana_spent.emit(hovered_tower.level_upgrade_price)
		hovered_tower.upgrade()

func sell_tower() -> void:
	if hovered_tower:
		# Update WorldGrid
		var tower_grid_position: Vector2 = WorldGrid.world_to_grid(preview_tower.global_position)
		WorldGrid.data[tower_grid_position] = true	

		# Spend money and remove tower
		tower_mana_spent.emit(-hovered_tower.sell_price)
		hovered_tower.die()

func check_can_perform_action() -> bool:
	var cost: int = get_action_cost()
	if hovered_tower.level < Constants.TOWER_MAX_LEVEL and _tower_mana >= cost:
		# Check tower can be healed if relevant
		if tower_action == heal_tower:
			if hovered_tower.can_heal:
				return true
			else:
				return false

		if tower_action == upgrade_tower:
			if hovered_tower.level >= Constants.TOWER_MAX_LEVEL:
				return false
			else:
				return true

		return true
	return false

func get_action_cost() -> int: 
	if hovered_tower:
		var cost: int = 0
		match tower_action:
			heal_tower: cost = TOWER_MANA_COST_PER_HEAL
			upgrade_tower: cost = hovered_tower.level_upgrade_price
			sell_tower: cost = -hovered_tower.sell_price
		return cost
	else:
		return -1

func configure_hovered_tower_for_action(_hovered_tower) -> void:
	if _hovered_tower:
		_hovered_tower.show_action_cost_info(get_action_cost())

		if check_can_perform_action():
			print("can perform")
			_hovered_tower.upgrade_button_hint.show()
			_hovered_tower.upgrade_coin_icon.show()
		else:
			print("can NOT perform")
			_hovered_tower.upgrade_button_hint.hide()
			_hovered_tower.upgrade_coin_icon.hide()
			_hovered_tower.upgrade_price_label.text = " MAX"

func on_tower_detect_area_entered(intruder: Area2D) -> void:
	if preview_tower:
		preview_tower.hide()
	
	hovered_tower = intruder.owner
	hovered_tower.show_action_cost_info(get_action_cost())	
	hovered_tower.can_show_range = true
	player_build_ui.update_tower_info_panel(hovered_tower)
	hovered_tower.upgrade_button_hint.set_hint_icon("joypad_button_2")
	configure_hovered_tower_for_action(hovered_tower)

func on_tower_detect_area_exited(_intruder: Area2D) -> void:
	reset_tower_action.emit(false)
	if preview_tower:
		preview_tower.show()
		
	# var hovered_tower: Tower = intruder.owner
	if hovered_tower:
		hovered_tower.hide_upgrade_info()
		hovered_tower.can_show_range = false
		hovered_tower = null

	if preview_tower:
		preview_tower.upgrade_button_hint.set_hint_icon("joypad_button_0")
		player_build_ui.update_tower_info_panel(preview_tower)

func on_tower_died(tower: Tower) -> void:
	if preview_tower == tower:
		preview_tower = null
	var index: int = active_towers.find(tower)
	if index != -1:
		active_towers.remove_at(index)

	player_build_ui.update_tower_count_label(active_towers.size())

func on_tower_mana_updated(_value) -> void:
	_tower_mana = _value
