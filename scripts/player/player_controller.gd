class_name PlayerController
extends Node2D

# Child References
@onready var tower_menu: TowerMenu = $UI/TowerMenu

# Scenes
var tower_scene: PackedScene = preload("res://scenes/towers/Tower.tscn")

var textures: Dictionary[GameManager.Element, Texture] = {
	GameManager.Element.FIRE: preload("res://assets/art/sprites/spr_tower_fire.png"),
	GameManager.Element.EARTH: preload("res://assets/art/sprites/spr_tower_earth.png"),
	GameManager.Element.WATER: preload("res://assets/art/sprites/spr_tower_water.png"),
}

var prices: Dictionary[GameManager.Element, int] = {
	GameManager.Element.FIRE: 25,
	GameManager.Element.EARTH: 50,
	GameManager.Element.WATER: 75,
}

var placement_indicator: PackedScene = preload("res://scenes/towers/PlacementIndicator.tscn")
var indicator: Node2D

var click_enabled: bool = true
var selected_tower_element: GameManager.Element = GameManager.Element.NONE
var active_towers: Array[Tower] = []
var placement_enabled: bool = true
var gold: int:
	set(value):
		gold = value
		tower_menu.update_gold(gold)
var reward: float

# Wave Checkpoint data
var checkpoint_gold: int
var checkpoint_active_towers: Array[Tower] = []

func _ready():
	gold = GameManager.active_level.initial_gold
	checkpoint_gold = gold

	# Configure connection to tower menu
	tower_menu.tower_selected.connect(on_tower_selected)
	tower_menu.mouse_entered_button.connect(on_mouse_entered_button)
	tower_menu.mouse_exited_button.connect(on_mouse_exited_button)

	tower_menu.show_level_number()
	# tower_menu.update_gold(gold) # get this from GameManager active_level
	update_tower_button_sprites()
	tower_menu.update_progress()
	tower_menu.start_wave.connect(on_start_wave)

	# Configure indicator sprite
	indicator = placement_indicator.instantiate()
	indicator.modulate.a = .75
	indicator.hide()
	add_child(indicator)

	# Connect to EnemySpawner
	EnemySpawner.wave_complete.connect(on_wave_complete)
	EnemySpawner.enemy_died.connect(on_enemy_died)

	# Connect to GameManager
	GameManager.wave_failed.connect(on_wave_failed)

func _process(_delta):
	if placement_enabled and selected_tower_element != GameManager.Element.NONE:
		indicator.position = GameManager.grid_to_world(GameManager.world_to_grid(get_global_mouse_position()))
	else:
		indicator.hide()

func spawn_tower(element: GameManager.Element, world_pos: Vector2) -> bool:
	# Do not allow placement during combat, do not allow NONE type turrets to spawn
	if placement_enabled and selected_tower_element != GameManager.Element.NONE:
		var grid_pos: Vector2 = GameManager.world_to_grid(world_pos)
		if grid_pos in WorldGrid.data and WorldGrid.data[grid_pos]:
			# Spawn and configure new tower
			var new_tower = tower_scene.instantiate()
			new_tower.position = GameManager.grid_to_world(grid_pos) # Bring it back to world to get a clean grid point
			add_child(new_tower)
			new_tower.configure_tower(element)

			# Connect to new tower signals
			new_tower.transform_tower.connect(on_tower_transform.bind(new_tower))
			new_tower.tower_hovered.connect(on_tower_hovered)
			new_tower.tower_unhovered.connect(on_tower_unhovered)

			# Update data
			active_towers.append(new_tower)
			WorldGrid.data[grid_pos] = false
			gold -= prices[element]

			# Clean up indicator
			indicator.hide()
			update_tower_button_sprites()
			# tower_menu.update_gold(gold)
			play_tower_select_sfx(element)

			selected_tower_element = GameManager.Element.NONE
			return true
		else:
			SFXPlayer.play_sfx("click_2")
			return false
	else:
		return false

func on_tower_selected(element: GameManager.Element) -> void:
	# Check player can afford tower
	if gold >= prices[element]:
		selected_tower_element = element

		match element:
			GameManager.Element.FIRE: SFXPlayer.play_sfx("fire_click")
			GameManager.Element.EARTH: SFXPlayer.play_sfx("earth_click")
			GameManager.Element.WATER: SFXPlayer.play_sfx("water_click")

		# Indicator
		indicator.tower_sprite.texture = textures[element]
		indicator.show()
	else:
		SFXPlayer.play_sfx("click_2")

func on_start_wave() -> void:
	tower_menu.hide_placement_phase()
	placement_enabled = false

	# Enemy Spawner
	EnemySpawner.start_wave()
	reward = EnemySpawner.active_wave.reward

	# GameManager
	GameManager.is_wave_failed = false

	SFXPlayer.play_sfx("go")

func on_wave_complete() -> void:
	# Update variables
	placement_enabled = true	
	gold += int(reward)
	update_tower_button_sprites()

	# Tower Menu config
	if EnemySpawner.wave_index != EnemySpawner.level_waves.size():
		tower_menu.show_placement_phase()
		# tower_menu.update_gold(int(gold))
		reset_towers()
		tower_menu.update_progress()

	set_checkpoints()

func on_wave_failed() -> void:
	placement_enabled = true
	tower_menu.show_placement_phase()
	gold = checkpoint_gold
	update_tower_button_sprites()

	# Remove uncheckpointed towers from active_towers, delete them and update world grid
	# Iterate backwards to avoid null pointer since editing list in place
	for i in range(active_towers.size() - 1, -1, -1):
		if active_towers[i] not in checkpoint_active_towers:
			WorldGrid.data[GameManager.world_to_grid(active_towers[i].position)] = true
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

func play_tower_select_sfx(element: GameManager.Element) -> void:
	match element:
		GameManager.Element.FIRE: SFXPlayer.play_sfx("fire_select")
		GameManager.Element.EARTH: SFXPlayer.play_sfx("earth_select")
		GameManager.Element.WATER: SFXPlayer.play_sfx("water_select")

func on_enemy_died():
	gold += 1
	# tower_menu.update_gold(gold)

func _input(_event):
	if click_enabled and Input.is_action_just_pressed("left_click"):
		spawn_tower(selected_tower_element, get_global_mouse_position())

	if click_enabled and Input.is_action_just_pressed("right_click"):
		selected_tower_element = GameManager.Element.NONE

func set_checkpoints() -> void:
	# Checkpoint playerController data
	checkpoint_gold = gold
	checkpoint_active_towers = active_towers
	GameManager.set_checkpoint_base_health() # kind of a round-about way to do this...

func update_tower_button_sprites() -> void:
	tower_menu.set_tower_button_sprites(gold, prices[GameManager.Element.FIRE],prices[GameManager.Element.EARTH],prices[GameManager.Element.WATER])

func on_mouse_entered_button() -> void:
	click_enabled = false

func on_mouse_exited_button() -> void:
	click_enabled = true
