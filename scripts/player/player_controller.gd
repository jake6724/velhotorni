class_name PlayerController
extends Node2D

# Child References
@onready var tower_menu: TowerMenu = $UI/TowerMenu

# Scenes
var towers: Dictionary[String, PackedScene] = {
	"fire": preload("res://scenes/towers/FireTower.tscn"),
	"water": preload("res://scenes/towers/WaterTower.tscn"),
	"earth": preload("res://scenes/towers/EarthTower.tscn"),
}

var textures: Dictionary[String, Texture] = {
	"fire": preload("res://assets/art/sprites/spr_tower_fire.png"),
	"water": preload("res://assets/art/sprites/spr_tower_water.png"),
	"earth": preload("res://assets/art/sprites/spr_tower_earth.png"),
}

var placement_indicator: PackedScene = preload("res://scenes/towers/PlacementIndicator.tscn")
var indicator: Node2D

var prices: Dictionary[String, int] = {
	"fire": 25,
	"water": 75,
	"earth": 50,
}

var click_enabled: bool = true

var selected_tower_name: String
var active_towers: Array[Tower] = []
var transformed_towers: Dictionary[Tower, int] = {}
var pre_wave_towers: Array[Tower] = [] # Original configuration of towers during placement; allows transformed towers to reset 

var placement_enabled: bool = true

var gold: int
var reward: float

func _ready():
	# ** EVERYTHING in here will only be done ONCE. If something needs to be done each level, put in configure_level()
	gold = GameManager.active_level.initial_gold

	# Configure tower menu
	tower_menu.tower_selected.connect(on_tower_selected)
	tower_menu.mouse_entered_button.connect(on_mouse_entered_button)
	tower_menu.mouse_exited_button.connect(on_mouse_exited_button)

	tower_menu.show_level_number()
	tower_menu.update_gold(gold) # get this from GameManager active_level
	tower_menu.set_tower_button_sprites(gold, prices["fire"],prices["earth"],prices["water"])
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

func _process(_delta):
	if placement_enabled and selected_tower_name in towers:
		indicator.position = GameManager.grid_to_world(GameManager.world_to_grid(get_global_mouse_position()))
	else:
		indicator.hide()

## Place a tower in the world grid. Return true if successful, false if not. If `is_tranform` is `true`, the gold
## cost of the tower will not be subtracted from player gold.
func spawn_tower(tower_name: String, world_pos: Vector2, is_transform: bool=false) -> Array: # [was_spawned:bool, Tower]
	# Do not allow placement during combat
	if not placement_enabled and not is_transform:
		return [false, null]

	if tower_name in towers:
		var grid_pos: Vector2 = GameManager.world_to_grid(world_pos)

		if grid_pos in WorldGrid.data: 
			if WorldGrid.data[grid_pos]:
				# Spawn and configure new tower
				var tower = towers[tower_name].instantiate()
				tower.position = GameManager.grid_to_world(grid_pos) # Bring it back to world to get a clean grid point
				# Connect to signals (this needs be done in copy_active_towers_to_prewave_towers() as well!)
				tower.transform_tower.connect(on_tower_transform.bind(tower))
				tower.tower_hovered.connect(on_tower_hovered)
				tower.tower_unhovered.connect(on_tower_unhovered)
				add_child(tower)

				# Update related data
				active_towers.append(tower)
				WorldGrid.data[grid_pos] = false
				if not is_transform:
					gold -= prices[tower_name]
					tower_menu.update_gold(gold)

				# Clean up indicator
				indicator.hide()
				tower_menu.set_tower_button_sprites(gold, prices["fire"],prices["earth"],prices["water"])
				play_tower_select_sfx(tower_name)

				selected_tower_name = ""
				return [true, tower]
			else:
				SFXPlayer.play_sfx("click_2")
				return [false, null]
		else:
			return [false, null]
	else:
		return [false, null]

func on_tower_selected(tower_name: String) -> void:
	# Check player can afford tower
	if gold >= prices[tower_name]:
		selected_tower_name = tower_name

		match tower_name:
			"fire": SFXPlayer.play_sfx("fire_click")
			"earth": SFXPlayer.play_sfx("earth_click")
			"water": SFXPlayer.play_sfx("water_click")

		# Indicator
		indicator.tower_sprite.texture = textures[tower_name]
		indicator.show()
	else:
		SFXPlayer.play_sfx("click_2")

