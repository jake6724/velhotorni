@tool 
extends EditorPlugin

@export_tool_button("Hello", "Callable") var preview_wave_button = preview_wave

var button: Button

func _enter_tree():
	button = Button.new()
	button.text = "Preview Wave"
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BR, button)
	
func _exit_tree():
	remove_control_from_docks(button)
	button.queue_free()

func preview_wave():
	pass