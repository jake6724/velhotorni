class_name PlayerController
extends Node2D

# Child References
@onready var tower_menu: TowerMenu = $UI/TowerMenu
@onready var tower_upgrade_menu: TowerUpgradeMenu = $UI/TowerUpgradeMenu
@onready var tower_evolve_menu: TowerEvolveMenu = $UI/TowerEvolveMenu
@onready var coin_collector: CoinCollector = $CoinCollector

var tower_scene: PackedScene = preload("res://scenes/towers/Tower.tscn")
var tower_to_place: Tower = null
var tower_to_upgrade: Tower = null:
	set(value):
		tower_to_upgrade = value
		if value:
			tower_upgrade_menu.tower = value
			tower_upgrade_menu.update_stats(gold)

var click_enabled: bool = true
var can_open_tower_upgrades: bool = true
var selected_tower_element: Constants.Element = Constants.Element.NONE
var active_towers: Array[Tower] = []
var placement_enabled: bool = true
var gold: int:
	set(value):
		gold = value
		tower_menu.update_gold(gold)
		tower_menu.set_tower_button_sprites(gold)
var reward: float
var token: int: 
	set(value): 
		token = value
		tower_menu.update_token(value)
		# TODO: update evo menu!
var token_reward: int

# Wave Checkpoint data
var checkpoint_gold: int
var checkpoint_token: int
var checkpoint_active_towers: Array[Tower] = []

func _ready():
	# Configure connection to tower menu
	tower_menu.tower_selected.connect(on_tower_selected)
	tower_menu.mouse_entered_button.connect(on_mouse_entered_button)
	tower_menu.mouse_exited_button.connect(on_mouse_exited_button)
	tower_menu.start_wave.connect(on_start_wave)

	# Connect to tower upgrade menu
	tower_upgrade_menu.damage_button_pressed.connect(on_damage_button_pressed)
	tower_upgrade_menu.speed_button_pressed.connect(on_speed_button_pressed)
	tower_upgrade_menu.range_button_pressed.connect(on_range_button_pressed)
	tower_upgrade_menu.special_button_pressed.connect(on_special_button_pressed)
	tower_upgrade_menu.evolve_button_pressed.connect(on_evolve_button_pressed)
	tower_upgrade_menu.close_button_pressed.connect(on_close_menu)
	tower_upgrade_menu.target_priority_changed.connect(on_tower_priority_changed)

	# Connect to tower evolve menu
	tower_evolve_menu.option_1_selected.connect(on_option_selected)
	tower_evolve_menu.option_2_selected.connect(on_option_selected)
	tower_evolve_menu.close_button_pressed.connect(on_close_menu)
	tower_evolve_menu.back_button_pressed.connect(on_tower_evolve_menu_back_button_pressed)

	# Connect to EnemySpawner
	EnemySpawner.enemy_died.connect(on_enemy_died)

	# Connect to WaveManager
	WaveManager.wave_completed.connect(on_wave_complete)
	WaveManager.wave_failed.connect(on_wave_failed)

	# Connect to CoinCollector
	coin_collector.coin_collected.connect(on_coin_collected)

func setup(): # Active level has been set by the time main calls this method
	gold = LevelManager.active_level.initial_gold
	token = LevelManager.active_level.initial_token
	set_checkpoints()

	tower_menu.show_level_number()
	tower_menu.update_progress()
	tower_menu.wave_preview_panel.get_all_wave_preview_data(LevelManager.active_level)
	tower_menu.set_wave_preview(WaveManager.wave_index)

func _process(_delta):
	if tower_to_place:
		tower_to_place.position = WorldGrid.grid_to_world(WorldGrid.world_to_grid(get_global_mouse_position()))

	queue_redraw()

func _input(_event):
	if click_enabled and Input.is_action_just_pressed("left_click"):
		if not tower_to_upgrade and selected_tower_element != Constants.Element.NONE: # Place a new tower
			place_tower(selected_tower_element, get_global_mouse_position())

	if Input.is_action_just_pressed("right_click"): # Clear tower to place
		if tower_to_place:
			tower_menu.show_placement_phase()
			hide_tower_buff_ranges()
			tower_to_place.queue_free()
			tower_to_place = null

func create_tower(element: Constants.Element):
	# Reset previous selection
	if tower_to_place:
		tower_to_place.queue_free()
		tower_to_place = null

	tower_to_place = tower_scene.instantiate()
	add_child(tower_to_place)
	tower_to_place.initialize(element)
	tower_to_place.modulate.a = .75

	show_tower_buff_ranges()

