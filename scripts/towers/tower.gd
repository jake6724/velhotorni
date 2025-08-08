# TODO: Maybe go back to using data.damage etc, and set base_data_damage ? 

class_name Tower
extends Node2D

enum TargetPriority {FIRST, LAST, HIGHEST, LOWEST}
var level_upgrade_price: int = 25

# Child references
@onready var sprite: Sprite2D = $Sprite2D
@onready var swap_sprite: Sprite2D = $SwapSprite
@onready var cross_sprite: Sprite2D = $CrossSprite
@onready var area: Area2D = $Area2D
@onready var transform_area: Area2D = %TransformArea
@onready var transform_collider: CollisionShape2D = %TransformCollider
@onready var collider: CollisionShape2D = $Area2D/CollisionShape2D
@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var range_indicator = $RangeIndicator
@onready var transform_hint_sprite: Sprite2D = %TransformHintSprite
@onready var tower_targeting: TowerTargeting = %TowerTargeting
@onready var buff_manager: BuffManager = %BuffManager
@onready var buff_collider: CollisionShape2D = %BuffCollider
@onready var buff_area: BuffArea = %BuffArea

# Internal data
var active_target: Enemy
var in_range_targets: Array[Enemy] = []
var attack_timer: Timer = Timer.new()
var transform_timer: Timer = Timer.new()
var transform_delay: float = .01
var can_transform: bool = false # Set to true after brief delay in on_transform_timer_timeout()
var can_attack: bool = true
var can_show_range: bool: 
	set(value):
		can_show_range = value
		queue_redraw()

# Combat Data
var curr_damage: float
var curr_speed: float
var curr_range: float

# Preview data (used in tower upgrade menu)
var preview_damage: float
var preview_speed: float
var preview_range: float

const MAX_LEVEL_PRICE: int = 75
const LEVEL_COST_INCREMENT: int = 25
var level: int = 0
var damage_level: int = 0:
	set(value):
		damage_level = value
		level += 1
		level_upgrade_price = min(level_upgrade_price + LEVEL_COST_INCREMENT, MAX_LEVEL_PRICE)
		update_current_combat_data()

var speed_level: int = 0:
	set(value):
		speed_level = value
		level += 1
		level_upgrade_price = min(level_upgrade_price + LEVEL_COST_INCREMENT, MAX_LEVEL_PRICE)
		update_current_combat_data()

var range_level: int = 0:
	set(value):
		range_level = value
		level += 1
		level_upgrade_price = min(level_upgrade_price + LEVEL_COST_INCREMENT, MAX_LEVEL_PRICE)
		update_current_combat_data()
		update_colliders()

var special_level: int = 0:
	set(value):
		special_level = value
		level += 1
		level_upgrade_price = min(level_upgrade_price + LEVEL_COST_INCREMENT, MAX_LEVEL_PRICE)
		update_debuff_data()
		update_buff_data()
		refresh_buff_collider()

const DAMAGE_MODIFIER: float = 0.5
const RANGE_MODIFIER: float = 0.2
const SPEED_MODIFIER: float = 0.33

const BURN_DAMAGE_MODIFIER: float = 0.75
const KNOCKBACK_DISTANCE_MODIFIER: float = 0.5
const SLOW_DURATION_MODIFIER: float = 0.3333
const FREEZE_DURATION_MODIFIER: float = 0.3333
const STUN_DURATION_MODIFIER: float = 0.3333
const WEAKEN_DURATION_MODIFIER: float = 1

const RANGE_BUFF_LEVEL_MODIFIER: float = .33
const DAMAGE_BUFF_LEVEL_MODIFIER: float = .33
const SPEED_BUFF_LEVEL_MODIFIER: float = .33

# TowerData resources
var data: TowerData
var base_data: TowerData
var transform_data: TowerData

var target_priority: TargetPriority = TargetPriority.FIRST

# Tower data (for transformations)
var tower_data: Dictionary[Constants.Element, TowerData] = {
	Constants.Element.FIRE: load("res://data/towers/tower_data_fire.tres"),
	Constants.Element.EARTH: load("res://data/towers/tower_data_earth.tres"),
	Constants.Element.WATER: load("res://data/towers/tower_data_water.tres"),
	Constants.Element.WIND: load("res://data/towers/tower_data_wind.tres"),
	Constants.Element.DARK: load("res://data/towers/tower_data_dark.tres"),
	Constants.Element.LIGHT: load("res://data/towers/tower_data_light.tres"),}

