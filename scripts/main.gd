class_name Main
extends Node2D

@onready var pause_menu: PauseMenu = $UI/PauseMenu
@onready var bestiary_menu: BestiaryMenu = $UI/BestiaryMenu
# @onready var player_controller: PlayerController = %PlayerController
@onready var player_character: PlayerCharacter = %PlayerCharacter
@onready var coin_drop_manager: CoinDropManager = %CoinDropManager
@onready var mana_drop_manager: ManaDropManager = %ManaDropManager
@onready var fps_label: Label = %FPSLabel
@onready var level_complete_panel: LevelCompletePanel = %LevelCompletePanel
@onready var perk_manager: PerkManager = %PerkManager
@onready var perk_ui: PerkUI = %PerkUI
var player_spawn_point: Node2D

var active_level: LevelEnvironment
var can_pause: bool = false

var wave_failures: int = 0

const PERK_UI_POPUP_DELAY: float = .1

# func _input(_event):
# 	if Input.is_action_just_pressed("x"):
# 		pause_game_with_perk_ui()

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
	AlertManager.configure_level()

	# Configure EnemySpawner
	EnemySpawner.player = player_character

	# Connect to WaveManager
	WaveManager.wave_started.connect(on_wave_started)

	# Configure TowerGlobalData
	TowerGlobalData.reset()
	TowerGlobalData.tower_max = active_level.max_towers

	# Configure PlayerCharacter
	player_spawn_point = active_level.player_spawn_point
	player_character.spawn_point = player_spawn_point.global_position
	player_character.global_position = player_character.spawn_point
	player_character.on_tower_mana_collected(active_level.initial_gold)
	player_character.player_respawned.connect(active_level.base.take_damage.bind(1))
	player_character.player_input.escape_pressed.connect(on_escape_pressed)
	player_character.player_hud.level_requires_banner = active_level.show_level_details

	# Configure CoinDrop Manager and Coin Collector
	EnemySpawner.enemy_spawned_with_ref.connect(coin_drop_manager.on_enemy_spawned)
	player_character.coin_collector.reward_collected.connect(coin_drop_manager.decrement_reward_remaining)
	coin_drop_manager.player = player_character

	# Configure ManaDropManager
	EnemySpawner.enemy_died_with_global_pos_drop_chance.connect(mana_drop_manager.on_enemy_died)
	mana_drop_manager.initialize(player_character.player_spells)
	mana_drop_manager.player = player_character
	player_character.player_spell_perk_manager.spell_mana_drop_perk_bonus_incremented.connect(mana_drop_manager.on_spell_mana_drop_perk_bonus_incremented)
	player_character.player_spell_perk_manager.spell_mana_drop_chance_multiplier_added.connect(mana_drop_manager.on_spell_mana_drop_chance_multiplier_added)
	player_character.player_spell_perk_manager.spawn_tower_mana_as_spell_mana_chance_incremented.connect(coin_drop_manager.on_spawn_tower_mana_as_spell_mana_chance_incremented)
	coin_drop_manager.spell_mana_spawn_requested.connect(mana_drop_manager.on_spell_mana_spawn_requested)

	# Configure PauseMenu
	pause_menu.parent_scene = self
	pause_menu.restart.show()
	if not active_level.show_pause_menu_restart:
		pause_menu.restart.hide()
	
	# Configure Bestiary	
	bestiary_menu.parent_scene = self
	bestiary_menu.add_entries()
	EnemySpawner.enemy_spawned_with_ref.connect(bestiary_menu.on_enemy_spawned)

	# Configure TowerManaBreakables
	for breakable: Breakable in active_level.tower_mana_breakables:
		breakable.coin_dropped.connect(coin_drop_manager.spawn_coin_drop)

	# # Configure PerkManager
	# perk_manager.initialize(player_character.player_data.perk_data_pool, player_character.player_spells, player_character.player_build)
	# perk_manager.perk_ui = perk_ui
	# perk_manager.player_perk_manager = player_character.player_perk_manager
	# perk_manager.player_mana_drop_collector = player_character.mana_drop_collector
	# perk_manager.player_hurtbox = player_character.player_hurtbox
	# perk_manager.player_spell_spawner = player_character.player_spell_spawner
	# perk_manager.base_perk_manager = active_level.base.base_perk_manager
	# perk_manager.player_spell_perk_manager = player_character.player_spell_perk_manager
	# perk_manager.player_special = player_character.player_special

	# Configure PerkUI
	# player_character.player_hud.wave_complete_banner_animation_finished.connect(pause_game_with_perk_ui)

	player_character.player_hud.wave_complete_banner_animation_finished.connect(on_banner_animation_finished)

	# perk_ui.perk_selected.connect(on_perk_selected)
	player_character.player_input.switch_selection_pressed.connect(perk_ui.switch_selected_card)
	player_character.player_input.ui_interact_pressed.connect(perk_ui.select_card)
	player_character.player_input = player_character.player_input
	perk_ui.main = self

	# Configure LevelEnvironment's TallGrass
	for tall_grass: TallGrass in active_level.tall_grass_parent.get_children():
		player_character.player_stopped.connect(tall_grass.on_player_stopped)
		player_character.player_moving.connect(tall_grass.on_player_moving)

	# Hide Cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

	if active_level.start_first_wave_immediately:
		WaveManager.start_wave()

	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.AMBIANCE_WIND_1)
	MusicManager.create_audio(MusicData.MUSIC_TRACK.COZY)

func on_banner_animation_finished() -> void:
	player_character.player_input.input_enabled = true
	player_character.player_input.can_start_wave = true
	player_character.player_hud.configure_for_next_wave()

func on_escape_pressed() -> void:
	if can_pause:
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

# func pause_game_with_perk_ui() -> void:
	pass
	# await get_tree().create_timer(PERK_UI_POPUP_DELAY).timeout
	# player_character.player_input.input_enabled = false

	# # Show Perk Menu, hide player info
	# player_character.player_build_ui.hide()
	# player_character.player_hud.hide()

	# # Create perk hand, update perk ui'
	# var perk_hand: Array[PerkData] = perk_manager.get_perk_hand()
	# var rarity = perk_manager.current_perk_hand_rarity
	# perk_ui.set_rarity_label(rarity)
	# perk_ui.set_card_data(perk_hand)
	# perk_ui.show()
	# perk_ui.animate(rarity)

	# if not GlobalSettings.controller_active:
	# 	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# await perk_ui.animation_complete
	# get_tree().paused = true

# func on_perk_selected(perk_data: PerkData) -> void:
# 	perk_ui.animate_reset()
# 	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
# 	player_character.player_hud.show()
# 	player_character.player_hud.add_perk_mini_icon(perk_data.perk_mini_icon)
# 	perk_manager.create_perk(perk_data)

# 	if player_character.building:
# 		player_character.player_build_ui.show()

func show_level_complete() -> void:
	level_complete_panel.set_stars(calc_stars())
	# player_controller.tower_menu.hide()
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

func on_unpause_menu_restart_level() -> void:
	get_tree().paused = false
	LevelManager.restart_level()

func on_unpause_menu_exit_level() -> void:
	get_tree().paused = false
	LevelManager.exit_level()

func on_wave_started() -> void:
	player_character.player_input.can_start_wave = false
