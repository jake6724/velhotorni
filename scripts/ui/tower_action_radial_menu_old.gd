class_name TowerActionRadialMenuOld
extends Control

@onready var heal_icon: TextureRect = %HealIcon
@onready var upgrade_icon: TextureRect = %UpgradeIcon
@onready var sell_icon: TextureRect = %SellIcon

@onready var center_point: Control = %CenterPoint
@onready var cursor: Control = %Cursor

var active: bool = false

# @onready var info_icon: TextureRect = %InfoIcon

# func _input(event):
# 	if Input.is_action_pressed("x"):
# 		if not active:
# 			animate_open()
# 	if Input.is_action_just_released("x"):
# 		animate_close()

func _ready():
	# heal_icon.global_position = center_point.global_position
	# upgrade_icon.global_position = center_point.global_position
	# sell_icon.global_position = center_point.global_position
	
	heal_icon.hide()
	upgrade_icon.hide()
	sell_icon.hide()

func _process(delta: float) -> void:
	queue_redraw()
	var mouse_position: Vector2 = get_global_mouse_position()
	var angle: float = rad_to_deg(mouse_position.angle_to(center_point.global_position))
	print(angle)

	if angle >= .03 and angle <= .07:
		# print("Move to heal")
		cursor.global_position = heal_icon.global_position

	elif angle >= -.04 and angle <= .08: 
		# print("Move to upgrade")
		cursor.global_position = upgrade_icon.global_position

	elif angle >= -.07 and angle <= .07: 
		# print("Move to sell")
		cursor.global_position = sell_icon.global_position


func animate_open() -> void:    
	var open_offset: float = 24.0
	var open_speed: float = .1
	active = true
	show()
	heal_icon.show()
	upgrade_icon.show()
	sell_icon.show()

	var tween_1: Tween = get_tree().create_tween()
	var tween_2: Tween = get_tree().create_tween()
	var tween_3: Tween = get_tree().create_tween()
	
	tween_1.tween_property(heal_icon, "position:y", (heal_icon.position.y - open_offset), open_speed)
	tween_2.tween_property(upgrade_icon, "position:x", (upgrade_icon.position.x + open_offset), open_speed)
	tween_3.tween_property(sell_icon, "position:x", (sell_icon.position.x - open_offset), open_speed)

	await tween_1.finished
	cursor.show()
	cursor.global_position = heal_icon.global_position

func animate_close() -> void:    
	var open_speed: float = .1
	
	var tween_1: Tween = get_tree().create_tween()
	var tween_2: Tween = get_tree().create_tween()
	var tween_3: Tween = get_tree().create_tween()
	
	tween_1.tween_property(heal_icon, "position", Vector2(-8,-8), open_speed)
	tween_2.tween_property(upgrade_icon, "position", Vector2(-8,-8), open_speed)
	tween_3.tween_property(sell_icon, "position", Vector2(-8,-8), open_speed)

	cursor.hide()
	await tween_1.finished
	heal_icon.hide()
	upgrade_icon.hide()
	sell_icon.hide()

	active = false
	hide()

func _draw():
	draw_circle(center_point.global_position, 3, Color.RED, true)
