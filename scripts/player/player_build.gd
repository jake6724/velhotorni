class_name PlayerBuild
extends Node2D

enum TowerAction {HEAL, UPGRADE, SELL, INFO, NONE}
enum TowerPlacementError {POSITION, COST, CAP, DISTANCE}

@export var grid_follow_tower: bool = true # Debugging, should go away

var player_camera: PlayerCamera

var tower_parent: Node = Node.new() # Towers are spawned under this Node so that their position will not affected by this class since it is a Node2D

var active_towers: Array[Tower] = []
var _tower_mana: int # Connected to player_mana's tower_mana_updated signal. This is player_build's local copy

var player_build_ui: PlayerBuildUI # Set by PlayerCharacter
var build_grid_sprite: Sprite2D # Set by PlayerCharacter
var tower_detect_area: Area2D # Set by PlayerCharacter
var hovered_tower: Tower
var mouse_reset_warp_position: Vector2

var tower_action_radial_menu_active: bool = false

const TOWER_PLACEMENT_RANGE: int = 16
# const TOWER_MANA_COST_PER_HEAL: int = 1
const TOWER_HEAL_AMOUNT: int = 25
const MAX_PLACEMENT_DISTANCE: float = 150.0

var tower_scene: PackedScene = preload("res://scenes/towers/Tower.tscn")
var shield_tower_scene: PackedScene = preload("res://scenes/towers/ShieldTower.tscn")
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
signal tower_count_updated
signal heal_all_cost_updated
signal player_hud_hint_requested
signal set_player_enabled_requested

"""
TODO
E is making preview tower move ? 

"""

func _ready():
	add_child(tower_parent)
	WaveManager.wave_started.connect(on_wave_started)
	heal_all_cost_updated.emit(0)
	WaveManager.wave_completed.connect(on_wave_completed)

func initialize(_player_build_ui: PlayerBuildUI, _build_grid_sprite: Sprite2D, _tower_detect_area: Area2D, player_mana: PlayerMana, player_hud: PlayerHUD, player: PlayerCharacter) -> void:
	player_build_ui = _player_build_ui
	build_grid_sprite = _build_grid_sprite
	tower_detect_area = _tower_detect_area
	tower_detect_area.area_entered.connect(on_tower_detect_area_entered)
	tower_detect_area.area_exited.connect(on_tower_detect_area_exited)

	for tower_data: TowerData in PlayerLoadout.equipped_towers:
		if tower_data:
			tower_element_options.append(tower_data.element)

	player_build_ui.update_tower_count_label(0)
	tower_count_updated.emit(0)
	player_build_ui.update_tower_max_label(TowerGlobalData.tower_max)
	_tower_mana = player_mana.tower_mana
	tower_action_changed.emit(tower_action)
	TowerGlobalData.tower_max_updated.connect(on_tower_max_updated)
	TowerGlobalData.tower_debuff_perk_modifier_data_updated.connect(on_tower_perk_debuff_modifier_data_updated)
	TowerGlobalData.tower_buff_perk_modifier_data_updated.connect(on_tower_perk_buff_modifier_data_updated)
	TowerGlobalData.tower_upgrade_price_modifier_updated.connect(on_tower_upgrade_price_modifier_updated)
	TowerGlobalData.tower_prices_updated.connect(on_tower_prices_updated)

	player_build_ui.configure_loadout(tower_element_options)

	# TowerActionRadialMenu
	player_build_ui.tower_action_radial_menu.initialize(player)
	player.player_input.primary_action_just_pressed.connect(on_player_input_primary_action_just_pressed)
	player_build_ui.tower_action_radial_menu.cost_requested.connect(on_tower_action_radial_menu_cost_requested)

	player_hud.heal_all_requested.connect(on_player_hud_heal_all_requested)

	player.player_input.ui_interact_pressed.connect(on_ui_interact_pressed)
	player.player_input.ui_interact_released.connect(on_ui_interact_released)

	player_camera = player.player_camera

