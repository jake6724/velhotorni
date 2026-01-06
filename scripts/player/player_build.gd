class_name PlayerBuild
extends Node2D

enum TowerAction {HEAL, UPGRADE, SELL}

@export var grid_follow_tower: bool = true # Debugging, should go away

var tower_parent: Node = Node.new() # Towers are spawned under this Node so that their position will not affected by this class since it is a Node2D

var active_towers: Array[Tower] = []
var _tower_mana: int # Connected to player_mana's tower_mana_updated signal. This is player_build's local copy

var player_build_ui: PlayerBuildUI # Set by PlayerCharacter
var build_grid_sprite: Sprite2D # Set by PlayerCharacter
var tower_detect_area: Area2D # Set by PlayerCharacter
var hovered_tower: Tower

const TOWER_PLACEMENT_RANGE: int = 16
const TOWER_MANA_COST_PER_HEAL: int = 1
const TOWER_HEAL_AMOUNT: int = 25

var tower_scene: PackedScene = preload("res://scenes/towers/Tower.tscn")
var preview_tower: Tower
var preview_tower_grid_position: Vector2
var tower_element_options: Array[Constants.Element] = []

var tower_index: int = 0: 
	set(value):
		tower_index = value
		if tower_index < 0:
			tower_index = (tower_element_options.size()-1)
		elif tower_index > (tower_element_options.size()-1):
			tower_index = 0

		player_build_ui.tower_index = tower_index

var tower_action: TowerAction = TowerAction.HEAL
var tower_action_options: Array[TowerAction] = [TowerAction.HEAL, TowerAction.UPGRADE, TowerAction.SELL]

signal tower_mana_spent
signal reset_tower_action
signal tower_action_changed
signal tower_action_hint_requested

func _ready():
	add_child(tower_parent)

func initialize(_player_build_ui: PlayerBuildUI, _build_grid_sprite: Sprite2D, _tower_detect_area: Area2D, player_mana: PlayerMana) -> void:
	player_build_ui = _player_build_ui
	build_grid_sprite = _build_grid_sprite
	tower_detect_area = _tower_detect_area
	tower_detect_area.area_entered.connect(on_tower_detect_area_entered)
	tower_detect_area.area_exited.connect(on_tower_detect_area_exited)

	for tower_data: TowerData in PlayerLoadout.equipped_towers:
		if tower_data:
			tower_element_options.append(tower_data.element)

	player_build_ui.update_tower_count_label(0)
	player_build_ui.update_tower_max_label(TowerGlobalData.tower_max)
	_tower_mana = player_mana.tower_mana
	tower_action_changed.emit(tower_action)
	TowerGlobalData.tower_max_updated.connect(on_tower_max_updated)
	TowerGlobalData.tower_debuff_perk_modifier_data_updated.connect(on_tower_perk_debuff_modifier_data_updated)
	TowerGlobalData.tower_buff_perk_modifier_data_updated.connect(on_tower_perk_buff_modifier_data_updated)
	TowerGlobalData.tower_upgrade_price_modifier_updated.connect(on_tower_upgrade_price_modifier_updated)
	TowerGlobalData.tower_prices_updated.connect(on_tower_prices_updated)

	player_build_ui.configure_loadout(tower_element_options)

func run(_delta, player_input: PlayerInput, upgrade_action_charge_cirlce: TextureProgressBar) -> void:
	if player_input.upgrade_action_charge and hovered_tower and check_can_perform_action(hovered_tower):
		if check_can_afford_action(hovered_tower):
			upgrade_action_charge_cirlce.show()
			upgrade_action_charge_cirlce.value = player_input.upgrade_action_charge * 100
			if player_input.upgrade_action_charge >= 1:
				get_tower_action_callable(tower_action).call()
				configure_hovered_tower_for_action(hovered_tower)
				match tower_action:
					TowerAction.HEAL: reset_tower_action.emit(false)
					TowerAction.UPGRADE: reset_tower_action.emit(true)
					TowerAction.SELL: reset_tower_action.emit(true)
	else:
		upgrade_action_charge_cirlce.hide()
		upgrade_action_charge_cirlce.value = 0

		
		if preview_tower and preview_tower.visible:
			if get_tower_placement_info()[0]:
				preview_tower.upgrade_button_hint.show()
			else:
				preview_tower.upgrade_button_hint.hide()

