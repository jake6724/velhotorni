class_name PauseMenu
extends Control

@onready var pause_menu: NinePatchRect = %PauseMenu
@onready var settings_menu: SettingsMenu = %SettingsMenu

@onready var resume_button: Button = %ResumeButton
@onready var exit_button: Button = %ExitButton
@onready var settings_button: Button = %SettingsButton
@onready var restart_button: Button = %RestartButton

@onready var resume: NinePatchRect = %Resume
@onready var settings: NinePatchRect = %Settings
@onready var restart: NinePatchRect = %Restart
@onready var exit: NinePatchRect = %Exit

@export var main: Main # Set in editor

var main_menu: PackedScene = load("res://scenes/MainMenu.tscn") # Don't make pre-load; weird circular dep issue
var parent_scene: Node2D # The scene that the pause menu exists in; Main or WorldMap

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	# Resume/exit buttons
	resume_button.pressed.connect(on_resume_button_pressed)
	resume_button.pressed.connect(func x(): AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_SELECT_1))
	exit_button.pressed.connect(on_exit_button_pressed)
	exit_button.pressed.connect(func x(): AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_SELECT_1))

	# Restart button
	restart_button.pressed.connect(on_restart_button_pressed)
	restart_button.pressed.connect(func x(): AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_SELECT_1))

	# Settings
	settings_button.pressed.connect(on_settings_button_pressed)
	settings_button.pressed.connect(func x(): AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_SELECT_1))
	settings_menu.back_button_pressed.connect(on_settings_menu_back_button_pressed)

	# Connect highlighting
	resume.mouse_entered.connect(highlight_ui_element.bind(resume))
	resume.mouse_entered.connect(func x(): AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_HOVER_1))
	resume.mouse_exited.connect(un_highlight_ui_element.bind(resume))
	settings.mouse_entered.connect(highlight_ui_element.bind(settings))
	settings.mouse_entered.connect(func x(): AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_HOVER_1))
	settings.mouse_exited.connect(un_highlight_ui_element.bind(settings))
	restart.mouse_entered.connect(highlight_ui_element.bind(restart))
	restart.mouse_entered.connect(func x(): AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_HOVER_1))
	restart.mouse_exited.connect(un_highlight_ui_element.bind(restart))
	exit.mouse_entered.connect(highlight_ui_element.bind(exit))
	exit.mouse_entered.connect(func x(): AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_HOVER_1))
	exit.mouse_exited.connect(un_highlight_ui_element.bind(exit))

	

func _input(_event):
	if Input.is_action_just_pressed("exit_menu"):
		if pause_menu.visible:
			get_viewport().set_input_as_handled() # prevent main from re-opening in its own _input()
			on_resume_button_pressed()
		else:
			settings_menu.hide()
			pause_menu.show()

func on_resume_button_pressed():
	parent_scene.unpause_game_with_menu()

func on_exit_button_pressed():
	parent_scene.on_unpause_menu_exit_level()

func on_restart_button_pressed():
	parent_scene.on_unpause_menu_restart_level()

func on_settings_button_pressed():
	pause_menu.hide()
	settings_menu.show()

func on_settings_menu_back_button_pressed():
	pause_menu.show()
	settings_menu.hide()

func highlight_ui_element(ui_element: Control) -> void:
	ui_element.self_modulate = Color(Constants.ui_color_select)

func un_highlight_ui_element(ui_element: Control) -> void:
	ui_element.self_modulate = Color.WHITE