func on_ui_interact_pressed() -> void:
	if hovered_tower:
		hovered_tower.upgrade_button_hint.hide()
		set_player_enabled_requested.emit(false)
		mouse_reset_warp_position = get_viewport().get_mouse_position()
		tower_action_radial_menu_active = true
		player_build_ui.tower_action_radial_menu.animate_open()
		hovered_tower.can_show_range = false
		preview_tower.hide()

func on_ui_interact_released() -> void: # TODO: Call this when unhovering a tower also
	if tower_action_radial_menu_active:
		set_player_enabled_requested.emit(true)
		if hovered_tower:
			hovered_tower.upgrade_button_hint.show()

		player_build_ui.tower_action_radial_menu.animate_close() 
		tower_action_radial_menu_active = false
		get_viewport().warp_mouse(mouse_reset_warp_position)
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func on_player_input_primary_action_just_pressed() -> void:
	if tower_action_radial_menu_active and hovered_tower:
		var selected_tower_action: TowerAction = player_build_ui.tower_action_radial_menu.select_action()
		if check_can_perform_action(hovered_tower, selected_tower_action):
			if check_can_afford_action(hovered_tower, selected_tower_action):
				get_tower_action_callable(selected_tower_action).call()

				# Post call cleanup and updates
				match selected_tower_action:
					TowerAction.SELL: on_ui_interact_released()
					_: pass
				on_tower_action_radial_menu_cost_requested(selected_tower_action)

func on_tower_action_radial_menu_cost_requested(_tower_action: TowerAction) -> void:
	if hovered_tower:
		if _tower_action != TowerAction.SELL:
			player_build_ui.tower_action_radial_menu.set_cost_label(get_action_cost(hovered_tower, _tower_action))
		else:
			player_build_ui.tower_action_radial_menu.set_cost_label(-get_action_cost(hovered_tower, _tower_action))
 
func run(_delta, player_input: PlayerInput, upgrade_action_charge_cirlce: TextureProgressBar) -> void:
	pass

## Creates a new instance of `tower_scene`, fully initialized. Modulated to be transparent.
## This is an active and ready tower that just needs to be placed.
func create_preview_tower():
	if tower_element_options.size():
		# Reset previous selection

		if tower_element_options[tower_index] == Constants.Element.ARCANE:
			preview_tower = shield_tower_scene.instantiate()
		else:
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
		# if not hovered_tower:
		# 	preview_tower.upgrade_button_hint.set_hint_icon("joypad_button_0")

		preview_tower.tower_action_cost_label.text = str(TowerGlobalData.tower_prices[preview_tower.data.element])
		preview_tower.died.connect(on_tower_died)
		preview_tower.sell_price_updated.connect(on_tower_stat_updated)
		preview_tower.tower_health_updated.connect(on_tower_stat_updated)

		if not hovered_tower:
			player_build_ui.update_tower_info_panel(preview_tower)
			preview_tower.show()
		else:
			preview_tower.hide()

## Update the `global_position` of `preview_tower`, which is calculated based on
## the position of `PlayerCharacter` and the current `aim_input`
func update_preview_tower_position(player_global_position: Vector2, aim_input: Vector2) -> void:
	if preview_tower and not tower_action_radial_menu_active:
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

			# Turn tower red if too far to place
			if global_position.distance_to(preview_tower.global_position) > MAX_PLACEMENT_DISTANCE:
				preview_tower.modulate.r = 20

			else:
				preview_tower.modulate.r = 1

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
		preview_tower.modulate.r = 1
		preview_tower.placement_button_hint.hide()
		AudioManager.create_2d_audio_at_location(WorldGrid.grid_to_world(tower_placement_info[1]), SoundEffect.SOUND_EFFECT_TYPE.TOWER_SUMMON)

		# Update WorldGrid
		WorldGrid.data[tower_placement_info[1]] = false

		# Update internal data and BuildUI
		active_towers.append(preview_tower)
		player_build_ui.update_tower_count_label(active_towers.size())
		tower_count_updated.emit(active_towers.size())
		tower_mana_spent.emit(tower_placement_info[2])

		# If wave is running tower sell prices are immeadiately locked
		if WaveManager.wave_active:
			lock_in_tower_sell_prices()

		if preview_tower is ShieldTower:
			preview_tower.set_all_shield_colliders_disabled(false)

		# Get a new preview tower
		create_preview_tower()
	else:
		shake_preview_tower()
		AudioManager.create_2d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.TOWER_SUMMON_FAIL)
		var _hint_text: String = ""
		match tower_placement_info[3]:
			TowerPlacementError.COST: _hint_text = "Can't afford tower!"
			TowerPlacementError.CAP: _hint_text = "Tower cap reached!"
			TowerPlacementError.POSITION: _hint_text = "Can't place tower here!"
			TowerPlacementError.DISTANCE: _hint_text = "Too far away!"
		player_hud_hint_requested.emit(_hint_text, 1.0, true)
		

