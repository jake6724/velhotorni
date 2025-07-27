class_name PlayerController
extends Node2D

# Child References
@onready var tower_menu: TowerMenu = $UI/TowerMenu

# Scenes
var tower_scene: PackedScene = preload("res://scenes/towers/Tower.tscn")
var tower_to_place: Tower = null

var click_enabled: bool = true
var selected_tower_element: Constants.Element = Constants.Element.NONE
var active_towers: Array[Tower] = []
var placement_enabled: bool = true
var gold: int:
	set(value):
		gold = value
		tower_menu.update_gold(gold)
		tower_menu.set_tower_button_sprites(gold)
var reward: float

# Wave Checkpoint data
var checkpoint_gold: int
var checkpoint_active_towers: Array[Tower] = []

func _ready():
	# Configure connection to tower menu
	tower_menu.tower_selected.connect(on_tower_selected)
	tower_menu.mouse_entered_button.connect(on_mouse_entered_button)
	tower_menu.mouse_exited_button.connect(on_mouse_exited_button)

	tower_menu.start_wave.connect(on_start_wave)

	# Connect to EnemySpawner
	EnemySpawner.enemy_died.connect(on_enemy_died)

	# Connect to WaveManager
	WaveManager.wave_completed.connect(on_wave_complete)
	WaveManager.wave_failed.connect(on_wave_failed)

func setup():
	gold = LevelManager.active_level.initial_gold
	set_checkpoints()

	tower_menu.show_level_number()
	tower_menu.update_progress()

func _process(_delta):
	if tower_to_place:
		tower_to_place.position = WorldGrid.grid_to_world(WorldGrid.world_to_grid(get_global_mouse_position()))

func create_tower(element: Constants.Element):
	tower_to_place = tower_scene.instantiate()
	add_child(tower_to_place)
	tower_to_place.initialize(element)

	tower_to_place.modulate.a = .75

func place_tower(element: Constants.Element, world_pos: Vector2) -> bool:
	# Do not allow placement during combat, do not allow NONE type turrets to spawn
	if placement_enabled and selected_tower_element != Constants.Element.NONE:
		var grid_pos: Vector2 = WorldGrid.world_to_grid(world_pos)
		if grid_pos in WorldGrid.data and WorldGrid.data[grid_pos]:
			# Spawn and configure new tower
			var new_tower: Tower = tower_to_place
			tower_to_place = null # Disable movement in _process()
			new_tower.position = WorldGrid.grid_to_world(grid_pos) # Bring it back to world to get a clean grid point
			new_tower.modulate.a = 1

			# Connect to new tower signals
			new_tower.transform_tower.connect(on_tower_transform.bind(new_tower))
			new_tower.tower_hovered.connect(on_tower_hovered)
			new_tower.tower_unhovered.connect(on_tower_unhovered)

			# Update data
			active_towers.append(new_tower)
			WorldGrid.data[grid_pos] = false
			gold -= Constants.TOWER_PRICES[element]

			play_tower_select_sfx(element)

			selected_tower_element = Constants.Element.NONE
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

	else:
		SFXPlayer.play_sfx("click_2")

func on_start_wave() -> void:
	tower_menu.hide_placement_phase()
	placement_enabled = false

	WaveManager.start_wave()
	reward = WaveManager.active_wave.reward

	SFXPlayer.play_sfx("go")

func on_wave_complete() -> void:
	# Update variables
	placement_enabled = true	
	gold += int(reward)

	# Tower Menu config
	if WaveManager.wave_index != WaveManager.level_waves.size():
		tower_menu.show_placement_phase()
		reset_towers()
		tower_menu.update_progress()

	set_checkpoints()

func on_wave_failed() -> void:
	placement_enabled = true
	tower_menu.show_placement_phase()
	gold = checkpoint_gold

	# Remove uncheckpointed towers from active_towers, delete them and update world grid
	# Iterate backwards to avoid null pointer since editing list in place
	for i in range(active_towers.size() - 1, -1, -1):
		if active_towers[i] in checkpoint_active_towers:
			active_towers[i].revert()
		else:
			WorldGrid.data[WorldGrid.world_to_grid(active_towers[i].position)] = true
			active_towers[i].queue_free()
			active_towers.remove_at(i)

	tower_menu.update_progress()

func reset_towers() -> void:
	for tower: Tower in active_towers:
		tower.revert()

func on_tower_transform(tower: Tower) -> void:
	if not placement_enabled and tower.can_transform:
		tower.transform()
		SFXPlayer.play_sfx("click_1")
	else:
		SFXPlayer.play_sfx("click_2")

func on_tower_hovered(tower: Tower):
	if not placement_enabled: # Only show transform sprites if in combat phase
		if tower.can_transform:
			tower.swap_sprite.show()
		else:
			tower.cross_sprite.show()

func on_tower_unhovered(tower: Tower):
	if not placement_enabled:
		tower.swap_sprite.hide()
		tower.cross_sprite.hide()

func play_tower_select_sfx(element: Constants.Element) -> void:
	match element:
		Constants.Element.FIRE: SFXPlayer.play_sfx("fire_select")
		Constants.Element.WIND: SFXPlayer.play_sfx("wind_select")
		Constants.Element.WATER: SFXPlayer.play_sfx("water_select")
		_: pass # TODO: Update with more sfx, maybe have the tower paly this? 

func on_enemy_died():
	gold += 1

func _input(_event):
	if click_enabled and Input.is_action_just_pressed("left_click"):
		place_tower(selected_tower_element, get_global_mouse_position())

	if click_enabled and Input.is_action_just_pressed("right_click"):
		if tower_to_place:
			tower_to_place.queue_free()
			tower_to_place = null

func set_checkpoints() -> void:
	# Checkpoint playerController data
	checkpoint_gold = gold
	checkpoint_active_towers = active_towers.duplicate()

func on_mouse_entered_button() -> void:
	click_enabled = false

func on_mouse_exited_button() -> void:
	click_enabled = true
