class_name SpellCard
extends LoadoutCard

@onready var spell_icon: TextureRect = %SpellIcon
@onready var button_hint: ButtonHint = %ButtonHint

var greyscale_shader = preload("res://shader/greyscale.gdshader")
var greyscale_shader_material = ShaderMaterial.new()

signal primary_press
signal secondary_press

var data: SpellData
var chest_disabled: bool = false:
	set(value):
		chest_disabled = value
		if chest_disabled:
			spell_icon.material = greyscale_shader_material
		else:
			spell_icon.material = null

func _ready():
	greyscale_shader_material.shader = greyscale_shader

## Must be called AFTER SpellCard is added to scene
func populate(_data: SpellData) -> void:
	data = _data
	if _data:
		spell_icon.texture = _data.active_icon
		spell_icon.show()
		button_hint.hide()
	else:
		button_hint.show()
		spell_icon.hide()

func disable() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func enable() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and not event.is_echo():
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				primary_press.emit()
			MOUSE_BUTTON_RIGHT:
				secondary_press.emit()
