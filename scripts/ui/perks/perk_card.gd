class_name PerkCard
extends Control

@onready var content: Control = %Content
@onready var card_background: NinePatchRect = %CardBackground
@onready var perk_icon: TextureRect = %PerkIcon

# var expand_start_value: Vector2 = Vector2(118, 144)
var expand_full_value: Vector2 = Vector2(118, 144)
var expand_time: float = .25
var bounce_speed: float = .05

signal bounce_complete

func _ready():
	card_background.size = Vector2(118, 16)

func animate() -> void:
	content.hide()
	perk_icon.texture.region = Rect2(0,1,48,46)
	card_background.size = Vector2(118, 16)
	expand()
	bounce_perk_icon()

func expand() -> void:
	var expand_full_tween: Tween = get_tree().create_tween()
	expand_full_tween.tween_property(card_background, "size", expand_full_value, expand_time)
	await expand_full_tween.finished
	content.show()
	bounce_content()

func bounce_perk_icon() -> void:
	await bounce_element(perk_icon)
	perk_icon.texture.region = Rect2(192,1,48,46)

func bounce_content() -> void:
	bounce_element(content)

func bounce_element(ui_element: Control) -> void:
	var target: Vector2

	var bounce_up_tween: Tween = get_tree().create_tween() 
	target = ui_element.position - Vector2(0,4)
	bounce_up_tween.tween_property(ui_element, "position", target, bounce_speed)

	await bounce_up_tween.finished

	var bounce_down_tween: Tween = get_tree().create_tween()
	target = ui_element.position + Vector2(0,4)
	bounce_down_tween.tween_property(ui_element, "position", target, bounce_speed)

	bounce_complete.emit()
