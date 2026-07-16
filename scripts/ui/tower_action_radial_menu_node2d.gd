class_name TowerActionRadialMenuNode2D
extends Node2D

@onready var heal_icon: Sprite2D = %HealIcon
@onready var upgrade_icon: Sprite2D = %UpgradeIcon
@onready var sell_icon: Sprite2D = %SellIcon

@onready var center_point: Node2D = %CenterPoint
@onready var cursor: Sprite2D = %Cursor

var active: bool = false

# @onready var info_icon: TextureRect = %InfoIcon

# func _input(event):
# 	# print("Input!")
# 	if Input.is_action_pressed("x"):
# 		if not active:
# 			animate_open()
# 	if Input.is_action_just_released("x"):
# 		animate_close()

# func _ready():
# 	print("Ruinning stcript")
# 	heal_icon.hide()
# 	upgrade_icon.hide()
# 	sell_icon.hide()

# func _process(delta: float) -> void:
# 	queue_redraw()
# 	var mouse_position: Vector2 = get_global_mouse_position()
# 	var direction: Vector2 = mouse_position.direction_to(center_point.global_position)
# 	var angle: float = direction.angle()
		
# 	if angle <= 2.5 and angle >= .75:
# 		# print("Test")
# 		cursor.show()
# 		cursor.global_position = heal_icon.global_position
# 	elif angle :
# 		cursor.hide()


# func animate_open() -> void:    
# 	var open_offset: float = 24.0
# 	var open_speed: float = .1
# 	active = true
# 	show()
# 	heal_icon.show()
# 	upgrade_icon.show()
# 	sell_icon.show()

# 	var tween_1: Tween = get_tree().create_tween()
# 	var tween_2: Tween = get_tree().create_tween()
# 	var tween_3: Tween = get_tree().create_tween()
	
# 	tween_1.tween_property(heal_icon, "position:y", (heal_icon.position.y - open_offset), open_speed)
# 	tween_2.tween_property(upgrade_icon, "position:x", (upgrade_icon.position.x + open_offset), open_speed)
# 	tween_3.tween_property(sell_icon, "position:x", (sell_icon.position.x - open_offset), open_speed)

# 	await tween_1.finished
# 	cursor.show()
# 	cursor.global_position = heal_icon.global_position

# func animate_close() -> void:    
# 	var open_speed: float = .1
	
# 	var tween_1: Tween = get_tree().create_tween()
# 	var tween_2: Tween = get_tree().create_tween()
# 	var tween_3: Tween = get_tree().create_tween()
	
# 	tween_1.tween_property(heal_icon, "position", Vector2(0,0), open_speed)
# 	tween_2.tween_property(upgrade_icon, "position", Vector2(0,0), open_speed)
# 	tween_3.tween_property(sell_icon, "position", Vector2(0,0), open_speed)

# 	cursor.hide()
# 	await tween_1.finished
# 	heal_icon.hide()
# 	upgrade_icon.hide()
# 	sell_icon.hide()

# 	active = false
# 	hide()

# func _draw():
# 	draw_circle(to_local(global_position), 3, Color.RED, true)
