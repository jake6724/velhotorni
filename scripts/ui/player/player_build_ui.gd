class_name PlayerBuildUI
extends Control

@onready var tower_info_panel = %TowerInfoPanel

var tower_index: int = 0:
	set(value):
		lower_button(tower_buttons[tower_index])
		tower_index = value
		raise_button(tower_buttons[tower_index])

var tower_buttons: Array[TowerButton] = []
var tower_button_price_labels: Array[Label] = []

var ui_tower_sprites: Dictionary[Constants.Element, Texture] = {
 	Constants.Element.FIRE: preload("res://assets/art/sprites/ui/spr_ui_tower_fire.png"),
	Constants.Element.WIND: preload("res://assets/art/sprites/ui/spr_ui_tower_wind_bird.png"),
	Constants.Element.WATER: preload("res://assets/art/sprites/ui/spr_ui_tower_water_fish.png"),
	Constants.Element.EARTH: preload("res://assets/art/sprites/ui/spr_ui_tower_earth.png"),
	Constants.Element.LIGHT: preload("res://assets/art/sprites/ui/spr_ui_tower_light.png"),
	Constants.Element.DARK: preload("res://assets/art/sprites/ui/spr_ui_tower_dark.png"),
}

var locked_ui_tower_sprites: Dictionary[Constants.Element, Texture] = {
	Constants.Element.FIRE: preload("res://assets/art/sprites/ui/spr_ui_tower_fire_locked.png"),
	Constants.Element.WIND: preload("res://assets/art/sprites/ui/spr_ui_tower_wind_bird_locked.png"),
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
