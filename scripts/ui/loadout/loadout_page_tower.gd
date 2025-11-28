class_name LoadoutPageTower
extends LoadoutPage

var tower_card_scene: PackedScene = preload("res://scenes/ui/loadout/TowerCard.tscn")

@onready var equip_tower_cards_parent: HBoxContainer = %EquipTowerCardsParent
@onready var chest_tower_cards_parent: GridContainer = %ChestTowerCardsParent

@onready var tower_name: Label = %TowerName
@onready var tower_element: Label = %TowerElement
@onready var tower_desc: Label = %TowerDesc
@onready var tower_damage_value: Label = %TowerDamageValue
@onready var tower_range_value: Label = %TowerRangeValue
@onready var tower_fire_rate_value: Label = %TowerFireRateValue

var equip_tower_card_1: TowerCard
var equip_tower_card_2: TowerCard
var equip_tower_card_3: TowerCard
var equip_tower_card_4: TowerCard
var equip_tower_card_5: TowerCard
var equip_tower_card_6: TowerCard

var equip_tower_cards: Array[TowerCard] = []
var chest_tower_cards: Array[TowerCard] = []

var selected_equip_tower_card: TowerCard = null

func _ready():
	populate_equip_cards()
	populate_chest_cards()

	for child in equip_tower_cards_parent.get_children():
		if child is TowerCard:
			equip_tower_cards.append(child)

	equip_tower_card_1 = equip_tower_cards[0]
	equip_tower_card_2 = equip_tower_cards[1]
	equip_tower_card_3 = equip_tower_cards[2]
	equip_tower_card_4 = equip_tower_cards[3]
	equip_tower_card_5 = equip_tower_cards[4]
	equip_tower_card_6 = equip_tower_cards[5]
	
	for child in chest_tower_cards_parent.get_children():
		if child is TowerCard:
			chest_tower_cards.append(child)

	update_all_chest_disabled()

func populate_equip_cards() -> void:
	for i in range(PlayerLoadout.equipped_towers.size()):
		var new_tower_card: TowerCard = tower_card_scene.instantiate()
		equip_tower_cards_parent.add_child(new_tower_card)
		new_tower_card.populate(PlayerLoadout.equipped_towers[i])
		new_tower_card.primary_press.connect(on_card_pressed.bind(new_tower_card))
		new_tower_card.primary_press.connect(on_equip_card_pressed.bind(new_tower_card))
		new_tower_card.secondary_press.connect(on_equip_card_secondary_press.bind(new_tower_card))

func populate_chest_cards() -> void:
	for tower_data: TowerData in PlayerLoadout.towers.keys():
		if PlayerLoadout.towers[tower_data]:
			var new_tower_card: TowerCard = tower_card_scene.instantiate()
			chest_tower_cards_parent.add_child(new_tower_card)
			new_tower_card.populate(tower_data)
			new_tower_card.primary_press.connect(on_card_pressed.bind(new_tower_card))
			new_tower_card.primary_press.connect(on_chest_card_pressed.bind(new_tower_card))

## Called for all cards; displays info about card in the tower_card info panel
func on_card_pressed(tower_card: TowerCard) -> void:
	# Only show card info if data to show
	if tower_card.data:
		tower_name.text = tower_card.data.tower_name
		tower_element.text = Constants.get_element_text(tower_card.data.element)
		tower_desc.text = tower_card.data.desc
		tower_damage_value.text = str(int(tower_card.data.damage))
		tower_range_value.text = str(int(tower_card.data.attack_range))
		tower_fire_rate_value.text = str(snappedf((1 / tower_card.data.speed), .01))

func on_equip_card_pressed(tower_card: TowerCard) -> void:
	selected_equip_tower_card = tower_card

func on_equip_card_secondary_press(tower_card: TowerCard) -> void:
	tower_card.populate(null)
	update_player_loadout()
	update_all_chest_disabled()

func on_chest_card_pressed(chest_tower_card: TowerCard) -> void:
	if selected_equip_tower_card and not chest_tower_card.chest_disabled:
		chest_tower_card.chest_disabled = true
		selected_equip_tower_card.populate(chest_tower_card.data)
		update_player_loadout()
		update_all_chest_disabled()
		selected_equip_tower_card = null # This may be desirable or not idk yet

func update_all_chest_disabled() -> void:
	for chest_tower_card: TowerCard in chest_tower_cards:
		chest_tower_card.chest_disabled = false
	
	for equip_tower_card: TowerCard in equip_tower_cards:
		for chest_tower_card: TowerCard in chest_tower_cards:
			if equip_tower_card.data == chest_tower_card.data:
				chest_tower_card.chest_disabled = true

func update_player_loadout() -> void:
	PlayerLoadout.equipped_tower_1 = equip_tower_card_1.data
	PlayerLoadout.equipped_tower_2 = equip_tower_card_2.data
	PlayerLoadout.equipped_tower_3 = equip_tower_card_3.data
	PlayerLoadout.equipped_tower_4 = equip_tower_card_4.data
	PlayerLoadout.equipped_tower_5 = equip_tower_card_5.data
	PlayerLoadout.equipped_tower_6 = equip_tower_card_6.data
