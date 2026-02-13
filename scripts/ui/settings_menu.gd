class_name SettingsMenu
extends NinePatchRect

@onready var sfx_volume_slider: HSlider = %SFXVolumeSlider
@onready var sfx_check_box: CheckBox = %SFXCheckBox
@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var music_check_box: CheckBox = %MusicCheckBox

@onready var back: NinePatchRect = %Back
@onready var back_button: Button = %BackButton

signal back_button_pressed

func _ready():
	if MusicPlayer.bus_volume_linear == 0:
		music_check_box.button_pressed = false			

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

	# Configure BackButton
	back_button.pressed.connect(on_back_button_pressed)

	# Configure Highlighting
	back.mouse_entered.connect(highlight_ui_element.bind(back))
	back.mouse_exited.connect(un_highlight_ui_element.bind(back))

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

func on_back_button_pressed() -> void:
	back_button_pressed.emit()

func highlight_ui_element(ui_element: Control) -> void:
	ui_element.self_modulate = Color(Constants.ui_color_select)

func un_highlight_ui_element(ui_element: Control) -> void:
	ui_element.self_modulate = Color.WHITE