class_name PromptArea
extends Area2D

@onready var collider: CollisionShape2D
@onready var button_hint: ButtonHint = $ButtonHint
@export var ui_element: Control
var player_in_range: bool = false

func _ready():
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)
	button_hint.hide()

func _input(event):
	if event.is_action("ui_interact") and event.is_pressed() and not event.is_echo():
		if player_in_range:
			show_ui()

func on_body_entered(player: PlayerCharacter) -> void:
	player_in_range = true
	button_hint.show()

func on_body_exited(player: PlayerCharacter) -> void:
	player_in_range = false
	button_hint.hide()

func show_ui() -> void:
	ui_element.show()