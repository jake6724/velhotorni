class_name WorldMap
extends Node2D

@onready var background_sprite: Sprite2D = $BackgroundSprite
@onready var level_buttons: Control = %LevelButtons
@onready var left_world_map_info_panel: WorldMapInfoPanel = %LeftWorldMapInfoPanel
@onready var right_world_map_info_panel: WorldMapInfoPanel = %RightWorldMapInfoPanel
@onready var pause_menu: PauseMenu = %PauseMenu
@onready var level_toggle_button: TextureButton = %LevelToggleButton
@onready var level_ui: TextureRect = %LevelUI

var background_width: float
var hovered_scale_increment: Vector2 = Vector2(.1, .1)
var hovered_position_offset: Vector2 = Vector2(0, -1)

var hide_timer: Timer = Timer.new()
const HIDE_DELAY: float = .3
const SLIDE_DURATION: float = .35

var can_pause: bool = false
var exit_scene: PackedScene = load("res://scenes/MainMenu.tscn") # passed to PauseMenu
var active_panel: WorldMapInfoPanel

func _ready():
	SceneTransition.scene_transition_complete.connect(set_can_pause.bind(true))
	
	background_width = (background_sprite.texture.get_size().x / 2) + (background_sprite.texture.get_size().x * .1)

	hide_timer.autostart = false
	hide_timer.one_shot = true
	add_child(hide_timer)
	hide_timer.timeout.connect(on_hide_timer_timeout)
	
	# Connect to level buttons
	for button: LevelButton in level_buttons.get_children():
		button.level_hovered.connect(on_level_hovered.bind(button))
		button.level_unhovered.connect(on_level_unhovered.bind(button))
		button.level_button_pressed.connect(on_level_button_pressed)

	# Configure PauseMenu
	pause_menu.parent_scene = self
	pause_menu.exit_scene = exit_scene
	pause_menu.restart.hide()

	# LevelToggleButton
	level_toggle_button.toggled.connect(on_level_toggled)

func on_level_hovered(_level_name: String, _region_name: String, _level_button: LevelButton) -> void:
	_level_button.position += hovered_position_offset
	if _level_button.stars > 0:
		hide_timer.stop()

		if _level_button.global_position.x >= background_width: # Show left panel
			if active_panel and active_panel != left_world_map_info_panel:
				on_hide_timer_timeout()
			active_panel = left_world_map_info_panel
		else:												    # Show right panel
			if active_panel and active_panel != right_world_map_info_panel:
				on_hide_timer_timeout()
			active_panel = right_world_map_info_panel

		active_panel.set_level_name(_level_name)
		active_panel.set_region(_region_name)
		active_panel.set_stars(_level_button.stars)

		var tween: Tween = get_tree().create_tween()
		tween.tween_property(active_panel, "position", active_panel.slide_pos, SLIDE_DURATION)

func on_level_unhovered(_level_button: LevelButton) -> void:
	_level_button.position -= hovered_position_offset
	if _level_button.stars > 0:
		hide_timer.start(HIDE_DELAY)

func on_hide_timer_timeout() -> void:
	if active_panel:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(active_panel, "position", active_panel.original_pos, .4)

func on_level_button_pressed(_level_scene: PackedScene) -> void:
	hide_timer.stop()
	on_hide_timer_timeout()
	LevelManager.load_specific_level(_level_scene)

func _input(_event):
	if Input.is_action_just_pressed("escape"): # TODO: Input action change
		if can_pause:
			pause_game_with_menu()

# PauseMenu functions
func pause_game():
	get_tree().paused = true

func unpause_game():
	get_tree().paused = false

func pause_game_with_menu():
	on_hide_timer_timeout()
	pause_menu.show()
	get_tree().paused = true

func unpause_game_with_menu():
	pause_menu.hide()
	get_tree().paused = false

func set_can_pause(value: bool) -> void:
	can_pause = value

func on_level_toggled(toggled_on: bool) -> void:
	if toggled_on:
		level_ui.hide()
	else:
		level_ui.show()
