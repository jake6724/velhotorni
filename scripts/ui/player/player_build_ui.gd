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

var ui_tower_sprites: Dictionary[Constants.Element, Texture] = {
 	Constants.Element.FIRE: preload("res://assets/art/sprites/ui/spr_ui_tower_fire.png"),
	Constants.Element.WIND: preload("res://assets/art/sprites/ui/spr_ui_tower_wind.png"),
	Constants.Element.WATER: preload("res://assets/art/sprites/ui/spr_ui_tower_water_fish.png"),
	Constants.Element.EARTH: preload("res://assets/art/sprites/ui/spr_ui_tower_earth.png"),
	Constants.Element.LIGHT: preload("res://assets/art/sprites/ui/spr_ui_tower_light.png"),
	Constants.Element.DARK: preload("res://assets/art/sprites/ui/spr_ui_tower_dark.png"),
}

var locked_ui_tower_sprites: Dictionary[Constants.Element, Texture] = {
	Constants.Element.FIRE: preload("res://assets/art/sprites/ui/spr_ui_tower_fire_locked.png"),
	Constants.Element.WIND: preload("res://assets/art/sprites/ui/spr_ui_tower_wind_locked.png"),
	Constants.Element.WATER: preload("res://assets/art/sprites/ui/spr_ui_tower_water_fish_locked.png"),
	Constants.Element.EARTH: preload("res://assets/art/sprites/ui/spr_ui_tower_earth_locked.png"),
	Constants.Element.LIGHT: preload("res://assets/art/sprites/ui/spr_ui_tower_light_locked.png"),
	Constants.Element.DARK: preload("res://assets/art/sprites/ui/spr_ui_tower_dark_locked.png"),
}

const BASE_POSITION: Vector2 = Vector2(0,-3)
const RAISE_POSITION: Vector2 = Vector2(0, -8)
const RAISE_DURATION: float = .1

func _ready():
	tower_buttons = [%FireButton, %WindButton, %WaterButton, $%EarthButton, %LightButton, %DarkButton]
	tower_button_price_labels = [%FirePriceLabel, %WindPriceLabel, %WaterPriceLabel, %EarthPriceLabel, %LightPriceLabel, %DarkPriceLabel]
	set_tower_button_prices()
	raise_button(tower_buttons[tower_index])

	tower_action_icons = [heal_icon, upgrade_icon, sell_icon]
	tower_action_button_hint_icon.z_index = Constants.z_index_map["tower_menu"]

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

func set_tower_button_prices() -> void:
	%FirePriceLabel.text = str(TowerGlobalData.tower_prices[Constants.Element.FIRE])
	%WindPriceLabel.text = str(TowerGlobalData.tower_prices[Constants.Element.WIND])
	%WaterPriceLabel.text = str(TowerGlobalData.tower_prices[Constants.Element.WATER])
	%EarthPriceLabel.text = str(TowerGlobalData.tower_prices[Constants.Element.EARTH])
	%LightPriceLabel.text = str(TowerGlobalData.tower_prices[Constants.Element.LIGHT])
	%DarkPriceLabel.text = str(TowerGlobalData.tower_prices[Constants.Element.DARK])

func update_tower_info_panel(tower: Tower) -> void:
	tower_info_panel.update_stats(tower)

func update_tower_button_icons(player_mana: PlayerMana) -> void:
	for button: TowerButton in tower_buttons:
		if player_mana.tower_mana >= TowerGlobalData.tower_prices[button.element]:
			button.texture_normal = ui_tower_sprites[button.element]
		else:
			button.texture_normal = locked_ui_tower_sprites[button.element]

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
	print(tower_action_icons)

func position_tower_action_icons() -> void:
	tower_action_icons[0].position += Vector2(-2,-2)
	tower_action_icons[1].position += Vector2(0,0)
	tower_action_icons[2].position += Vector2(2,2)