# Debugs
var debug_attack_line: Line2D = Line2D.new()

signal tower_clicked
signal tower_hovered
signal tower_unhovered

func _ready():
	# Configure Area2D
	area.area_entered.connect(on_area_entered)
	area.area_exited.connect(on_area_exited)

	# Configure Transforming
	transform_area.input_event.connect(on_transform_area_pressed)
	transform_area.mouse_entered.connect(on_mouse_entered_transform_area)
	transform_area.mouse_exited.connect(on_mouse_exited_transform_area)

## Must be called after `Tower` has been added to scene with `add_child()`.
func initialize(element: Constants.Element):
	base_data = get_tower_data_copy(tower_data[element])
	# base_data = tower_data[element].duplicate(true)
	transform_data = get_tower_data_copy(tower_data[base_data.transform_element])
	data = base_data

	update_current_combat_data()
	update_debuff_data()
	update_buff_data()
	update_textures()
	update_colliders()

	# Configure Timers
	attack_timer.timeout.connect(on_attack_timer_timeout)
	attack_timer.one_shot = true
	add_child(attack_timer)
	attack_timer.start(curr_speed)

	transform_timer.timeout.connect(on_transform_timer_timeout)
	transform_timer.one_shot = true
	add_child(transform_timer)
	transform_timer.start(transform_delay) # time until you can transform a tower (so it doesn't when you click to spawn it)

	can_show_range = false

	# Connect to BuffManager and BuffArea
	if data.buff_data_list.size() > 0:
		buff_area.initialize()

	buff_manager.add_new_buff.connect(on_add_new_buff)
	buff_manager.remove_active_buff.connect(on_remove_active_buff)

func _physics_process(_delta):	
	if can_attack:
		active_target = tower_targeting.get_active_target(target_priority, in_range_targets)
		if active_target:
			attack()
			can_attack = false
			attack_timer.start(curr_speed)

	ap.play("idle")

func attack() -> void:
	flip_to_face_active_target()
	spawn_bullet()
	play_shot_sfx()

func spawn_bullet() -> void:
	var new_bullet: Bullet = data.bullet.instantiate()
	new_bullet.initialize(active_target, data.element, curr_damage, data.debuff_data, data.bullet_speed, data.attack_range)
	new_bullet.position += new_bullet._pos_offset
	add_child(new_bullet)

## Transform into the next tower type in the cycle. Defined in `TowerData.transform_element`. 
func transform() -> void:
	data = transform_data
	swap_sprite.hide()
	cross_sprite.show()
	can_transform = false
	reset_tower()

func revert() -> void:
	if not can_transform: # Has previously transformed 
		data = base_data
		cross_sprite.hide()
		swap_sprite.hide()
		can_transform = true
		reset_tower()

## Remove all debuffs, refresh colliders so that buffs can be reapplied, update collider sizes, update textures.
func reset_tower() -> void:
	buff_manager.remove_all_buffs()
	update_current_combat_data()
	update_debuff_data()
	update_buff_data()
	refresh_transform_collider()
	update_colliders()
	update_textures()

func update_current_combat_data() -> void:
	# TODO: Buffs?
	curr_damage = data.damage + (damage_level * (data.damage * DAMAGE_MODIFIER))  
	curr_speed = data.speed / (1.0 + (speed_level * SPEED_MODIFIER))
	curr_range = data.attack_range * (1.0 + (range_level * RANGE_MODIFIER))
	update_preview_combat_data()

func update_preview_combat_data() -> void:
	preview_damage = data.damage + ((damage_level + 1) * (data.damage * DAMAGE_MODIFIER))  
	preview_speed = data.speed / (1.0 + ((speed_level + 1) * SPEED_MODIFIER))
	preview_range = data.attack_range * (1.0 + ((range_level + 1 )* RANGE_MODIFIER))