func on_tower_transform(tower: Tower) -> void:
	# Only allow transformation if player not in placement phase and not tower was not previously transformed this wave
	if not placement_enabled and not transformed_towers.has(tower):
		# Remove old tower from active towers
		active_towers.remove_at(active_towers.find(tower))

		# Find what type of tower should replace it
		var next_tower_name: String = get_next_tower_name(tower)

		# Remove old tower, clear map position
		var _world_pos: Vector2 = tower.position
		var _grid_pos: Vector2 = GameManager.world_to_grid(_world_pos)
		WorldGrid.data[_grid_pos] = true
		tower.queue_free()

		# Spawn new tower, add to set
		var new_tower: Tower = spawn_tower(next_tower_name, _world_pos, true)[1]
		transformed_towers[new_tower] = 0

		SFXPlayer.play_sfx("click_1")

	else:
		SFXPlayer.play_sfx("click_2")

func get_next_tower_name(tower: Tower) -> String:
	# fire -> earth -> water -> fire
	match tower.element:
		GameManager.Element.FIRE: return "earth"
		GameManager.Element.EARTH: return "water"
		GameManager.Element.WATER: return "fire"
	return "" # Should never be reached.

func on_start_wave() -> void:
	tower_menu.hide_placement_phase()
	placement_enabled = false
	copy_active_towers_to_prewave_towers()
	transformed_towers = {}

	# Enemy Spawner
	EnemySpawner.start_wave()
	reward = EnemySpawner.active_wave.reward

	SFXPlayer.play_sfx("go")

func on_wave_complete() -> void:
	# Update variables
	placement_enabled = true	
	gold += int(reward)
	tower_menu.set_tower_button_sprites(gold, prices["fire"],prices["earth"],prices["water"])

	# Tower Menu config
	if EnemySpawner.wave_index != EnemySpawner.level_waves.size():
		tower_menu.show_placement_phase()
		tower_menu.update_gold(int(gold))
		reset_towers()
		tower_menu.update_progress()

## For each tower in `active_towers` create a new tower object in `pre_wave_towers` with the same attributes. 
## This is a NEW `Tower` object and NOT a reference.
func copy_active_towers_to_prewave_towers() -> void:
	for tower: Tower in active_towers:
		var copy: Tower = towers[tower.tower_name].instantiate()
		copy.position = tower.position
		copy.transform_tower.connect(on_tower_transform.bind(copy))
		copy.tower_hovered.connect(on_tower_hovered)
		copy.tower_unhovered.connect(on_tower_unhovered)
		pre_wave_towers.append(copy)

func reset_towers() -> void:
	# Clear all active towers and replace them with towers from pre_wave_towers
	for tower: Tower in active_towers:
		tower.queue_free()
	
	for tower: Tower in pre_wave_towers:
		add_child(tower)

	# Active towers becomes pre_wave; pre_wave is reset
	active_towers = pre_wave_towers
	pre_wave_towers = []

func on_tower_hovered(tower: Tower):
	if not placement_enabled:
		if tower.can_transform:
			if transformed_towers.has(tower) and not tower.cross_sprite.is_visible():
				tower.cross_sprite.show()
			else:
				tower.swap_sprite.show()
		else:
			tower.cross_sprite.show()		

func on_tower_unhovered(tower: Tower):
	if not placement_enabled:
		# Could check to see which but I don't think it is that important rn
		tower.swap_sprite.hide()
		tower.cross_sprite.hide()

func play_tower_select_sfx(tower_name: String) -> void:
	match tower_name:
		"fire": SFXPlayer.play_sfx("fire_select")
		"earth": SFXPlayer.play_sfx("earth_select")
		"water": SFXPlayer.play_sfx("water_select")

func on_enemy_died():
	gold += 1
	tower_menu.update_gold(gold)

func _input(_event):
	if click_enabled and Input.is_action_just_pressed("left_click"):
		spawn_tower(selected_tower_name, get_global_mouse_position(), false)

	if click_enabled and Input.is_action_just_pressed("right_click"):
		if selected_tower_name:
			selected_tower_name = ""

func on_mouse_entered_button() -> void:
	click_enabled = false

func on_mouse_exited_button() -> void:
	click_enabled = true
