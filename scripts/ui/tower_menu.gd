class_name TowerMenu
extends Control

# Child References
@onready var fire_button: TextureButton = %FireButton
@onready var water_button: TextureButton = %WaterButton
@onready var earth_button: TextureButton = %EarthButton
@onready var tower_buttons: HBoxContainer = %TowerButtons
@onready var gold: Label = %Gold
@onready var wave_button: TextureButton = %WaveButton
@onready var wave_number: Label = %WaveNumber
@onready var level_number: Label = %LevelNumber
@onready var progress: Label = %Progress
@onready var fast_forward: TextureButton = %FastForward

var ui_tower_sprites: Dictionary[GameManager.Element, Texture] = {
	GameManager.Element.FIRE: preload("res://assets/art/sprites/spr_ui_tower_fire.png"),
	GameManager.Element.EARTH: preload("res://assets/art/sprites/spr_ui_tower_earth.png"),
	GameManager.Element.WATER: preload("res://assets/art/sprites/spr_ui_tower_ice.png")
}

var locked_ui_tower_sprites: Dictionary[GameManager.Element, Texture] = {
	GameManager.Element.FIRE: preload("res://assets/art/sprites/spr_ui_tower_fire_locked.png"),
	GameManager.Element.EARTH: preload("res://assets/art/sprites/spr_ui_tower_earth_locked.png"),
	GameManager.Element.WATER: preload("res://assets/art/sprites/spr_ui_tower_ice_locked.png")
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
	var buttons: Array[TextureButton] = [fire_button, water_button, earth_button]
	for b: TextureButton in buttons:
			b.pressed.connect(on_button_pressed.bind(b))
			b.mouse_entered.connect(on_mouse_entered_button)
			b.mouse_exited.connect(on_mouse_exited_button)

	wave_button.pressed.connect(on_wave_button_pressed)
	wave_button.mouse_entered.connect(on_mouse_entered_button)
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

func show_level_number() -> void:
	# level_number.text = "Level " + str(GameManager.level_index + 1)
	level_number.text = GameManager.active_level.level_name
	level_number.show()
	# Start timer which will automatically hide level number after timeout
	level_number_timer.start(level_number_duration)

func on_button_pressed(pressed_button: TextureButton):
	var b_name: String = pressed_button.name.to_lower()
	match b_name:
		"firebutton": tower_selected.emit("fire")
		"waterbutton": tower_selected.emit("water")
		"earthbutton": tower_selected.emit("earth")

## Intended to be called by `player_controller` to directly update gold count
func update_gold(new_amount: int) -> void:
	gold.text = str(new_amount)

func set_tower_button_sprites(_gold: float, fire_price: int , earth_price: int, water_price: int):
	# Set Fire
	if _gold >= fire_price:
		fire_button.texture_normal = ui_tower_sprites[GameManager.Element.FIRE]
	else:
		fire_button.texture_normal = locked_ui_tower_sprites[GameManager.Element.FIRE]
	# Set Earth
	if _gold >= earth_price:
		earth_button.texture_normal = ui_tower_sprites[GameManager.Element.EARTH]
	else:
		earth_button.texture_normal = locked_ui_tower_sprites[GameManager.Element.EARTH]
	# Set Water
	if _gold >= water_price:
		water_button.texture_normal = ui_tower_sprites[GameManager.Element.WATER]
	else:
		water_button.texture_normal = locked_ui_tower_sprites[GameManager.Element.WATER]

func update_progress():
	progress.text = str(GameManager.level_index) + "-" + str(EnemySpawner.wave_index+1)

func on_wave_button_pressed() -> void:
	wave_number.text = "Wave " + str(EnemySpawner.wave_index+1)
	wave_number.show()
	wave_number_timer.start(wave_number_duration)
	start_wave.emit()

func on_wave_number_timer_timeout():
	wave_number.hide()

func on_level_number_timer_timeout():
	level_number.hide()
	$AnimationPlayer.play("flash")

func on_start_fast_forward():
	Engine.time_scale = 2

func on_stop_fast_forward():
	Engine.time_scale = 1

func on_mouse_entered_button():
	mouse_entered_button.emit()

func on_mouse_exited_button():
	mouse_exited_button.emit()
