class_name TowerActionRadialMenu
extends Control

@onready var heal_icon: TextureRect = %HealIcon
@onready var upgrade_icon: TextureRect = %UpgradeIcon
@onready var sell_icon: TextureRect = %SellIcon
@onready var info_icon: TextureRect = %InfoIcon
@onready var background: ColorRect = %Background
@onready var cursor: Control = %Cursor
@onready var action_label: Label = %ActionLabel
@onready var cost_label: Label = %CostLabel
@onready var cost_panel: PanelContainer = %CostPanel

const OPEN_CLOSE_SPEED: float = .1
const OPEN_OFFSET: float = 48.0
const CLOSE_RESET_POSITION: Vector2 = Vector2(-8,-8)

var active: bool = false

var active_icon: TextureRect

signal cost_requested

func _ready():
	heal_icon.hide()
	upgrade_icon.hide()
	sell_icon.hide()
	info_icon.hide()
	z_index = Constants.z_index_map["popup"]

func initialize(player: PlayerCharacter) -> void:
	player.player_input.angle_to_mouse_updated.connect(on_player_input_angle_to_mouse_updated)
	active_icon = heal_icon
	animate_close()

func on_player_input_angle_to_mouse_updated(angle_to_mouse: float) -> void:
	var angle = fposmod(angle_to_mouse, TAU)
	angle = rad_to_deg(angle)
	# print(angle)
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
		cursor.show()
		cursor.global_position = active_icon.global_position
		animate_icon(active_icon)
		set_action_label(active_icon)
		cost_requested.emit(select_action())

func select_action() -> PlayerBuild.TowerAction:
	match active_icon:
		heal_icon: return PlayerBuild.TowerAction.HEAL
		upgrade_icon: return PlayerBuild.TowerAction.UPGRADE
		sell_icon: return PlayerBuild.TowerAction.SELL
		info_icon: return PlayerBuild.TowerAction.INFO
		_:
			push_error("Unable to match TowerActionRadialMenu active_icon in select_action()")
			return PlayerBuild.TowerAction.NONE

func animate_open() -> void:    
	active = true
	show()
	background.show()
	heal_icon.show()
	upgrade_icon.show()
	sell_icon.show()
	info_icon.show()
	action_label.show()

	var tween: Tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(heal_icon, "position:y", (heal_icon.position.y - OPEN_OFFSET), OPEN_CLOSE_SPEED)
	tween.tween_property(upgrade_icon, "position:x", (upgrade_icon.position.x + OPEN_OFFSET), OPEN_CLOSE_SPEED)
	tween.tween_property(sell_icon, "position:x", (sell_icon.position.x - OPEN_OFFSET), OPEN_CLOSE_SPEED)
	tween.tween_property(info_icon, "position:y", (info_icon.position.y + OPEN_OFFSET), OPEN_CLOSE_SPEED)
	await tween.finished
	cursor.show()
	cursor.global_position = active_icon.global_position
	active_icon = heal_icon

func animate_close() -> void:    
	action_label.hide()
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
	background.hide()
	hide()

func animate_icon(icon: TextureRect) -> void:
	var shake_tween: Tween = get_tree().create_tween()
	var shake_range: float = 3.3
	var shake_duration: float = .03
	var scale_target: Vector2 = Vector2(1.2, 1.2)
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


	var scale_tween: Tween = get_tree().create_tween()
	scale_tween.tween_property(icon, "scale", scale_target, .03)
	scale_tween.tween_interval(shake_duration)
	scale_tween.tween_property(icon, "scale", Vector2.ONE, .03)

func set_action_label(icon: TextureRect) -> void:
	var _text: String
	match icon:
		heal_icon: _text = "Heal"
		upgrade_icon: _text = "Upgrade"
		sell_icon: _text = "Sell"
		info_icon: _text = "Info"
	action_label.text = _text

func set_cost_label(cost: int) -> void:
	if cost > 0:
		cost_panel.show()
		cost_label.text = str(cost)
	else:
		cost_panel.hide()