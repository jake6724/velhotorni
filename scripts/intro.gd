extends Node2D
var main_menu: PackedScene = preload("res://scenes/MainMenu.tscn")
func _ready() -> void:
	$VideoStreamPlayer.finished.connect(on_intro_finished)
func on_intro_finished() -> void:
	get_tree().changed_scene_to_packed(main_menu)