func update_debuff_data() -> void:
	if data.debuff_data:
		match data.debuff_data.type:
			Debuff.Type.BURN: 
				data.debuff_data.modified_value = data.debuff_data.value + ((data.debuff_data.value * BURN_DAMAGE_MODIFIER) * special_level)
			Debuff.Type.KNOCKBACK: 
				data.debuff_data.modified_value = data.debuff_data.value + ((data.debuff_data.value * KNOCKBACK_DISTANCE_MODIFIER) * special_level)
			Debuff.Type.SLOW:
				data.debuff_data.modified_total_duration = data.debuff_data.total_duration + ((data.debuff_data.total_duration * SLOW_DURATION_MODIFIER) * special_level)
			Debuff.Type.FREEZE:
				data.debuff_data.modified_total_duration = data.debuff_data.total_duration + ((data.debuff_data.total_duration * FREEZE_DURATION_MODIFIER) * special_level)
			Debuff.Type.STUN:
				data.debuff_data.modified_total_duration = data.debuff_data.total_duration + ((data.debuff_data.total_duration * STUN_DURATION_MODIFIER) * special_level)
			Debuff.Type.WEAKEN:
				data.debuff_data.modified_total_duration = data.debuff_data.total_duration + ((data.debuff_data.total_duration * WEAKEN_DURATION_MODIFIER) * special_level)
		update_preview_debuff_data()

func update_preview_debuff_data() -> void:
	if data.debuff_data:
		match data.debuff_data.type:
			Debuff.Type.BURN: 
				data.debuff_data.preview_modified_value = data.debuff_data.value + ((data.debuff_data.value * BURN_DAMAGE_MODIFIER) * (special_level + 1))
			Debuff.Type.KNOCKBACK: 
				data.debuff_data.preview_modified_value = data.debuff_data.value + ((data.debuff_data.value * KNOCKBACK_DISTANCE_MODIFIER) * (special_level + 1))
			Debuff.Type.SLOW:
				data.debuff_data.preview_modified_total_duration = data.debuff_data.total_duration + ((data.debuff_data.total_duration * SLOW_DURATION_MODIFIER) * (special_level + 1))
			Debuff.Type.FREEZE:
				data.debuff_data.preview_modified_total_duration = data.debuff_data.total_duration + ((data.debuff_data.total_duration * FREEZE_DURATION_MODIFIER) * (special_level + 1))
			Debuff.Type.STUN:
				data.debuff_data.preview_modified_total_duration = data.debuff_data.total_duration + ((data.debuff_data.total_duration * STUN_DURATION_MODIFIER) * (special_level + 1))
			Debuff.Type.WEAKEN:
				data.debuff_data.preview_modified_total_duration = data.debuff_data.total_duration + ((data.debuff_data.total_duration * WEAKEN_DURATION_MODIFIER) * (special_level + 1))

func update_buff_data() -> void:
	if data.buff_data_list and data.buff_data_list[0]:
		match data.buff_data_list[0].type:
			Buff.Type.RANGE:
				data.buff_data_list[0].leveled_value = data.buff_data_list[0].value + ((data.buff_data_list[0].value * RANGE_BUFF_LEVEL_MODIFIER) * special_level)
			Buff.Type.DAMAGE:
				data.buff_data_list[0].leveled_value = data.buff_data_list[0].value + ((data.buff_data_list[0].value * DAMAGE_BUFF_LEVEL_MODIFIER) * special_level)
			Buff.Type.SPEED:
				data.buff_data_list[0].leveled_value = data.buff_data_list[0].value + ((data.buff_data_list[0].value * SPEED_BUFF_LEVEL_MODIFIER) * special_level)
		
		buff_area.buff_data_list = data.buff_data_list.duplicate(true)
		update_preview_buff_data()

func update_preview_buff_data() -> void:
	if data.buff_data_list and data.buff_data_list[0]:
		match data.buff_data_list[0].type:
			Buff.Type.RANGE:
				data.buff_data_list[0].preview_leveled_value = data.buff_data_list[0].value + ((data.buff_data_list[0].value * RANGE_BUFF_LEVEL_MODIFIER) * (special_level + 1))
			Buff.Type.DAMAGE:
				data.buff_data_list[0].preview_leveled_value = data.buff_data_list[0].value + ((data.buff_data_list[0].value * DAMAGE_BUFF_LEVEL_MODIFIER) * (special_level + 1))
			Buff.Type.SPEED:
				data.buff_data_list[0].preview_leveled_value = data.buff_data_list[0].value + ((data.buff_data_list[0].value * SPEED_BUFF_LEVEL_MODIFIER) * (special_level + 1))

