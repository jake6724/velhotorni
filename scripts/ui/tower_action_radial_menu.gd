class_name TowerActionRadialMenu
extends Control

@onready var heal_icon: TextureRect = %HealIcon
@onready var upgrade_icon: TextureRect = %UpgradeIcon
@onready var sell_icon: TextureRect = %SellIcon
@onready var info_icon: TextureRect = %InfoIcon

@onready var cursor: Control = %Cursor

const OPEN_CLOSE_SPEED: float = .1
const OPEN_OFFSET: float = 24.0
const CLOSE_RESET_POSITION: Vector2 = Vector2(-8,-8)

var active: bool = false

var player: PlayerCharacter

var active_icon: TextureRect

# @onready var info_icon: TextureRect = %InfoIcon

func _input(event):
	if Input.is_action_pressed("x"):
		if not active:
			animate_open()
	if Input.is_action_just_released("x"):
		animate_close()

func _ready():
	heal_icon.hide()
	upgrade_icon.hide()
	sell_icon.hide()
	info_icon.hide()

func _process(_delta: float) -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	var angle: float = (mouse_position.angle_to_point(global_position))
	angle = fposmod(angle, TAU)
	angle = rad_to_deg(angle)
	var selected_icon: TextureRect
	# Heal
	if angle > 45 and angle <= 135:
		selected_icon = heal_icon

	# Upgrade
	elif angle > 135 and angle <= 225: 
		selected_icon = upgrade_icon

	# Info
	elif angle > 225 and angle <= 315: 
		selected_icon = info_icon
	
	# Sell
	elif angle < 45 or angle < 315:
		selected_icon = sell_icon

	# Animate and update data
	if selected_icon and active_icon != selected_icon:
		active_icon = selected_icon
		cursor.global_position = active_icon.global_position
		animate_icon(active_icon)

func animate_open() -> void:    
	active = true
	show()
	heal_icon.show()
	upgrade_icon.show()
	sell_icon.show()
	info_icon.show()

	var tween: Tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(heal_icon, "position:y", (heal_icon.position.y - OPEN_OFFSET), OPEN_CLOSE_SPEED)
	tween.tween_property(upgrade_icon, "position:x", (upgrade_icon.position.x + OPEN_OFFSET), OPEN_CLOSE_SPEED)
	tween.tween_property(sell_icon, "position:x", (sell_icon.position.x - OPEN_OFFSET), OPEN_CLOSE_SPEED)
	tween.tween_property(info_icon, "position:y", (info_icon.position.y + OPEN_OFFSET), OPEN_CLOSE_SPEED)
	await tween.finished
	cursor.show()
	active_icon = heal_icon

func animate_close() -> void:    
	var tween: Tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(heal_icon, "position", CLOSE_RESET_POSITION, OPEN_CLOSE_SPEED)
	tween.tween_property(upgrade_icon, "position", CLOSE_RESET_POSITION, OPEN_CLOSE_SPEED)
	tween.tween_property(sell_icon, "position", CLOSE_RESET_POSITION, OPEN_CLOSE_SPEED)
	tween.tween_property(info_icon, "position", CLOSE_RESET_POSITION, OPEN_CLOSE_SPEED)
	cursor.hide()

	await tween.finished
	heal_icon.hide()
	upgrade_icon.hide()
	sell_icon.hide()
	active = false
	hide()

func _draw():
	draw_circle(global_position, 3, Color.RED, true)

func animate_icon(icon: TextureRect) -> void:
	var shake_tween: Tween = get_tree().create_tween()
	var shake_range: float = 3.3
	var shake_duration: float = .03
	shake_tween.tween_property(icon, "rotation_degrees", shake_range, shake_duration)
	shake_tween.tween_interval(shake_duration)
	shake_tween.tween_property(icon, "rotation_degrees", 0, shake_duration)
	shake_tween.tween_interval(shake_duration)
	shake_tween.tween_property(icon, "rotation_degrees", -shake_range, shake_duration)
	shake_tween.tween_interval(shake_duration)
	shake_tween.tween_property(icon, "rotation_degrees", 0, shake_duration)
	shake_tween.tween_interval(shake_duration)

	var move_tween: Tween = get_tree().create_tween()
	var reset: float = icon.position.y
	move_tween.tween_property(icon, "position:y", reset - 1, .03)
	move_tween.tween_interval(shake_duration)
	move_tween.tween_property(icon, "position:y", reset, .03)
