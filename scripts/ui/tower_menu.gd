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

@onready var gold: Label = %Gold
@onready var token: Label = %Token
@onready var token_bar: HBoxContainer = %TokenBar

@onready var tower_buttons: HBoxContainer = %TowerButtons
@onready var wave_button: TextureButton = %WaveButton
@onready var wave_number: Label = %WaveNumber
@onready var level_number: Label = %LevelNumber
@onready var progress: Label = %Progress
@onready var fast_forward: TextureButton = %FastForward

@onready var eye_button: TextureButton = %EyeButton
@onready var bestiary_button: TextureButton = %BestiaryButton

@onready var fire_price_label: Label = %FirePriceLabel
@onready var wind_price_label: Label = %WindPriceLabel
@onready var water_price_label: Label = %WaterPriceLabel
@onready var earth_price_label: Label = %EarthPriceLabel
@onready var light_price_label: Label = %LightPriceLabel
@onready var dark_price_label: Label = %DarkPriceLabel

@onready var left_tower_info_panel: TowerInfoPanel = %LeftTowerInfoPanel
@onready var right_tower_info_panel: TowerInfoPanel = %RightTowerInfoPanel

@onready var wave_preview_panel: WavePreviewPanel = %WavePreviewPanel
@onready var cycle_indicator: NinePatchRect = %CycleIndicator

@onready var boss_info: VBoxContainer = %BossInfo
@onready var boss_healthbar: BossHealthbar = %BossHealthbar
@onready var boss_label: Label = %BossLabel

var ui_tower_sprites: Dictionary[Constants.Element, Texture] = {
 	Constants.Element.FIRE: load("res://assets/art/sprites/ui/spr_ui_tower_fire.png"),
	Constants.Element.WIND: load("res://assets/art/sprites/ui/spr_ui_tower_wind.png"),
	Constants.Element.WATER: load("res://assets/art/sprites/ui/spr_ui_tower_water_fish.png"),
	Constants.Element.EARTH: load("res://assets/art/sprites/ui/spr_ui_tower_earth.png"),
	Constants.Element.LIGHT: load("res://assets/art/sprites/ui/spr_ui_tower_light.png"),
	Constants.Element.DARK: load("res://assets/art/sprites/ui/spr_ui_tower_dark.png"),
}

var locked_ui_tower_sprites: Dictionary[Constants.Element, Texture] = {
	Constants.Element.FIRE: load("res://assets/art/sprites/ui/spr_ui_tower_fire_locked.png"),
	Constants.Element.WIND: load("res://assets/art/sprites/ui/spr_ui_tower_wind_locked.png"),
	Constants.Element.WATER: load("res://assets/art/sprites/ui/spr_ui_tower_water_fish_locked.png"),
	Constants.Element.EARTH: load("res://assets/art/sprites/ui/spr_ui_tower_earth_locked.png"),
	Constants.Element.LIGHT: load("res://assets/art/sprites/ui/spr_ui_tower_light_locked.png"),
	Constants.Element.DARK: load("res://assets/art/sprites/ui/spr_ui_tower_dark_locked.png"),
}

# Signals
signal tower_selected
signal start_wave
signal mouse_entered_button
signal mouse_exited_button
signal bestiary_pressed

var wave_number_timer: Timer = Timer.new()
var wave_number_duration: float = 1.0

var level_number_timer: Timer = Timer.new()
var level_number_duration: float = 2.0

var opened: bool = true

# func _input(_event):
# 	if Input.is_action_just_pressed("x"):
# 		if opened:
# 			var tween: Tween = get_tree().create_tween()
# 			await tween.tween_property(tower_buttons, "theme_override_constants/separation", -32, .25).finished
# 			tower_buttons.hide()
# 			opened = not opened
# 		else:
# 			tower_buttons.show()
# 			var tween: Tween = get_tree().create_tween()
# 			tween.tween_property(tower_buttons, "theme_override_constants/separation", 0, .25)
# 			opened = not opened

func _ready():
	# Configure tower buttons
	all_tower_buttons = [fire_button, water_button, wind_button, earth_button, light_button, dark_button]
	for b: TextureButton in all_tower_buttons:
			b.pressed.connect(on_button_pressed.bind(b))
			b.mouse_entered.connect(on_mouse_entered_button.bind(b))
			b.mouse_exited.connect(on_mouse_exited_button.bind(b))

	wave_button.pressed.connect(on_wave_button_pressed)
	wave_button.mouse_entered.connect(on_mouse_entered_wave_button)
	wave_button.mouse_exited.connect(on_mouse_exited_wave_button)

	fast_forward.button_down.connect(on_start_fast_forward)
	fast_forward.button_up.connect(on_stop_fast_forward)

	eye_button.toggled.connect(on_eye_toggled)

	# Configure timers
	wave_number_timer.timeout.connect(on_wave_number_timer_timeout)
	wave_number_timer.one_shot = true
	add_child(wave_number_timer)

	level_number_timer.timeout.connect(on_level_number_timer_timeout)
	level_number_timer.one_shot = true
	add_child(level_number_timer)

	set_price_labels()

	# Configure Bestiary
	bestiary_button.pressed.connect(on_bestiary_pressed)