func place_tower(element: Constants.Element, world_pos: Vector2) -> bool:
	# Do not allow placement during combat, do not allow NONE type turrets to spawn
	if placement_enabled and selected_tower_element != Constants.Element.NONE and tower_to_place:
		var grid_pos: Vector2 = WorldGrid.world_to_grid(world_pos)
		if grid_pos in WorldGrid.data and WorldGrid.data[grid_pos]:
			# Spawn and configure new tower
			var new_tower: Tower = tower_to_place # tower_to_place BECOMES new_tower, same tower ref
			tower_to_place = null # Disable movement in _process()
			new_tower.transform_area.input_pickable = false
			new_tower.position = WorldGrid.grid_to_world(grid_pos) # Bring it back to world to get a clean grid point
			new_tower.modulate.a = 1

			# Connect to new tower signals
			new_tower.tower_clicked.connect(on_tower_clicked.bind(new_tower))
			new_tower.tower_hovered.connect(on_tower_hovered)
			new_tower.tower_unhovered.connect(on_tower_unhovered)

			# Update data
			active_towers.append(new_tower)
			WorldGrid.data[grid_pos] = false
			gold -= Constants.TOWER_PRICES[element]

			play_tower_select_sfx(element)

			hide_tower_buff_ranges()

			selected_tower_element = Constants.Element.NONE
			tower_menu.show_shop()
			await get_tree().create_timer(.1).timeout # delay allowing tower to process input events
			new_tower.transform_area.set_deferred("input_pickable", true)
			return true
		else:
			# SFXPlayer.play_sfx("click_2")
			return false
	else:
		return false

func on_tower_selected(element: Constants.Element) -> void:
	# Check player can afford tower
	if gold >= Constants.TOWER_PRICES[element]:
		selected_tower_element = element

		match element:
			Constants.Element.FIRE: SFXPlayer.play_sfx("fire_click")
			Constants.Element.WIND: SFXPlayer.play_sfx("wind_click")
			Constants.Element.WATER: SFXPlayer.play_sfx("water_click")

		create_tower(element)
		tower_menu.hide_shop()

	else:
		SFXPlayer.play_sfx("click_2")

func on_tower_clicked(tower: Tower) -> void:
	if not placement_enabled and tower.can_transform: # Transform tower
		tower.transform()
		SFXPlayer.play_sfx("click_1")

	elif placement_enabled and not tower_to_place and tower.can_transform: # Upgrade tower
		tower_to_upgrade = tower
		tower_upgrade_menu.show()
		tower_menu.hide()

	else: pass # Tower not ready to be interacted with (just placed)

func on_start_wave() -> void:
	# Disable wave start if actively placing a tower, or no towers placed
	if not tower_to_place and active_towers.size() > 0:
		tower_menu.display_wave_info()
		tower_menu.hide_placement_phase()
		placement_enabled = false

		WaveManager.start_wave()
		reward = WaveManager.active_wave.reward
		token_reward = WaveManager.active_wave.token_reward

		SFXPlayer.play_sfx("go")
	else:
		SFXPlayer.play_sfx("click_2")

func on_wave_complete() -> void:
	# Update variables
	placement_enabled = true	
	gold += int(reward)
	token += token_reward

	# Tower Menu config
	if WaveManager.wave_index != WaveManager.level_waves.size():
		tower_menu.show_placement_phase()
		reset_towers()
		tower_menu.update_progress()
		tower_menu.set_wave_preview(WaveManager.wave_index)

	set_checkpoints()
	set_tower_checkpoints()

func on_wave_failed() -> void:
	placement_enabled = true
	tower_menu.show_placement_phase()
	gold = checkpoint_gold
	token = checkpoint_token

	# Remove uncheckpointed towers from active_towers, delete them and update world grid
	# Iterate backwards to avoid null pointer since editing list in place
	for i in range(active_towers.size() - 1, -1, -1):
		if active_towers[i] in checkpoint_active_towers:
			active_towers[i].revert()
			active_towers[i].revert_to_checkpoint()
		else:
			WorldGrid.data[WorldGrid.world_to_grid(active_towers[i].position)] = true
			active_towers[i].queue_free()
			active_towers.remove_at(i)

	tower_menu.update_progress()

func reset_towers() -> void:
	for tower: Tower in active_towers:
		tower.revert()

func show_tower_buff_ranges() -> void:
	for tower: Tower in active_towers:
		tower.can_show_buff_range = true

func hide_tower_buff_ranges() -> void:
	for tower: Tower in active_towers:
		tower.can_show_buff_range = false