func switch_tower_action(player_input: PlayerInput) -> void:
	pass

func heal_tower() -> void:
	if hovered_tower and hovered_tower.can_heal:
		tower_mana_spent.emit(hovered_tower.heal_cost)
		hovered_tower.heal(hovered_tower.curr_max_health)

func upgrade_tower() -> void:
	if hovered_tower:
		tower_mana_spent.emit(hovered_tower.level_upgrade_price)
		hovered_tower.upgrade()
		hovered_tower.heal(10000) # Heal em up full

func sell_tower() -> void:
	if hovered_tower:
		# Reclaim money and remove tower
		tower_mana_spent.emit(-hovered_tower.sell_price)
		hovered_tower.die()
		hovered_tower = null

func configure_hovered_tower_for_action(_hovered_tower) -> void:
	pass

func check_can_perform_action(_hovered_tower, _tower_action: TowerAction=TowerAction.NONE) -> bool:
	if _tower_action == TowerAction.NONE:
		_tower_action = tower_action
	# if global_position.distance_to(_hovered_tower.global_position) < MAX_PLACEMENT_DISTANCE:
	match _tower_action:
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
		TowerAction.INFO:
			return false #TODO: THIS NEED TO BE ALWAYS TRUE ONCE IMPLEMENTED!
		_:
			push_error("Unknown tower action: ", tower_action)
			return false
	# else:
	# 	player_hud_hint_requested.emit("Tower far to perform action!", 1.0, true)
	# 	return false

func check_can_afford_action(_hovered_tower, _tower_action: TowerAction) -> bool: 
	var cost: int = get_action_cost(_hovered_tower, _tower_action)
	if _tower_mana >= cost:
		return true
	else:
		return false

func get_action_cost(_hovered_tower, _tower_action: TowerAction=TowerAction.NONE) -> int: 
	if _hovered_tower:
		if _tower_action == TowerAction.NONE:
			_tower_action = tower_action
	
		var cost: int = 0
		match _tower_action:
			TowerAction.HEAL: 
				if _hovered_tower.can_heal:
					cost = max(((_hovered_tower.max_health - _hovered_tower.health) / TOWER_HEAL_AMOUNT), 1)
					_hovered_tower.heal_cost = cost
				else:
					cost = 0
			TowerAction.UPGRADE: 
				if _hovered_tower.can_upgrade:
					cost = _hovered_tower.level_upgrade_price
				else:
					cost = 0
			TowerAction.SELL: cost = -_hovered_tower.sell_price
			TowerAction.INFO: cost = 0
		return cost
	else:
		return -1

## TODO: Instead of calling this on tick in run, maybe just when input updates?
## Returns is_placement_positon_valid: bool, tower_grid_position: Vector2, cost: int
func get_tower_placement_info() -> Array:
	if preview_tower:
		if global_position.distance_to(preview_tower.global_position) < MAX_PLACEMENT_DISTANCE:
			# Check tower count
			if active_towers.size() < TowerGlobalData.tower_max:
				# Check can afford
				var cost: int = TowerGlobalData.tower_prices[preview_tower.data.element]
				if _tower_mana >= cost:
					# Check if placement position is valid
					var tower_grid_position: Vector2 = WorldGrid.world_to_grid(preview_tower.global_position)
					if tower_grid_position in WorldGrid.data and WorldGrid.data[tower_grid_position]:
						return [true, tower_grid_position, cost]
					else:
						return [false, -1, -1, TowerPlacementError.POSITION]
				else: 
					return [false, -1, -1, TowerPlacementError.COST]
			else:
				return [false, -1, -1, TowerPlacementError.CAP]
		else:
			return [false, -1, -1, TowerPlacementError.DISTANCE]
	else:
		return [false, -1, -1]

