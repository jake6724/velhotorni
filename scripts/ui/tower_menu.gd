class_name TowerMenu
extends Control

# Child References
@onready var fire_button: TextureButton = %FireButton
@onready var water_button: TextureButton = %WaterButton
@onready var wind_button: TextureButton = %WindButton
@onready var earth_button: TextureButton = %EarthButton
@onready var light_button: TextureButton = %LightButton
@onready var dark_button: TextureButton = %DarkButton

@onready var all_tower_buttons: Array[TextureButton] = []

@onready var tower_buttons: HBoxContainer = %TowerButtons
@onready var gold: Label = %Gold
@onready var wave_button: TextureButton = %WaveButton
@onready var wave_number: Label = %WaveNumber
@onready var level_number: Label = %LevelNumber
@onready var progress: Label = %Progress
@onready var fast_forward: TextureButton = %FastForward

@onready var left_tower_info_panel: TowerInfoPanel = %LeftTowerInfoPanel
@onready var right_tower_info_panel: TowerInfoPanel = %RightTowerInfoPanel

var ui_tower_sprites: Dictionary[Constants.Element, Texture] = {
 	Constants.Element.FIRE: preload("res://assets/art/sprites/ui/spr_ui_tower_fire.png"),
	Constants.Element.WIND: preload("res://assets/art/sprites/ui/spr_ui_tower_wind.png"),
	Constants.Element.WATER: preload("res://assets/art/sprites/ui/spr_ui_tower_water.png"),
	Constants.Element.EARTH: preload("res://assets/art/sprites/ui/spr_ui_tower_earth.png"),
	Constants.Element.LIGHT: preload("res://assets/art/sprites/ui/spr_ui_tower_light.png"),
	Constants.Element.DARK: preload("res://assets/art/sprites/ui/spr_ui_tower_dark.png"),
}

var locked_ui_tower_sprites: Dictionary[Constants.Element, Texture] = {
	Constants.Element.FIRE: preload("res://assets/art/sprites/ui/spr_ui_tower_fire_locked.png"),
	Constants.Element.WIND: preload("res://assets/art/sprites/ui/spr_ui_tower_wind_locked.png"),
	Constants.Element.WATER: preload("res://assets/art/sprites/ui/spr_ui_tower_water_locked.png"),
	Constants.Element.EARTH: preload("res://assets/art/sprites/ui/spr_ui_tower_earth_locked.png"),
	Constants.Element.LIGHT: preload("res://assets/art/sprites/ui/spr_ui_tower_light_locked.png"),
	Constants.Element.DARK: preload("res://assets/art/sprites/ui/spr_ui_tower_dark_locked.png"),
}

# Signals
signal tower_selected
signal start_wave
signal mouse_entered_button
signal mouse_exited_button

var wave_number_timer: Timer = Timer.new()
var wave_number_duration: float = 1.0

var level_number_timer: Timer = Timer.new()
var level_number_duration: float = 2.0

func _ready():
	# Configure tower buttons
	all_tower_buttons = [fire_button, water_button, wind_button, earth_button, light_button, dark_button]
	for b: TextureButton in all_tower_buttons:
			b.pressed.connect(on_button_pressed.bind(b))
			b.mouse_entered.connect(on_mouse_entered_button.bind(b))
			b.mouse_exited.connect(on_mouse_exited_button)

	wave_button.pressed.connect(on_wave_button_pressed)
	wave_button.mouse_entered.connect(on_mouse_entered_button.bind(wave_button))
	wave_button.mouse_exited.connect(on_mouse_exited_button)

	fast_forward.button_down.connect(on_start_fast_forward)
	fast_forward.button_up.connect(on_stop_fast_forward)

	# Configure timers
	wave_number_timer.timeout.connect(on_wave_number_timer_timeout)
	wave_number_timer.one_shot = true
	add_child(wave_number_timer)

	level_number_timer.timeout.connect(on_level_number_timer_timeout)
	level_number_timer.one_shot = true
	add_child(level_number_timer)

