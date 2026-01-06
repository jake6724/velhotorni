class_name PlayerBuildUI
extends Control

@onready var tower_info_panel = %TowerInfoPanel
@onready var tower_count_label: Label = %TowerCountLabel
@onready var tower_max_label: Label = %TowerMaxLabel

@onready var heal_margin_container: MarginContainer = %HealMarginContainer
@onready var heal_icon: TextureRect = %HealIcon
@onready var upgrade_margin_container: MarginContainer = %UpgradeMarginContainer
@onready var upgrade_icon: TextureRect = %UpgradeIcon
@onready var sell_margin_container: MarginContainer = %SellMarginContainer
@onready var sell_icon: TextureRect = %SellIcon
@onready var tower_action_button_hint_icon: TextureRect = %ButtonHintIcon

var tower_action_icons: Array[TextureRect] = []

var tower_index: int = 0:
	set(value):
		lower_button(tower_buttons[tower_index])
		tower_index = value
		raise_button(tower_buttons[tower_index])

var tower_buttons: Array[TowerButton] = []
var tower_button_price_labels: Array[Label] = []

const BASE_POSITION: Vector2 = Vector2(0,-3)
const RAISE_POSITION: Vector2 = Vector2(0, -8)
const RAISE_DURATION: float = .1

func _ready():
	tower_buttons = [%TowerButton1, %TowerButton2, %TowerButton3, $%TowerButton4, %TowerButton5, %TowerButton6]
	tower_button_price_labels = [%TowerPriceLabel1, %TowerPriceLabel2, %TowerPriceLabel3, %TowerPriceLabel4, %TowerPriceLabel5, %TowerPriceLabel6]
	raise_button(tower_buttons[tower_index])

	tower_action_icons = [heal_icon, upgrade_icon, sell_icon]
	tower_action_button_hint_icon.z_index = Constants.z_index_map["tower_menu"]

	TowerGlobalData.tower_prices_updated.connect(set_tower_button_prices)

## Set the element for each tower button, and prices. This DOES NOT update the actual icon of the button; that is 
## done in update(), which requires PlayerMana information. Ensure that update() is called from a parent script with
## PlayerMana included to update icons
func configure_loadout(tower_element_options: Array[Constants.Element]) -> void:
	populate_tower_button_data(tower_element_options)
	set_tower_button_prices(tower_element_options)

func populate_tower_button_data(tower_element_options: Array[Constants.Element]) -> void:
	# Clean-slate, hide all tower buttons
	for tower_button: TowerButton in tower_buttons:
		tower_button.hide()
	# Show tower buttons starting from left-to-right and assigning elements
	for i in range(tower_element_options.size()):
		tower_buttons[i].element = tower_element_options[i]
		tower_buttons[i].show()

# This is seperate from populate_tower_button_data() so that it can be called seperately when prices update,
# such as a perk that reduces fire tower cost
func set_tower_button_prices(tower_element_options: Array[Constants.Element]) -> void:
	for i in range(tower_element_options.size()):
		tower_button_price_labels[i].text = str(TowerGlobalData.tower_prices[tower_element_options[i]])

func update(player_mana: PlayerMana) -> void:
	update_tower_button_icons(player_mana)

func raise_button(_button) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(_button, "position", RAISE_POSITION, RAISE_DURATION)

func lower_button(_button) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(_button, "position", BASE_POSITION, RAISE_DURATION)

func raise_current() -> void:
	raise_button(tower_buttons[tower_index])

func update_tower_info_panel(tower: Tower) -> void:
	tower_info_panel.update_stats(tower)

func update_tower_button_icons(player_mana: PlayerMana) -> void:
	for button: TowerButton in tower_buttons:
		if player_mana.tower_mana >= TowerGlobalData.tower_prices[button.element]:
			button.texture_normal = TowerGlobalData.ui_tower_sprites[button.element]
		else:
			button.texture_normal = TowerGlobalData.locked_ui_tower_sprites[button.element]

## Update tower_count_label with the provided value. 
func update_tower_count_label(_value: int) -> void:
	tower_count_label.text = str(_value)

func update_tower_max_label(_value: int) -> void:
	tower_max_label.text = str(_value)

func animate_switch_tower_action() -> void:
	# Move top to back
	var heal_tween: Tween = get_tree().create_tween()
	heal_tween.tween_property(tower_action_icons[0], "global_position", Vector2(2, 65), .15)
	await heal_tween.finished
	tower_action_icons[0].z_index = -10
	var heal_tween_2: Tween = get_tree().create_tween()
	heal_tween_2.tween_property(tower_action_icons[0], "global_position", Vector2(6,74), .1)

	# Move middle to front
	var upgrade_tween: Tween = get_tree().create_tween()
	upgrade_tween.tween_property(tower_action_icons[1], "global_position", Vector2(2, 70), .1)
	tower_action_icons[1].z_index = 20

	await get_tree().create_timer(.1).timeout
	
	# Move back to middle
	var sell_tween: Tween = get_tree().create_tween()
	sell_tween.tween_property(tower_action_icons[2], "global_position", Vector2(4, 72), .1)
	tower_action_icons[2].z_index = 10

	tower_action_icons.append(tower_action_icons[0])
	tower_action_icons.remove_at(0)

func position_tower_action_icons() -> void:
	tower_action_icons[0].position += Vector2(-2,-2)
	tower_action_icons[1].position += Vector2(0,0)
	tower_action_icons[2].position += Vector2(2,2)