## Creates a new instance of `tower_scene`, fully initialized. Modulated to be transparent.
## This is an active and ready tower that just needs to be placed.
func create_preview_tower():
	if tower_element_options.size():
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
		if not hovered_tower:
			preview_tower.upgrade_button_hint.set_hint_icon("joypad_button_0")

		preview_tower.tower_action_cost_label.text = str(TowerGlobalData.tower_prices[preview_tower.data.element])
		preview_tower.died.connect(on_tower_died)

		if not hovered_tower:
			player_build_ui.update_tower_info_panel(preview_tower)
			preview_tower.show()
		else:
			preview_tower.hide()

## Update the `global_position` of `preview_tower`, which is calculated based on
## the position of `PlayerCharacter` and the current `aim_input`
func update_preview_tower_position(player_global_position: Vector2, aim_input: Vector2) -> void:
	if preview_tower:

		if GlobalSettings.controller_active:
			aim_input = Constants.get_closest_cardinal_4_direction_normalized(aim_input)
			preview_tower_grid_position = WorldGrid.world_to_grid(player_global_position + (aim_input * TOWER_PLACEMENT_RANGE))
			preview_tower.global_position = WorldGrid.grid_to_world(preview_tower_grid_position)

			var target: Vector2
			if not grid_follow_tower:
				target = WorldGrid.grid_to_world(WorldGrid.world_to_grid(player_global_position)) + Vector2(8,8)
			else:
				target = preview_tower.global_position + Vector2(8,8)
				
			build_grid_sprite.global_position = target

		else:
			preview_tower_grid_position = WorldGrid.grid_to_world(WorldGrid.world_to_grid(get_global_mouse_position()))
			preview_tower.global_position = preview_tower_grid_position
			build_grid_sprite.global_position = preview_tower.global_position + Vector2(8,8)

func update_tower_detect_area_position() -> void:
	tower_detect_area.global_position = build_grid_sprite.global_position

## Check if placement is valid and place `preview_tower`. Update `WorldGrid` and `preview_tower` accordingly.
func place_tower() -> void:	
	var tower_placement_info: Array = get_tower_placement_info()
	if tower_placement_info[0]:
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
		WorldGrid.data[tower_placement_info[1]] = false

		# Update internal data and BuildUI
		active_towers.append(preview_tower)
		player_build_ui.update_tower_count_label(active_towers.size())
		tower_mana_spent.emit(tower_placement_info[2])

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
	if tower_action == TowerAction.HEAL:
		player_input.tower_action_press_multiplier = player_input.tower_action_press_multiplier_fast
	else:
		player_input.tower_action_press_multiplier = player_input.tower_action_press_multiplier_normal

	tower_action_changed.emit(tower_action)

func heal_tower() -> void:
	if hovered_tower and hovered_tower.can_heal:
		tower_mana_spent.emit(TOWER_MANA_COST_PER_HEAL)
		hovered_tower.heal(TOWER_HEAL_AMOUNT)

func upgrade_tower() -> void:
	if hovered_tower:
		tower_mana_spent.emit(hovered_tower.level_upgrade_price)
		hovered_tower.upgrade()
		hovered_tower.heal(10000) # Heal em up full
func sell_tower() -> void:
	if hovered_tower:
		# Update WorldGrid
		var tower_grid_position: Vector2 = WorldGrid.world_to_grid(preview_tower.global_position)
		WorldGrid.data[tower_grid_position] = true	

		# Spend money and remove tower
		tower_mana_spent.emit(-hovered_tower.sell_price)
		hovered_tower.die()

func configure_hovered_tower_for_action(_hovered_tower) -> void:
	if _hovered_tower:
		_hovered_tower.show_action_cost_info(get_action_cost(_hovered_tower))

		if check_can_perform_action(_hovered_tower):
			if check_can_afford_action(_hovered_tower):
				_hovered_tower.upgrade_button_hint.show()
				_hovered_tower.upgrade_coin_icon.show()
			else:
				_hovered_tower.upgrade_button_hint.hide()
				_hovered_tower.upgrade_coin_icon.show()
		else:
			_hovered_tower.upgrade_button_hint.hide()
			_hovered_tower.upgrade_coin_icon.hide()
			_hovered_tower.tower_action_cost_label.text = " MAX"

func check_can_perform_action(_hovered_tower) -> bool:
	match tower_action:
		TowerAction.HEAL:
			if _hovered_tower.can_heal:
				return true
			else:
				return false
		TowerAction.UPGRADE:
			if _hovered_tower.level < Constants.TOWER_MAX_LEVEL:
				return true
			else:
				return false
		TowerAction.SELL: 
			return true

	push_error("Unknown tower action: ", tower_action)
	return false

