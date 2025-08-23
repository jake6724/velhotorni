#*** NOTE ***
# This script IS NOT a singleton, SceneTransition.tscn is!
extends CanvasLayer

signal scene_transition_complete

func change_scene(target: PackedScene) -> void:
	$AnimationPlayer.play('dissolve')
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_packed(target)
	$AnimationPlayer.play_backwards('dissolve')
	scene_transition_complete.emit() # no one observing yet