func flip_to_face_active_target():
	if active_target:
		var direction: Vector2 = global_position.direction_to(active_target.global_position)
		if direction > Vector2.ZERO:
			sprite.flip_h = false
		else:
			sprite.flip_h = true

func play_shot_sfx() -> void:
	# TODO: THis should go inside bullet, play on spawn, make it positional too ? rework of sfx required
	# OR maybe this should be part of tower, and tower should have positional sound node to play stuff
	match data.element:
		Constants.Element.FIRE: SFXPlayer.play_sfx("fire_shot")
		Constants.Element.WIND: SFXPlayer.play_sfx("wind_shot")
		Constants.Element.WATER: SFXPlayer.play_sfx("water_shot")
		_: SFXPlayer.play_sfx("water_shot")

func update_textures() -> void:
	sprite.texture = data.atlas
	transform_hint_sprite.texture = data.transform_hint_texture

func on_enemy_died(enemy: Enemy) -> void:
	var index = in_range_targets.find(enemy)
	if index != -1:
		in_range_targets.remove_at(index)

	if enemy == active_target: 
		active_target = null
		
func on_area_entered(intruder: Area2D) -> void:
	if intruder is Enemy:
		in_range_targets.append(intruder)
		intruder.died.connect(on_enemy_died)

func on_area_exited(intruder) -> void:
	if intruder is Enemy:
		if intruder == active_target:
			active_target = null

		if intruder in in_range_targets:
			in_range_targets.remove_at(in_range_targets.find(intruder))
			intruder.died.disconnect(on_enemy_died)

func on_mouse_entered_transform_area():
	can_show_range = true
	tower_hovered.emit(self)

func on_mouse_exited_transform_area():
	can_show_range = false
	tower_unhovered.emit(self)

# Click-input check
func on_transform_area_pressed(_viewport, _event, _shape_idx) -> void:
	if Input.is_action_just_pressed("left_click"):
		tower_clicked.emit()
			
func on_attack_timer_timeout() -> void:
	can_attack = true

func on_transform_timer_timeout() -> void: 
	can_transform = true

func _draw():
	if can_show_range:
		draw_circle(Vector2.ZERO + Vector2(8,8), curr_range, Color.WHITE, false, -1.0, false)

# Buffs
func on_add_new_buff(buff: Buff):
	match buff.data.type:
		Buff.Type.RANGE:
			curr_range += data.attack_range * buff.data.modified_value
			update_colliders()
		Buff.Type.SPEED:
			curr_speed = max(.01, curr_speed - data.speed * buff.data.modified_value)
		Buff.Type.DAMAGE:
			curr_damage += data.damage * buff.data.modified_value
		_: pass

func on_remove_active_buff(buff: Buff):
	match buff.data.type:
		Buff.Type.RANGE:
			curr_range -= data.attack_range * buff.data.modified_value
			update_colliders()
		Buff.Type.SPEED:
			curr_speed += data.speed * buff.data.modified_value
		Buff.Type.DAMAGE:
			curr_damage -= data.damage * buff.data.modified_value
		_: pass

func refresh_transform_collider() -> void:
	transform_collider.disabled = true
	await get_tree().create_timer(.1).timeout
	transform_collider.disabled = false

func refresh_buff_collider() -> void:
	buff_collider.disabled = true
	await get_tree().create_timer(.1).timeout
	buff_collider.disabled = false

func update_colliders() -> void:
	buff_collider.shape.radius = curr_range
	collider.shape.radius =  curr_range
	queue_redraw()

## Returns a deep, custom copy of a `TowerData` resource
func get_tower_data_copy(_input_data: TowerData) -> TowerData:
	var new_data: TowerData = _input_data.duplicate(true)

	# duplicate(true) on a CR will NOT deep-copy arrays or dicts; do that manually here
	new_data.buff_data_list = []
	for buff_data: BuffData in _input_data.buff_data_list:
		new_data.buff_data_list.append(buff_data.duplicate(true))
	return new_data
