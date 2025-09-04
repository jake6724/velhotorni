class_name CreditsMenu
extends NinePatchRect

@onready var back: NinePatchRect = %Back
@onready var back_button: Button = %BackButton

signal back_button_pressed

func _ready():
	# Configure BackButton
	back_button.pressed.connect(on_back_button_pressed)

	# Configure Highlighting
	back.mouse_entered.connect(highlight_ui_element.bind(back))
	back.mouse_exited.connect(un_highlight_ui_element.bind(back))

func on_back_button_pressed() -> void:
	back_button_pressed.emit()

func highlight_ui_element(ui_element: Control) -> void:
	ui_element.self_modulate = Color(Constants.ui_color_select)

func un_highlight_ui_element(ui_element: Control) -> void:
	ui_element.self_modulate = Color.WHITE