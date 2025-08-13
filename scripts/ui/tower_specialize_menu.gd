class_name TowerSpecializeMenu
extends Control

@onready var option_1: NinePatchRect = %Option1
@onready var option_2: NinePatchRect = %Option2
@onready var option_1_label: Label = %Option1Label
@onready var option_2_label: Label = %Option2Label
@onready var option_1_desc: RichTextLabel = %Option1Desc
@onready var option_2_desc: RichTextLabel = %Option2Desc
@onready var option_1_image: TextureRect = %Option1Image
@onready var option_2_image: TextureRect = %Option2Image
@onready var option_1_button: Button = %Option1Button
@onready var option_2_button: Button = %Option2Button
@onready var back_button: TextureButton = %BackButton
@onready var close_button: Button = %CloseButton

signal option_1_selected
signal option_2_selected

var option_1_data: TowerData
var option_2_data: TowerData 
var ui_text: TowerEvolveMenuUIText = TowerEvolveMenuUIText.new()

func update_stats(_tower: Tower) -> void:
	option_1_data = Constants.tower_data[Constants.get_evolve_element_1(_tower.data.element)]
	option_2_data = Constants.tower_data[Constants.get_evolve_element_2(_tower.data.element)]

	print("Constants.get_evolve_element_1(_tower.data.element): ", Constants.get_evolve_element_1(_tower.data.element))

	option_1_label.text = option_1_data.tower_name
	option_2_label.text = option_2_data.tower_name

	print("option_1_data.element ", option_1_data.element)
	print("option_2_data.element ", option_2_data.element)

	option_1_desc.text = ui_text.evolve_desc_options[option_1_data.element]
	option_2_desc.text = ui_text.evolve_desc_options[option_2_data.element]

	option_1_image.texture.atlas = option_1_data.atlas
	option_2_image.texture.atlas = option_2_data.atlas

	if option_1_button.is_connected("pressed", on_option_1_select_pressed): option_1_button.disconnect("pressed",on_option_1_select_pressed) 
	if option_2_button.is_connected("pressed", on_option_2_select_pressed): option_2_button.disconnect("pressed",on_option_2_select_pressed) 
	option_1_button.pressed.connect(on_option_1_select_pressed.bind(option_1_data.element))
	option_2_button.pressed.connect(on_option_2_select_pressed.bind(option_2_data.element))

func on_option_1_select_pressed(_element: Constants.Element) -> void:
	print("Pressed")
	option_1_selected.emit(_element)

func on_option_2_select_pressed(_element: Constants.Element) -> void:
	print("Pressed")
	option_2_selected.emit(_element)
