class_name PromptArea
extends Area2D

@onready var collider: CollisionShape2D
@onready var button_hint: ButtonHint = $ButtonHint
@export var ui_element: Control
var player_in_range: bool = false

var player: PlayerCharacter

func _ready():
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)
	button_hint.hide()

func _input(event):
	if player_in_range and player:
		if event.is_action("ui_interact") and event.is_pressed() and not event.is_echo():
			show_ui()
		
		if event.is_action("escape") and event.is_pressed() and not event.is_echo():
			hide_ui()

func on_body_entered(_player: PlayerCharacter) -> void:
	player_in_range = true
	button_hint.show()
	player = _player

func on_body_exited(_player: PlayerCharacter) -> void:
	player_in_range = false
	button_hint.hide()
	hide_ui()

func show_ui() -> void:
	player.player_input.input_enabled = false
	player.player_hud.hide()
	player.player_camera.set_process(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	ui_element.show()

func hide_ui() -> void:
	ui_element.hide()
	player.player_camera.set_process(true)
	player.player_hud.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	player.player_input.set_deferred("input_enabled",true)
