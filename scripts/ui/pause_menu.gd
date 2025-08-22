class_name PauseMenu
extends Control

@onready var sfx_volume_slider: HSlider = %SFXVolumeSlider
@onready var sfx_check_box: CheckBox = %SFXCheckBox
@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var music_check_box: CheckBox = %MusicCheckBox
@onready var resume_button: Button = %ResumeButton
@onready var exit_button: Button = %ExitButton
@export var main: Main # Set in editor

var main_menu: PackedScene = load("res://scenes/MainMenu.tscn") # Don't make pre-load; weird circular dep issue

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	# SFX
	sfx_volume_slider.value = SFXPlayer.volume_linear
	sfx_volume_slider.value_changed.connect(on_sfx_volume_changed)
	sfx_check_box.pressed.connect(on_sfx_check_pressed)

	if SFXPlayer.volume_linear == 0:
		sfx_check_box.button_pressed = false

	# Music
	music_volume_slider.value = MusicPlayer.bus_volume_linear
	music_volume_slider.value_changed.connect(on_music_volume_changed)
	music_check_box.pressed.connect(on_music_check_pressed)

	if MusicPlayer.bus_volume_linear == 0:
		music_check_box.button_pressed = false			

	# Resume/exit buttons
	resume_button.pressed.connect(on_resume_button_pressed)
	exit_button.pressed.connect(on_exit_button_pressed)

func on_sfx_volume_changed(_value):
	if _value == 0:
		sfx_check_box.button_pressed = false
	else:
		sfx_check_box.button_pressed = true
	SFXPlayer.volume_linear = _value
	SFXPlayer.update_bus_volume(_value)

func on_sfx_check_pressed():
	if sfx_check_box.button_pressed: # Checked
		SFXPlayer.volume_linear = sfx_volume_slider.value
		SFXPlayer.update_bus_volume(sfx_volume_slider.value)
	else:
		SFXPlayer.volume_linear = 0
		SFXPlayer.update_bus_volume(0)

func on_music_volume_changed(_value):
	if _value == 0:
		MusicPlayer.bus_volume_linear = _value
		music_check_box.button_pressed = false
	else:
		music_check_box.button_pressed = true
	MusicPlayer.bus_volume_linear = _value
	MusicPlayer.update_bus_volume(_value)

func on_music_check_pressed():
	if music_check_box.button_pressed: # Checked
		MusicPlayer.bus_volume_linear = music_volume_slider.value
		MusicPlayer.update_bus_volume(music_volume_slider.value)
	else:
		MusicPlayer.bus_volume_linear = 0.0
		MusicPlayer.update_bus_volume(0.0)

func on_resume_button_pressed():
	main.unpause_game_with_menu()

func on_exit_button_pressed():
	main.unpause_game_with_menu()
	SceneTransition.change_scene(main_menu)
	LevelManager.level_index = 1 # TODO: Make 0 or most recent once loading is in
	WaveManager.wave_failed.emit()
  
