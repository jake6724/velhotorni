class_name LoadoutPageSpell
extends LoadoutPage

# @onready var equip_spellcard_1: SpellCard = %EquipSpellCard1
# @onready var equip_spellcard_2: SpellCard = %EquipSpellCard2
# @onready var equip_spellcard_3: SpellCard = %EquipSpellCard3
# @onready var equip_spellcard_4: SpellCard = %EquipSpellCard4
# @onready var equip_spellcards: Array[SpellCard] = [equip_spellcard_1, equip_spellcard_2, equip_spellcard_3, equip_spellcard_4]

@onready var chest_spell_cards_parent: GridContainer = %ChestSpellCards

var spell_card_scene: PackedScene = preload("res://scenes/ui/loadout/SpellCard.tscn")

func _ready():
	# start_card = equip_spellcard_1
	populate_chest_cards()

	# for spell_card: SpellCard in equip_spellcards:
	# 	spell_card.pressed.connect(on_equip_card_pressed)

func populate_chest_cards() -> void:
	for i in range(PlayerLoadout.unlocked_spells.size()):
		var new_spell_card: SpellCard = spell_card_scene.instantiate()
		chest_spell_cards_parent.add_child(new_spell_card)
		new_spell_card.populate(PlayerLoadout.unlocked_spells[i])

func on_equip_card_pressed() -> void:
	pass