func hide_placement_phase() -> void:
	tower_buttons.hide()
	wave_button.hide()
	fast_forward.show()

func show_placement_phase() -> void:
	tower_buttons.show()
	wave_button.show()
	fast_forward.hide()

func hide_shop() -> void:
	tower_buttons.hide()
	wave_button.hide()

func show_shop() -> void:
	tower_buttons.show()
	wave_button.show()

func show_level_number() -> void:
	level_number.text = LevelManager.active_level.level_name
	level_number.show()
	# Start timer which will automatically hide level number after timeout
	level_number_timer.start(level_number_duration)

func on_button_pressed(pressed_button: TextureButton):
	match pressed_button:
		fire_button: tower_selected.emit(Constants.Element.FIRE)
		wind_button: tower_selected.emit(Constants.Element.WIND)
		water_button: tower_selected.emit(Constants.Element.WATER)
		earth_button: tower_selected.emit(Constants.Element.EARTH)
		light_button: tower_selected.emit(Constants.Element.LIGHT)
		dark_button: tower_selected.emit(Constants.Element.DARK)

## Intended to be called by `player_controller` to directly update gold count
func update_gold(new_amount: int) -> void:
	gold.text = str(new_amount)

func set_tower_button_sprites(_gold: float):
	for button: TextureButton in all_tower_buttons:
		var element: Constants.Element
		match button:
			fire_button: element = Constants.Element.FIRE
			wind_button: element = Constants.Element.WIND
			water_button: element = Constants.Element.WATER
			earth_button: element = Constants.Element.EARTH
			light_button: element = Constants.Element.LIGHT
			dark_button:element = Constants.Element.DARK

		if _gold >= Constants.TOWER_PRICES[element]:
			button.texture_normal = ui_tower_sprites[element]
		else:
			button.texture_normal = locked_ui_tower_sprites[element]

func update_progress():
	progress.text = str(LevelManager.level_index) + "-" + str(WaveManager.wave_index+1)

func on_wave_button_pressed() -> void:
	start_wave.emit()

func on_wave_number_timer_timeout():
	wave_number.hide()

func display_wave_info():
	wave_number.text = "Wave " + str(WaveManager.wave_index+1)
	wave_number.show()
	wave_number_timer.start(wave_number_duration)

func on_level_number_timer_timeout():
	level_number.hide()
	$AnimationPlayer.play("flash")

func on_start_fast_forward():
	Engine.time_scale = Constants.FAST_FORWARD_SPEED

func on_stop_fast_forward():
	Engine.time_scale = 1

func on_mouse_entered_button(_button: TextureButton):
	var element: Constants.Element
	match _button:
			fire_button: element = Constants.Element.FIRE
			wind_button: element = Constants.Element.WIND
			water_button: element = Constants.Element.WATER
			earth_button: element = Constants.Element.EARTH
			light_button: element = Constants.Element.LIGHT
			dark_button:element = Constants.Element.DARK
			wave_button: element = Constants.Element.NONE

	mouse_entered_button.emit(element)

func on_mouse_exited_button():
	mouse_exited_button.emit()

# Info panel functions
func show_tower_info_panel(_tower: Tower) -> void:
	if _tower.global_position.x > ((WorldGrid.width * Constants.CELL_SIZE) / 2):
		left_tower_info_panel.update_stats(_tower)
		left_tower_info_panel.show()
	else:
		right_tower_info_panel.update_stats(_tower)
		right_tower_info_panel.show()

func hide_tower_info_panels() -> void:
	left_tower_info_panel.hide()
	right_tower_info_panel.hide()

func show_tower_info_panel_shop(_tower_data: TowerData) -> void:
	left_tower_info_panel.update_stats_shop(_tower_data)
	left_tower_info_panel.show()

func hide_tower_info_panel_shop() -> void:
	left_tower_info_panel.hide()
