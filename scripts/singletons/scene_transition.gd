#*** NOTE ***
# This script IS NOT a singleton, SceneTransition.tscn is!
extends CanvasLayer

@onready var block_mouse: Control = %BlockMouse

signal scene_transition_complete

func change_scene(target: PackedScene) -> void:
	block_mouse.show()
	$AnimationPlayer.play('dissolve')
	await $AnimationPlayer.animation_finished

	if get_tree().current_scene:
		get_tree().current_scene.queue_free()

	get_tree().change_scene_to_packed(target)
	$AnimationPlayer.play_backwards('dissolve')
	await $AnimationPlayer.animation_finished
	block_mouse.hide()
	scene_transition_complete.emit()

func change_scene_no_animation(target: PackedScene) -> void:
	if get_tree().current_scene:
		get_tree().current_scene.queue_free()
	get_tree().change_scene_to_packed(target)
	scene_transition_complete.emit()

func teleport_player(player: PlayerCharacter, target_global_position: Vector2) -> void:
	$AnimationPlayer.play('dissolve')
	await $AnimationPlayer.animation_finished
	player.player_camera.position_smoothing_enabled = false
	player.global_position = target_global_position
	player.player_camera.position_smoothing_enabled = false
	$AnimationPlayer.play_backwards('dissolve')
	await $AnimationPlayer.animation_finished

# func reload_active_scene() -> void:
# 	if get_tree().current_scene:
# 		get_tree().current_scene.queue_free()
# 	get_tree().change_scene_to_packed(active_scene)
# 	scene_transition_complete.emit()