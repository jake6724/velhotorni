class_name MainMenu
extends Control

@onready var play_button: Button = %PlayButton
@onready var settings_button: Button = %SettingsButton
@onready var credits_button: Button = %CreditsButton

@onready var play: NinePatchRect = %Play
@onready var settings: NinePatchRect = %Settings
@onready var credits: NinePatchRect = %Credits

@onready var title_menu: Control = %TitleMenu
@onready var settings_menu: SettingsMenu = %SettingsMenu
@onready var credits_menu: CreditsMenu = %CreditsMenu

var main_scene: PackedScene = load("res://scenes/Main.tscn")
var world_map: PackedScene = preload("res://scenes/level/world_map/WorldMap.tscn")

func _ready() -> void:
	# Connect to signals
	play_button.pressed.connect(_on_play_button_pressed)

	settings_button.pressed.connect(on_settings_button_pressed)
	settings_menu.back_button_pressed.connect(on_settings_menu_back_button_pressed)

	credits_button.pressed.connect(on_credits_button_pressed)
	credits_menu.back_button_pressed.connect(on_credits_menu_back_button_pressed)

	# Configure Highlighting
	play.mouse_entered.connect(highlight_ui_element.bind(play))
	play.mouse_exited.connect(un_highlight_ui_element.bind(play))	
	settings.mouse_entered.connect(highlight_ui_element.bind(settings))
	settings.mouse_exited.connect(un_highlight_ui_element.bind(settings))	
	credits.mouse_entered.connect(highlight_ui_element.bind(credits))
	credits.mouse_exited.connect(un_highlight_ui_element.bind(credits))

func _on_play_button_pressed() -> void:
	SceneTransition.change_scene(world_map)
	SFXPlayer.play_sfx("click_1")

func on_settings_button_pressed() -> void:
	title_menu.hide()
	settings_menu.show()

func on_settings_menu_back_button_pressed() -> void:
	title_menu.show()
	settings_menu.hide()

func on_credits_button_pressed() -> void:
	title_menu.hide()
	credits_menu.show()

func on_credits_menu_back_button_pressed() -> void:
	title_menu.show()
	credits_menu.hide()

func highlight_ui_element(ui_element: Control) -> void:
	ui_element.self_modulate = Color(Constants.ui_color_select)

func un_highlight_ui_element(ui_element: Control) -> void:
	ui_element.self_modulate = Color.WHITE
