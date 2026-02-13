@tool 
extends EditorPlugin

@export_tool_button("Hello", "Callable") var preview_wave_button = preview_wave

var tower_stats_ui_scene: PackedScene = load("res://addons/tower_stats/TowerStatsUI.tscn")
var tower_stats_ui

func _enter_tree():
	# Create UI
	tower_stats_ui = tower_stats_ui_scene.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UR, tower_stats_ui)
	
func _exit_tree():
	remove_control_from_docks(tower_stats_ui)
	tower_stats_ui.queue_free()

func preview_wave():
	pass