func hide_placement_phase() -> void:
	tower_buttons.hide()
	wave_button.hide()
	wave_preview_panel.hide()
	eye_button.hide()

	# cycle_indicator.show()
	# fast_forward.show()

func show_placement_phase() -> void:
	# tower_buttons.show()
	# wave_button.show()
	# wave_preview_panel.show()
	# eye_button.show()

	# cycle_indicator.hide()
	fast_forward.hide()
	# boss_info.hide()

func hide_shop() -> void:
	pass  # don't need this anymore
	# tower_buttons.hide()
	# wave_button.hide()

func show_shop() -> void:
	pass # don't need this anymore
	# tower_buttons.show()
	# wave_button.show()

func show_level_number() -> void:
	level_number.text = LevelManager.active_level.level_name
	# level_number.show()
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

## Intended to be called by `player_controller` to directly update token amount
func update_tokens(new_amount: int) -> void:
	token.text = str(new_amount)
	# if new_amount > 0:
	# 	token_bar.show()
	# else:
	# 	token_bar.hide()
		
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
	progress.text = str(LevelManager.level_index-1) + "-" + str(WaveManager.wave_index+1)

## TODO: DEV TEMP THIS SHOULD NOT STAY HERE
func _input(_event):
	if Input.is_action_just_pressed("start_wave_action"):
		start_wave.emit()

func on_wave_button_pressed() -> void:
	start_wave.emit()

func on_wave_number_timer_timeout():
	wave_number.hide()

func display_wave_info():
	wave_number.text = "Wave " + str(WaveManager.wave_index+1)
	# wave_number.show()
	wave_number_timer.start(wave_number_duration)

func on_level_number_timer_timeout():
	level_number.hide()
	$AnimationPlayer.play("flash")

func on_start_fast_forward():
	TimeManager.set_fast_forward_speed()

func on_stop_fast_forward():
	TimeManager.set_normal_speed()

func on_mouse_entered_button(_button: TextureButton):
	var element: Constants.Element

	var tween: Tween = get_tree().create_tween()
	tween.tween_property(_button, "position", (_button.position + Vector2(0, -3)), .1)

	match _button:
			fire_button: element = Constants.Element.FIRE
			wind_button: element = Constants.Element.WIND
			water_button: element = Constants.Element.WATER
			earth_button: element = Constants.Element.EARTH
			light_button: element = Constants.Element.LIGHT
			dark_button:element = Constants.Element.DARK

	mouse_entered_button.emit(element)

func on_mouse_exited_button(_button):
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(_button, "position", Vector2(0, -3), .1)
	mouse_exited_button.emit()

func on_mouse_entered_wave_button():
	mouse_entered_button.emit(Constants.Element.NONE)

func on_mouse_exited_wave_button():
	mouse_exited_button.emit()

# Info panel functions
func show_tower_info_panel(_tower: Tower, _gold: int) -> void:
	if _tower.global_position.x > ((WorldGrid.width * Constants.CELL_SIZE) / 2):
		left_tower_info_panel.update_stats(_tower, _gold)
		left_tower_info_panel.show()
	else:
		right_tower_info_panel.update_stats(_tower, _gold)
		right_tower_info_panel.show()

func hide_tower_info_panels() -> void:
	left_tower_info_panel.hide()
	right_tower_info_panel.hide()

func show_tower_info_panel_shop(_tower_data: TowerData) -> void:
	pass # 
	# left_tower_info_panel.update_stats_shop(_tower_data)
	# left_tower_info_panel.show()

func hide_tower_info_panel_shop() -> void:
	left_tower_info_panel.hide()

func set_price_labels() -> void:
	fire_price_label.text = str(Constants.TOWER_PRICES[Constants.Element.FIRE])
	wind_price_label.text = str(Constants.TOWER_PRICES[Constants.Element.WIND])
	water_price_label.text = str(Constants.TOWER_PRICES[Constants.Element.WATER])
	earth_price_label.text = str(Constants.TOWER_PRICES[Constants.Element.EARTH])
	light_price_label.text = str(Constants.TOWER_PRICES[Constants.Element.LIGHT])
	dark_price_label.text = str(Constants.TOWER_PRICES[Constants.Element.DARK])

func set_wave_preview(wave_index: int) -> void:
	wave_preview_panel.set_preview_labels(wave_index)

func on_eye_toggled(toggled_on) -> void:
	if toggled_on:
		tower_buttons.hide()
		wave_button.hide()
	else:
		tower_buttons.show()
		wave_button.show()

# BossHealthbar
func on_final_wave_started() -> void:
	boss_info.show()
	cycle_indicator.hide()
	boss_healthbar.boss_max_health = WaveManager.boss_wave_health
	boss_healthbar.boss_health = boss_healthbar.boss_max_health
	boss_label.text = LevelManager.active_level.boss_name

# Bestiary
func on_bestiary_pressed() -> void:
	bestiary_pressed.emit()