func on_tower_hovered(tower: Tower):
	if not placement_enabled: # Only show transform sprites if in combat phase
		if tower.can_transform:
			tower.swap_sprite.show()
		else:
			tower.cross_sprite.show()

	if placement_enabled:
		await get_tree().create_timer(.01).timeout # Make sure this always runs AFTER unhovered
		tower_menu.show_tower_info_panel(tower)

func on_tower_unhovered(tower: Tower):
	# if not placement_enabled:
	tower.swap_sprite.hide()
	tower.cross_sprite.hide()

	if placement_enabled:
		tower_menu.hide_tower_info_panels()

func play_tower_select_sfx(element: Constants.Element) -> void:
	match element:
		Constants.Element.FIRE: SFXPlayer.play_sfx("fire_select")
		Constants.Element.WIND: SFXPlayer.play_sfx("wind_select")
		Constants.Element.WATER: SFXPlayer.play_sfx("water_select")
		_: pass # TODO: Update with more sfx, maybe have the tower paly this? 

func on_enemy_died():
	pass

func on_coin_collected():
	gold += 1

func set_checkpoints() -> void:
	# Checkpoint playerController data
	checkpoint_gold = gold
	checkpoint_token = token
	checkpoint_active_towers = active_towers.duplicate()

func set_tower_checkpoints() -> void:
	for tower: Tower in active_towers:
		tower.set_checkpoint_levels()

func on_mouse_entered_button(_element) -> void:
	if _element != Constants.Element.NONE:
		tower_menu.show_tower_info_panel_shop(Constants.tower_data[_element])
	click_enabled = false

func on_mouse_exited_button() -> void:
	tower_menu.hide_tower_info_panel_shop()
	click_enabled = true

# Tower Upgrade Menu functions 
# TODO: Maybe some of this should move into the tower, or a tower upgrade component in tower?
func check_gold_upgrade_requirement() -> bool:
	if gold >= tower_to_upgrade.level_upgrade_price:
		return true
	else:
		return false

func on_damage_button_pressed() -> void:
	if tower_to_upgrade.damage_level < 3:
		if tower_to_upgrade and check_gold_upgrade_requirement():
			gold -= tower_to_upgrade.level_upgrade_price
			tower_to_upgrade.damage_level += 1
			tower_upgrade_menu.update_stats(gold)
			tower_upgrade_menu.update_damage_level_arrow()

func on_speed_button_pressed() -> void:
	if tower_to_upgrade.speed_level < 3:
		if tower_to_upgrade and check_gold_upgrade_requirement():
			gold -= tower_to_upgrade.level_upgrade_price
			tower_to_upgrade.speed_level += 1
			tower_upgrade_menu.update_stats(gold)
			tower_upgrade_menu.update_speed_level_arrow()

func on_range_button_pressed() -> void:
	if tower_to_upgrade.range_level < 3:
		if tower_to_upgrade and check_gold_upgrade_requirement():
			gold -= tower_to_upgrade.level_upgrade_price
			tower_to_upgrade.range_level += 1
			tower_upgrade_menu.update_stats(gold)
			tower_upgrade_menu.update_range_level_arrow()

func on_special_button_pressed() -> void:
	if tower_to_upgrade.special_level < 3:
		if tower_to_upgrade and check_gold_upgrade_requirement():
			gold -= tower_to_upgrade.level_upgrade_price
			tower_to_upgrade.special_level += 1
			tower_upgrade_menu.update_stats(gold)
			tower_upgrade_menu.update_special_level_arrow()

func on_evolve_button_pressed() -> void:
	tower_upgrade_menu.hide()
	tower_evolve_menu.show()
	tower_evolve_menu.update_stats(tower_to_upgrade, token)

func on_option_selected(_element: Constants.Element) -> void:
	if tower_to_upgrade:
		tower_to_upgrade.evolve(_element)
		token -= 1
		TowerGlobalData.tower_evolution_status[_element] = false
		tower_evolve_menu.hide()
		tower_to_upgrade = null
		tower_menu.show()

func on_close_menu() -> void:
	tower_upgrade_menu.hide()
	tower_evolve_menu.hide()
	tower_menu.show()
	tower_to_upgrade = null

func on_tower_evolve_menu_back_button_pressed() -> void:
	tower_evolve_menu.hide()
	tower_upgrade_menu.show()

func on_tower_priority_changed(priority: Tower.TargetPriority):
	if tower_to_upgrade:
		tower_to_upgrade.target_priority = priority
		tower_upgrade_menu.set_target_priority_data(tower_to_upgrade.target_priority)
		tower_upgrade_menu.update_stats(gold)