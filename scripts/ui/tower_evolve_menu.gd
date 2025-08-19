class_name TowerEvolveMenu
extends Control

# TODO: use a setter for hide/slow to disable animations

@onready var option_1: NinePatchRect = %Option1
@onready var option_2: NinePatchRect = %Option2
@onready var option_1_label: Label = %Option1Label
@onready var option_2_label: Label = %Option2Label
@onready var option_1_desc: RichTextLabel = %Option1Desc
@onready var option_2_desc: RichTextLabel = %Option2Desc
@onready var option_1_select_label: Label = %Option1SelectLabel
@onready var option_2_select_label: Label = %Option2SelectLabel
@onready var option_1_lock_icon: TextureRect = %Option1LockIcon
@onready var option_2_lock_icon: TextureRect = %Option2LockIcon
@onready var option_1_image: TextureRect = %Option1Image
@onready var option_2_image: TextureRect = %Option2Image
@onready var option_1_button: Button = %Option1Button
@onready var option_2_button: Button = %Option2Button
@onready var back_button: TextureButton = %BackButton
@onready var close_button: Button = %CloseButton
@onready var info: Label = %Info

signal option_1_selected
signal option_2_selected
signal close_button_pressed
signal back_button_pressed

var ui_text: TowerEvolveMenuUIText = TowerEvolveMenuUIText.new()

var animation_timer: Timer = Timer.new()
var animation_time: float = .25
var animation_anim_x_increment: float = 16.0
var animation_anim_x_max: float = 48.0
var anim_x: float = 0.0
var anim_w: float = 16.0
var anim_y: float = 0.0
var anim_h: float = 0.0

func _ready():
	close_button.pressed.connect(on_close_button_pressed)
	back_button.pressed.connect(on_back_button_pressed)
	add_child(animation_timer)
	animation_timer.timeout.connect(on_animation_timer_timeout)
	animation_timer.start()

func update_stats(_tower: Tower) -> void:
	var option_1_data: TowerData = Constants.tower_data[Constants.get_evolve_element_1(_tower.data.element)]
	var option_2_data: TowerData = Constants.tower_data[Constants.get_evolve_element_2(_tower.data.element)]

	option_1_label.text = option_1_data.tower_name
	option_2_label.text = option_2_data.tower_name

	option_1_desc.text = ui_text.evolve_desc_options[option_1_data.element]
	option_2_desc.text = ui_text.evolve_desc_options[option_2_data.element]

	option_1_image.texture.atlas = option_1_data.atlas
	option_2_image.texture.atlas = option_2_data.atlas

	if option_1_button.is_connected("pressed", on_option_1_select_pressed): option_1_button.disconnect("pressed",on_option_1_select_pressed) 
	if option_2_button.is_connected("pressed", on_option_2_select_pressed): option_2_button.disconnect("pressed",on_option_2_select_pressed) 
	option_1_button.pressed.connect(on_option_1_select_pressed.bind(option_1_data.element))
	option_2_button.pressed.connect(on_option_2_select_pressed.bind(option_2_data.element))

	set_level_stats(_tower, option_1_data, option_2_data)

func set_level_stats(_tower: Tower, _option_1_data: TowerData, _option_2_data: TowerData) -> void:
	option_1_select_label.hide()
	option_2_select_label.hide()
	option_1_button.disabled = true
	option_2_button.disabled = true
	option_1_lock_icon.show()
	option_2_lock_icon.show()
	info.text = ui_text.info_locked

	if TowerGlobalData.tower_evolution_status[_option_1_data.element]:
		option_1.show()
	else:
		option_1.hide()

	if TowerGlobalData.tower_evolution_status[_option_2_data.element]:
		option_2.show()
	else:
		option_2.hide()
		
	if _tower.level > 2:
			option_1_select_label.show()
			option_1_lock_icon.hide()
			option_1_button.disabled = false

			option_2_select_label.show()
			option_2_lock_icon.hide()
			option_2_button.disabled = false

			info.text = ui_text.info_unlocked

func on_option_1_select_pressed(_element: Constants.Element) -> void:
	option_1_selected.emit(_element)

func on_option_2_select_pressed(_element: Constants.Element) -> void:
	option_2_selected.emit(_element)

func on_close_button_pressed() -> void:
	close_button_pressed.emit()

func on_back_button_pressed() -> void:
	back_button_pressed.emit()

func on_animation_timer_timeout() -> void:
	animate_atlas_textures()
	animation_timer.start(animation_time)

func animate_atlas_textures() -> void:
	anim_x += animation_anim_x_increment
	if anim_x > animation_anim_x_max:
		anim_x = 0
	if option_1_image.texture and option_2_image.texture:
		option_1_image.texture.region = Rect2(anim_x, anim_y, anim_w, anim_h)
		option_2_image.texture.region = Rect2(anim_x, anim_y, anim_w, anim_h)
