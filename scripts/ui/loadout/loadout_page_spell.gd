class_name LoadoutPageSpell
extends LoadoutPage

var equip_spell_card_1: SpellCard 
var equip_spell_card_2: SpellCard 
var equip_spell_card_3: SpellCard 
var equip_spell_card_4: SpellCard 
var equip_spell_cards: Array[SpellCard] = []
var chest_spell_cards: Array[SpellCard] = []

@onready var equip_spell_cards_parent: HBoxContainer = %EquipSpellCardsParent
@onready var spell_name: Label = %SpellName
@onready var spell_element: Label = %SpellElement
@onready var spell_desc: Label = %SpellDesc
@onready var spell_damage_value: Label = %SpellDamageValue
@onready var spell_capacity_value: Label = %SpellCapacityValue
@onready var spell_fire_rate_value: Label = %SpellFireRateValue
@onready var chest_spell_cards_parent: GridContainer = %ChestSpellCards

var spell_card_scene: PackedScene = preload("res://scenes/ui/loadout/SpellCard.tscn")
var selected_equip_spell_card: SpellCard = null

func _ready():
	populate_equip_cards()
	populate_chest_cards()
	update_all_chest_disabled()
	StarRegistry.player_star_count_updated.connect(on_player_star_count_updated)

func populate_equip_cards() -> void:
	for i in range(PlayerLoadout.equipped_spells.size()):
		var new_spell_card: SpellCard = spell_card_scene.instantiate()
		equip_spell_cards_parent.add_child(new_spell_card)
		new_spell_card.populate(PlayerLoadout.equipped_spells[i])
		new_spell_card.primary_press.connect(on_card_pressed.bind(new_spell_card))
		new_spell_card.primary_press.connect(on_equip_card_pressed.bind(new_spell_card))
		new_spell_card.secondary_press.connect(on_equip_card_secondary_press.bind(new_spell_card))

	for child in equip_spell_cards_parent.get_children():
		if child is SpellCard:
			equip_spell_cards.append(child)

	equip_spell_card_1 = equip_spell_cards[0]
	equip_spell_card_2 = equip_spell_cards[1]
	equip_spell_card_3 = equip_spell_cards[2]
	equip_spell_card_4 = equip_spell_cards[3]
	start_card = equip_spell_cards[0]

func populate_chest_cards() -> void:
	# Get the data that already exists; don't re-add it
	var existing_data: Array[SpellData] = []
	for child in chest_spell_cards_parent.get_children():
		var spell_card: SpellCard = child as SpellCard
		if spell_card:
			var spell_card_data: SpellData = spell_card.data
			existing_data.append(spell_card_data)

	for spell_data: SpellData in PlayerLoadout.spells.keys():
		if PlayerLoadout.spells[spell_data]:
			if spell_data not in existing_data: # Do not add spell cards more than once per tower data
				var new_spell_card: SpellCard = spell_card_scene.instantiate()
				chest_spell_cards_parent.add_child(new_spell_card)
				new_spell_card.populate(spell_data)
				new_spell_card.primary_press.connect(on_card_pressed.bind(new_spell_card))
				new_spell_card.primary_press.connect(on_chest_card_pressed.bind(new_spell_card))

	for child in chest_spell_cards_parent.get_children():
		if child is SpellCard:
			chest_spell_cards.append(child)

func on_equip_card_pressed(spell_card: SpellCard) -> void:
	selected_equip_spell_card = spell_card

func on_equip_card_secondary_press(spell_card: SpellCard) -> void:
	spell_card.populate(null)
	update_player_loadout()
	update_all_chest_disabled()

func on_chest_card_pressed(chest_spell_card: SpellCard) -> void:
	if selected_equip_spell_card and not chest_spell_card.chest_disabled:
		chest_spell_card.chest_disabled = true
		selected_equip_spell_card.populate(chest_spell_card.data)
		update_player_loadout()
		update_all_chest_disabled()
		
		selected_equip_spell_card = null # This may be desirable or not idk yet

## Called for all cards; displays info about card in the spell_card info panel
func on_card_pressed(spell_card: SpellCard) -> void:
	# Only show card info if data to show
	if spell_card.data:
		spell_name.text = spell_card.data.spell_name
		spell_element.text = Constants.get_element_text(spell_card.data.element)
		spell_desc.text = spell_card.data.desc
		spell_damage_value.text = str(int(spell_card.data.damage))
		spell_capacity_value.text = str(int(spell_card.data.max_mana_amount))
		spell_fire_rate_value.text = str(snappedf((1 / spell_card.data.cooldown), .01))

func update_all_chest_disabled() -> void:
	for chest_spell_card: SpellCard in chest_spell_cards:
		chest_spell_card.chest_disabled = false
	
	for equip_spell_card: SpellCard in equip_spell_cards:
		for chest_spell_card: SpellCard in chest_spell_cards:
			if equip_spell_card.data == chest_spell_card.data:
				chest_spell_card.chest_disabled = true

func update_player_loadout() -> void:
	PlayerLoadout.equipped_spell_1 = equip_spell_card_1.data
	PlayerLoadout.equipped_spell_2 = equip_spell_card_2.data
	PlayerLoadout.equipped_spell_3 = equip_spell_card_3.data
	PlayerLoadout.equipped_spell_4 = equip_spell_card_4.data
	PlayerLoadout.trigger_spell_loadout_update()
	populate_chest_cards()
	update_all_chest_disabled()

func on_player_star_count_updated() -> void:
	populate_chest_cards()
	update_all_chest_disabled()
