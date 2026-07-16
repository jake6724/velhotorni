class_name MainMenuNew
extends Panel

@export_group("Node References")
@export var tutorial_button: Button
@export var play_button: Button
@export var options_button: Button
@export var credits_button: Button
@export var exit_button: Button
@export var buttons: Array[Button]

var tutorial: PackedScene = load("res://scenes/level/0_tutorial/LevelTutorial.tscn")

func _ready():
	for button: Button in buttons:
		button.pivot_offset = button.size/2
		button.mouse_entered.connect(shake_ui_node.bind(button))

	# tutorial_button.pressed.connect(on_tutorial_button_pressed)

# func on_tutorial_button_pressed() -> void:
# 	LevelManager.load_specific_level_by_level_tag(LevelManager.LevelTag.TUTORIAL)

func shake_ui_node(node: Control) -> void:
	var shake_tween: Tween = get_tree().create_tween()
	var shake_range: float = 2
	var shake_duration: float = .03
	shake_tween.tween_property(node, "rotation_degrees", shake_range, shake_duration)
	shake_tween.tween_interval(shake_duration)
	shake_tween.tween_property(node, "rotation_degrees", -shake_range, shake_duration)
	shake_tween.tween_interval(shake_duration)
	shake_tween.tween_property(node, "rotation_degrees", 0, shake_duration)
	shake_tween.tween_interval(shake_duration)

	# var scale_target: Vector2 = Vector2(1.3, 1.3)
	# var scale_tween: Tween = get_tree().create_tween()
	# scale_tween.tween_property(node, "scale", scale_target, .03)
	# scale_tween.tween_interval(shake_duration)
	# scale_tween.tween_property(node, "scale", Vector2.ONE, .03)
