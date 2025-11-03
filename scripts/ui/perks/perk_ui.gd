class_name PerkUI
extends Control

@onready var top_letterbox: TextureRect = %TopLetterbox
@onready var bottom_letterbox: TextureRect = %BottomLetterbox
@onready var title_label: Label = %TitleLabel
@onready var instruction_label: Label = %InstructionLabel
@onready var header: Control = %Header
@onready var candles: Control = %Candles

@onready var perk_card_1: PerkCard = %PerkCard1
@onready var perk_card_2: PerkCard = %PerkCard2
@onready var perk_card_3: PerkCard = %PerkCard3
var perk_cards: Array = []

# Animation Vars
var letterbox_speed: float = .20
var bounce_speed: float = .05
var delay_between_cards: float = 0

func _input(_event):
	if Input.is_action_just_pressed("x"):
		animate()

func _ready():
	perk_cards = [perk_card_1, perk_card_2, perk_card_3]

func animate() -> void:
	top_letterbox.position = Vector2(-512, 0)
	bottom_letterbox.position = Vector2(512, 256)
	animate_letterboxes()
	bounce_element(header)

	for card: PerkCard in perk_cards:
		card.animate()
		await get_tree().create_timer(delay_between_cards).timeout

func animate_letterboxes() -> void:	
	var top_tween: Tween = get_tree().create_tween()
	top_tween.tween_property(top_letterbox, "position", Vector2(0,0), letterbox_speed)

	var bottom_tween: Tween = get_tree().create_tween()
	bottom_tween.tween_property(bottom_letterbox, "position", Vector2(0,256), letterbox_speed)

func bounce_element(ui_element: Control) -> void:
	var target: Vector2

	var bounce_up_tween: Tween = get_tree().create_tween() 
	target = ui_element.position - Vector2(0,4)
	bounce_up_tween.tween_property(ui_element, "position", target, bounce_speed)

	await bounce_up_tween.finished

	var bounce_down_tween: Tween = get_tree().create_tween()
	target = ui_element.position + Vector2(0,4)
	bounce_down_tween.tween_property(ui_element, "position", target, bounce_speed)
