extends Node2D
var main_menu: PackedScene = preload("res://scenes/MainMenu.tscn")

func _ready() -> void:

	$VideoStreamPlayer.finished.connect(on_intro_finished)

func on_intro_finished() -> void:
	get_tree().change_scene_to_packed(main_menu)

func _input(_event):
	# Spacebar to skip
	if Input.is_action_just_pressed("spacebar"):
		get_tree().change_scene_to_packed(main_menu)
