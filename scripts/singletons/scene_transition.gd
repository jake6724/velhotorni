#*** NOTE ***
# This script IS NOT a singleton, SceneTransition.tscn is!
extends CanvasLayer

@onready var block_mouse: Control = %BlockMouse

signal scene_transition_complete

func change_scene(target: PackedScene) -> void:
	block_mouse.show()
	$AnimationPlayer.play('dissolve')
	await $AnimationPlayer.animation_finished
	get_tree().current_scene.queue_free()
	get_tree().change_scene_to_packed(target)
	$AnimationPlayer.play_backwards('dissolve')
	await $AnimationPlayer.animation_finished
	block_mouse.hide()
	scene_transition_complete.emit()
