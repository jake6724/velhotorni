class_name SpellManaPopup
extends Control

@onready var spell_icon: TextureRect = %SpellIcon
@onready var mana_amount_label: Label = %ManaAmountLabel
@onready var plus_icon: TextureRect = %PlusIcon

const full_text: String = " FULL"

func set_icon(_spell_icon: AtlasTexture) -> void:
	spell_icon.texture = _spell_icon
	
func set_text(_mana_amount: int) -> void:
	if _mana_amount <= 0:
		plus_icon.hide()
		mana_amount_label.text = full_text
	else:
		mana_amount_label.text = str(_mana_amount)