func on_tower_detect_area_entered(intruder: Area2D) -> void:
	if preview_tower:
		preview_tower.hide()
	
	hovered_tower = intruder.owner
	# hovered_tower.show_action_cost_info(get_action_cost(hovered_tower))
	hovered_tower.can_show_range = true
	player_build_ui.update_tower_info_panel(hovered_tower)
	# hovered_tower.upgrade_button_hint.set_hint_icon("joypad_button_2")
	hovered_tower.upgrade_button_hint.show()
	# configure_hovered_tower_for_action(hovered_tower)
	# tower_action_hint_requested.emit(true)

func on_tower_detect_area_exited(_intruder: Area2D) -> void:
	reset_tower_action.emit(false)
	if preview_tower:
		preview_tower.show()
		
	# var hovered_tower: Tower = intruder.owner
	if hovered_tower:
		# hovered_tower.hide_upgrade_info()
		hovered_tower.upgrade_button_hint.hide()
		hovered_tower.can_show_range = false
		hovered_tower = null

	if preview_tower:
		# preview_tower.upgrade_button_hint.set_hint_icon("joypad_button_0")
		player_build_ui.update_tower_info_panel(preview_tower)
	
	tower_action_hint_requested.emit(false)

func on_tower_died(tower: Tower) -> void:
	if preview_tower == tower:
		preview_tower = null
	var index: int = active_towers.find(tower)
	if index != -1:
		active_towers.remove_at(index)

	player_build_ui.update_tower_count_label(active_towers.size())
	tower_count_updated.emit(active_towers.size())

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
	player_build_ui.set_tower_button_prices(tower_element_options)
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
	create_preview_tower()

func remove_preview_tower() -> void:
	if preview_tower:
		preview_tower.queue_free()
		preview_tower = null

func get_active_debuff_types() -> Array[Debuff.Type]:
	var res: Array[Debuff.Type]
	for element: Constants.Element in tower_element_options:
		var tower_data: TowerData = TowerGlobalData.tower_data[element]
		if tower_data.debuff_data:
			res.append(tower_data.debuff_data.type)
	return res

func shake_preview_tower() -> void:
	if preview_tower:
		preview_tower.shake()

func on_wave_started() -> void:
	lock_in_tower_sell_prices()

func on_wave_completed() -> void:
	heal_all_cost_updated.emit(get_heal_all_cost())

func lock_in_tower_sell_prices() -> void:
	for child in tower_parent.get_children():
		var tower: Tower = child as Tower
		if tower and not tower.sell_price_locked_in:
			tower.sell_price_locked_in = true
			tower.sell_price = tower.sell_price / 2

func on_tower_stat_updated(tower: Tower) -> void:
	if hovered_tower and hovered_tower == tower:
		configure_hovered_tower_for_action(hovered_tower)

func on_player_hud_heal_all_requested() -> void:
	#TODO: SHOULD BE ABLE TO USE THE NORMAL HEAL FUNCTION NOW!
	# Can't use existing heal tower method, it intentionally only heals hovered tower
	for tower: Tower in tower_parent.get_children():
		tower.heal_cost = max(((tower.max_health - tower.health) / TOWER_HEAL_AMOUNT), 1)
		if tower.heal_cost > 0 and tower.can_heal:
			tower_mana_spent.emit(tower.heal_cost)
			tower.heal(tower.curr_max_health)
	heal_all_cost_updated.emit(get_heal_all_cost())

func get_heal_all_cost() -> float:
	var cost: float = 0
	# var heal_required: bool = false
	for tower: Tower in tower_parent.get_children():
		if tower.can_heal:
			# heal_required = true
			cost += max(((tower.max_health - tower.health) / TOWER_HEAL_AMOUNT), 1)
	
	return cost