func check_can_afford_action(_hovered_tower) -> bool: 
	var cost: int = get_action_cost(_hovered_tower)
	if _tower_mana >= cost:
		return true
	else:
		return false

func get_action_cost(_hovered_tower) -> int: 
	if _hovered_tower:
		var cost: int = 0
		match tower_action:
			TowerAction.HEAL: cost = TOWER_MANA_COST_PER_HEAL
			TowerAction.UPGRADE: cost = _hovered_tower.level_upgrade_price
			TowerAction.SELL: cost = -_hovered_tower.sell_price
		return cost
	else:
		return -1

func get_tower_placement_info() -> Array:
	if preview_tower:
		# Check tower count
		if active_towers.size() < TowerGlobalData.tower_max:
			# Check can afford
			var cost: int = TowerGlobalData.tower_prices[preview_tower.data.element]
			if _tower_mana >= cost:
				# Check if placement position is valid
				var tower_grid_position: Vector2 = WorldGrid.world_to_grid(preview_tower.global_position)
				if tower_grid_position in WorldGrid.data and WorldGrid.data[tower_grid_position]:
					return [true, tower_grid_position, cost]
		return [false, -1, -1]
	return [false, -1, -1]

func on_tower_detect_area_entered(intruder: Area2D) -> void:
	if preview_tower:
		preview_tower.hide()
	
	hovered_tower = intruder.owner
	hovered_tower.show_action_cost_info(get_action_cost(hovered_tower))	
	hovered_tower.can_show_range = true
	player_build_ui.update_tower_info_panel(hovered_tower)
	hovered_tower.upgrade_button_hint.set_hint_icon("joypad_button_2")
	hovered_tower.upgrade_button_hint.show()
	configure_hovered_tower_for_action(hovered_tower)
	tower_action_hint_requested.emit(true)

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
	
	tower_action_hint_requested.emit(false)

func on_tower_died(tower: Tower) -> void:
	if preview_tower == tower:
		preview_tower = null
	var index: int = active_towers.find(tower)
	if index != -1:
		active_towers.remove_at(index)

	player_build_ui.update_tower_count_label(active_towers.size())

func on_tower_mana_updated(_value) -> void:
	_tower_mana = _value

func get_tower_action_callable(_tower_action: TowerAction) -> Callable:
	match _tower_action:
		TowerAction.HEAL: return heal_tower
		TowerAction.UPGRADE: return upgrade_tower
		TowerAction.SELL: return sell_tower
	push_error("Passed TowerAction '", _tower_action, "' unknown")
	return null_func
	
func null_func() -> void:
	print("Null func")

func show_active_tower_ranges(_value: bool) -> void:
	for tower: Tower in active_towers:
		tower.can_show_range = _value

func show_active_tower_healths(_value: bool) -> void:
	for tower: Tower in active_towers:
		tower.healthbar.visible = _value

func on_tower_max_updated(tower_max: int) -> void:
	player_build_ui.update_tower_max_label(tower_max)

func on_tower_perk_debuff_modifier_data_updated() -> void:
	for tower: Tower in active_towers:
		tower.update_debuff_data()

func on_tower_perk_buff_modifier_data_updated() -> void:
	for tower: Tower in active_towers:
		tower.update_buff_data()
		# TODO: Make sure sell price is modified

func on_tower_upgrade_price_modifier_updated() -> void:
	for tower: Tower in active_towers:
		tower.update_upgrade_info()

func on_tower_prices_updated() -> void:
	if preview_tower:
		preview_tower.show_action_cost_info(TowerGlobalData.tower_prices[preview_tower.data.element])

func loadout_updated() -> void:
	tower_element_options = []
	tower_index = 0
	remove_preview_tower()
	for i in range(PlayerLoadout.equipped_towers.size()):
		if PlayerLoadout.equipped_towers[i]:
			var tower_data: TowerData = PlayerLoadout.equipped_towers[i]
			tower_element_options.append(tower_data.element)

	player_build_ui.configure_loadout(tower_element_options)

	print("Loadout updated. tower_element_options: ", tower_element_options)
	create_preview_tower()

func remove_preview_tower() -> void:
	if preview_tower:
		preview_tower.queue_free()
		preview_tower = null
