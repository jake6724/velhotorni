class_name SpellCard
extends LoadoutCard

# @onready var content: HBoxContainer = %Content
@onready var spell_icon: TextureRect = %SpellIcon
# @onready var spell_name: Label = %SpellName
# @onready var damage_value: Label = %DamageValue
# @onready var mana_value: Label = %ManaValue

# @onready var action_prompt = %ActionPrompt

## Must be called AFTER SpellCard is added to scene
func populate(_data: SpellData) -> void:
	if _data:
		# content.show()
		# action_prompt.hide()

		spell_icon.texture = _data.active_icon
		# spell_name.text = _data.spell_name
		# damage_value.text = str(int(_data.damage))
		# mana_value.text = str(_data.max_mana_amount)

	# else:
		# content.hide()
		# action_prompt.show()

func disable() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func enable() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
