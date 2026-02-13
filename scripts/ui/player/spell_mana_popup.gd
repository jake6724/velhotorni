class_name SpellManaPopup
extends Control

@onready var spell_icon: TextureRect = %SpellIcon
@onready var mana_amount_label: Label = %ManaAmountLabel
@onready var plus_icon: TextureRect = %PlusIcon

var spell_data: SpellData
var total: int = 0

const full_text: String = " FULL"

func set_icon(_spell_icon: AtlasTexture) -> void:
	spell_icon.texture = _spell_icon
	
func set_text(_mana_amount: int) -> void:
	total += _mana_amount
	if total <= 0:
		plus_icon.hide()
		mana_amount_label.text = full_text
	else:
		mana_amount_label.text = str(total)

func shake() -> void:
	var rotation_tween: Tween = get_tree().create_tween()
	rotation_tween.set_loops(3)
	rotation_tween.tween_property(self, "rotation_degrees", 4, .02)
	rotation_tween.tween_interval(.05)
	rotation_tween.tween_property(self, "rotation_degrees", 0, .02)
	rotation_tween.tween_interval(.05)