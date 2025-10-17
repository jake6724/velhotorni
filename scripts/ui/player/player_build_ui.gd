class_name PlayerBuildUI
extends Control

var tower_index: int = 0:
	set(value):
		lower_button(tower_buttons[tower_index])
		tower_index = value
		raise_button(tower_buttons[tower_index])

var tower_buttons: Array[TextureButton] = []
var tower_button_price_labels: Array[Label] = []

const BASE_POSITION: Vector2 = Vector2(0,-3)
const RAISE_POSITION: Vector2 = Vector2(0, -8)
const RAISE_DURATION: float = .1

func _ready():
	tower_buttons = [%FireButton, %WindButton, %WaterButton, $%EarthButton, %LightButton, %DarkButton]
	tower_button_price_labels = [%FirePriceLabel, %WindPriceLabel, %WaterPriceLabel, %EarthPriceLabel, %LightPriceLabel, %DarkPriceLabel]
	set_tower_button_prices()
	raise_button(tower_buttons[tower_index])

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
