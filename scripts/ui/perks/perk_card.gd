class_name PerkCard
extends Control

@onready var content: Control = %Content
@onready var description: Label = %Description

@onready var card_background: NinePatchRect = %CardBackground
@onready var perk_icon: TextureRect = %PerkIcon
@onready var perk_name: Label = %PerkName

# var expand_start_value: Vector2 = Vector2(118, 144)
var expand_full_value: Vector2 = Vector2(118, 144)
var expand_time: float = .25
var collapse_time: float = .1
var bounce_speed: float = .05

var original_position: Vector2

signal bounce_complete

var perk_data: PerkData = preload("res://data/perks/player/legendary/perk_data_player_lgd_move_speed_on_dmg.tres")
var highlight_texture: CompressedTexture2D = preload("res://assets/art/sprites/ui/spr_ui_box6.png")
var unhighlight_texture: CompressedTexture2D = preload("res://assets/art/sprites/ui/spr_ui_box6_gray.png")

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	card_background.size = Vector2(118, 16)
	original_position = global_position

func animate() -> void:
	content.hide()
	perk_icon.texture.region = Rect2(0,1,48,46)
	card_background.size = Vector2(118, 16)
	expand()
	bounce_perk_icon()
	populate_card(perk_data)

func animate_reset() -> void:
	collapse()

func expand() -> void:
	var expand_full_tween: Tween = get_tree().create_tween()
	expand_full_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	expand_full_tween.tween_property(card_background, "size", expand_full_value, expand_time)
	await expand_full_tween.finished
	content.show()
	bounce_content()

func collapse() -> void:
	bounce_content()
	var expand_full_tween: Tween = get_tree().create_tween()
	expand_full_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	expand_full_tween.tween_property(card_background, "size", Vector2(118, 16), collapse_time)
	await expand_full_tween.finished
	content.hide()

func bounce_perk_icon() -> void:
	await bounce_element(perk_icon, 16)
	# perk_icon.texture.region = Rect2(192,1,48,46)

func bounce_content() -> void:
	bounce_element(content, 4)

func bounce_element(ui_element: Control, bounce_height: int) -> void:
	var target: Vector2

	var bounce_up_tween: Tween = get_tree().create_tween() 
	bounce_up_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	target = ui_element.position - Vector2(0,bounce_height)
	bounce_up_tween.tween_property(ui_element, "position", target, bounce_speed)

	await bounce_up_tween.finished

	var bounce_down_tween: Tween = get_tree().create_tween()
	bounce_down_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	target = ui_element.position + Vector2(0,bounce_height)
	bounce_down_tween.tween_property(ui_element, "position", target, bounce_speed)

	bounce_complete.emit()

func populate_card(_data: PerkData) -> void:
	perk_icon.texture = _data.perk_icon
	description.text = _data.perk_desc
	perk_name.text = _data.perk_name

func highlight() -> void:
	card_background.texture = highlight_texture

func unhighlight() -> void:
	card_background.texture = unhighlight_texture

func pop_up() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var target: Vector2 = original_position + Vector2(0,-6)
	tween.tween_property(self, "position", target, .15)

func unpop_up() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "global_position", original_position, .15)