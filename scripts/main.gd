class_name Main
extends Node2D

@onready var round_info: RoundInfo = $UI/RoundInfo
@onready var pause_menu: PauseMenu = $UI/PauseMenu
@onready var bestiary_menu: BestiaryMenu = $UI/BestiaryMenu
@onready var player_controller: PlayerController = %PlayerController
@onready var player_character: PlayerCharacter = %PlayerCharacter
@onready var coin_drop_manager: CoinDropManager = %CoinDropManager
@onready var mana_drop_manager: ManaDropManager = %ManaDropManager
@onready var fps_label: Label = %FPSLabel
@onready var level_complete_panel: LevelCompletePanel = %LevelCompletePanel
@onready var perk_manager: PerkManager = %PerkManager
@onready var perk_ui: PerkUI = %PerkUI
var player_spawn_point: Node2D

var active_level: LevelEnvironment
var exit_scene: PackedScene = load("res://scenes/level/world_map/WorldMap.tscn") # passed to PauseMenu
var can_pause: bool = false

var wave_failures: int = 0

const PERK_UI_POPUP_DELAY: float = 2.0

func _ready():
	SceneTransition.scene_transition_complete.connect(set_can_pause.bind(true))
	
	# Configure with data from LevelManager
	LevelManager.configure_level(self)
	active_level = LevelManager.active_level
	add_child(active_level)

	# Configure other singletons
	WorldGrid.configure_level(LevelManager.active_level)
	WaveManager.configure_level(LevelManager.active_level)
	EnemySpawner.configure_level(LevelManager.active_level)
	TowerGlobalData.reset()

	# Configure EnemySpawner
	EnemySpawner.player = player_character

	# Connect to WaveManager
	WaveManager.wave_failed.connect(on_wave_failed)

	# Configure TowerGlobalData
	TowerGlobalData.reset()
	TowerGlobalData.tower_max = active_level.max_towers

	# Configure PlayerController
	player_controller.setup()
	player_controller.bestiary_pressed.connect(pause_game_with_bestiary)
	coin_drop_manager.reward_completed.connect(player_controller.on_reward_complete)
	player_controller.coin_collector = player_character.coin_collector

	# Configure PlayerCharacter
	player_spawn_point = active_level.player_spawn_point
	player_character.spawn_point = player_spawn_point.global_position
	player_character.global_position = player_character.spawn_point
	player_character.on_tower_mana_collected(active_level.initial_gold)
	player_character.player_respawned.connect(active_level.base.take_damage.bind(1))

	# Configure CoinDrop Manager and Coin Collector
	EnemySpawner.enemy_spawned_with_ref.connect(coin_drop_manager.on_enemy_spawned)
	player_character.coin_collector.reward_collected.connect(coin_drop_manager.decrement_reward_remaining)

	# Configure ManaDropManager
	EnemySpawner.enemy_died_with_global_pos_drop_chance.connect(mana_drop_manager.on_enemy_died)
	mana_drop_manager.initialize(player_character.player_spells)

	# Configure PauseMenu
	pause_menu.parent_scene = self
	pause_menu.exit_scene = exit_scene
	pause_menu.restart.show()

	# Configure Bestiary
	bestiary_menu.parent_scene = self
	bestiary_menu.add_entries()
	EnemySpawner.enemy_spawned_with_ref.connect(bestiary_menu.on_enemy_spawned)

	# Configure TowerManaBreakables
	for breakable: Breakable in active_level.tower_mana_breakables:
		breakable.coin_dropped.connect(coin_drop_manager.spawn_coin_drop)

	# Configure PerkManager
	perk_manager.initialize(player_character.perk_pool_data)
	perk_manager.perk_ui = perk_ui
	perk_manager.player_perk_manager = player_character.player_perk_manager
	perk_manager.player_mana_drop_collector = player_character.mana_drop_collector
	perk_manager.player_hurtbox = player_character.player_hurtbox
	perk_manager.player_spell_spawner = player_character.player_spell_spawner
	perk_manager.base_perk_manager = active_level.base.base_perk_manager
	perk_manager.player_spell_perk_manager = player_character.player_spell_perk_manager

	# Configure PerkUI
	WaveManager.wave_completed.connect(on_wave_completed)
	perk_ui.perk_selected.connect(on_perk_selected)
	player_character.player_input.switch_selection_pressed.connect(perk_ui.switch_selected_card)
	player_character.player_input.ui_interact_pressed.connect(perk_ui.select_card)
	player_character.player_input = player_character.player_input
	perk_ui.main = self

	# Hide Cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	if active_level.start_first_wave_immediately:
		WaveManager.start_wave()

func _input(_event):
	if Input.is_action_just_pressed("escape"): # TODO: Input action change
		if can_pause and not player_controller.menu_open:
			pause_game_with_menu()

func pause_game():
	get_tree().paused = true

func unpause_game():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false

func unpause_from_perk_ui() -> void:
	get_tree().paused = false
	perk_ui.hide()

func pause_game_with_menu():
	if not GlobalSettings.controller_active:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pause_menu.show()
	get_tree().paused = true

func unpause_game_with_menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pause_menu.hide()
	get_tree().paused = false

func pause_game_with_bestiary() -> void:
	bestiary_menu.show()
	get_tree().paused = true

func unpause_game_with_bestiary() -> void:
	bestiary_menu.hide()
	get_tree().paused = false

func set_can_pause(value: bool) -> void:
	can_pause = value

func on_wave_completed() -> void:
	pause_game_with_perk_ui()

func pause_game_with_perk_ui() -> void:
	await get_tree().create_timer(PERK_UI_POPUP_DELAY).timeout
	
	player_character.player_input.input_enabled = false

	# Show Perk Menu, hide player info
	player_character.player_build_ui.hide()
	player_character.player_hud.hide()

	# Create perk hand, update perk ui
	var perk_hand: Array[PerkData] = perk_manager.get_perk_hand()
	perk_ui.set_card_data(perk_hand)
	perk_ui.show()
	perk_ui.animate()

	if not GlobalSettings.controller_active:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	get_tree().paused = true

func on_perk_selected(perk_data: PerkData) -> void:
	perk_ui.animate_reset()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	player_character.player_hud.show()
	perk_manager.create_perk(perk_data)

	if player_character.building:
		player_character.player_build_ui.show()
	
	player_character.player_input.input_enabled = true

func on_wave_failed() -> void:
	wave_failures += 1

func show_level_complete() -> void:
	level_complete_panel.set_stars(calc_stars())
	player_controller.tower_menu.hide()
	level_complete_panel.show()

func calc_stars() -> int:
	var count: int = 2
	if wave_failures == 0:
		count += 1
		if active_level.base.health == 10:
			count += 1
	
	if count > StarRegistry.stars[LevelManager.levels[LevelManager.level_index]]:
		StarRegistry.stars[LevelManager.levels[LevelManager.level_index]] = count

	return count
