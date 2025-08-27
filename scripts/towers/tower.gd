class_name Tower
extends Node2D

enum TargetPriority {FIRST, LAST, HIGHEST, LOWEST}

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
@onready var hex_manager: HexManager = $HexManager
@onready var tower_audio: TowerAudio = $TowerAudio

# Internal data
var active_target: Enemy
var in_range_targets: Array[Enemy] = []
var attack_time_counter: float = 0.0
var transform_timer: Timer = Timer.new()
var transform_delay: float = .01
var can_transform: bool = false # Set to true after brief delay in on_transform_timer_timeout()
var can_attack: bool = true
var can_show_range: bool: 
	set(value):
		can_show_range = value
		queue_redraw()

var can_show_buff_range: bool: 
	set(value):
		can_show_buff_range = value
		queue_redraw()

var buff_range_transparency: float = .9
var color_buff_range_indicator: String = "#94ffbd"

# Combat Data
var curr_damage: float
var curr_speed: float
var curr_range: float
var _leveled_damage: float = 0.0
var _leveled_speed: float = 0.0
var _leveled_range: float = 0.0

var _damage_buff: float = 0.0
var _speed_buff: float = 0.0
var _range_buff: float = 0.0

var _hex_damage_multiplier: float = 1.0
var _hex_speed_multiplier: float = 1.0
var _hex_range_multiplier: float = 1.0

# Preview data (used in tower upgrade menu)
var preview_damage: float
var preview_speed: float
var preview_range: float
var _preview_leveled_damage: float
var _preview_leveled_range: float
var _preview_leveled_speed: float

const MAX_LEVEL_PRICE: int = 75
const LEVEL_COST_INCREMENT: int = 25
var level: int = 0
var damage_level: int = 0:
	set(value):
		set_deferred("transform_area", false)
		damage_level = value
		increment_level()
		update_current_combat_data()
		set_deferred("transform_area", true)

var speed_level: int = 0:
	set(value):
		set_deferred("transform_area", false)
		speed_level = value
		increment_level()
		update_current_combat_data()

var range_level: int = 0:
	set(value):
		set_deferred("transform_area", false)
		range_level = value
		increment_level()
		update_current_combat_data()
		update_colliders()
		set_deferred("transform_area", true)

var special_level: int = 0:
	set(value):
		set_deferred("transform_area", false)
		special_level = value
		increment_level()
		update_debuff_data()
		update_buff_data()
		update_bullet_modifier_data()
		refresh_buff_collider()
		set_deferred("transform_area", true)

var checkpoint_damage_level: int
var checkpoint_speed_level: int
var checkpoint_range_level: int
var checkpoint_special_level: int
var checkpoint_level: int

var is_evolved: bool = false
var is_evolve_checkpointed: bool = false

var level_upgrade_price: int = 25
var checkpoint_level_upgrade_price: int

const DAMAGE_MODIFIER: float = 0.5
const RANGE_MODIFIER: float = 0.2
const SPEED_MODIFIER: float = 0.3334

const BURN_DAMAGE_MODIFIER: float = 1
const KNOCKBACK_DISTANCE_MODIFIER: float = 0.5
const SLOW_DURATION_MODIFIER: float = 0.3334
const FREEZE_DURATION_MODIFIER: float = 0.3334
const STUN_DURATION_MODIFIER: float = 0.3334
const WEAKEN_DURATION_MODIFIER: float = 1

const DROP_CHANCE_MODIFIER: float = .3334

const RANGE_BUFF_LEVEL_MODIFIER: float = .5
const DAMAGE_BUFF_LEVEL_MODIFIER: float = .3334
const SPEED_BUFF_LEVEL_MODIFIER: float = .3334

const FLOAT_ERROR_MARGIN: float = .00001

# TowerData resources
var data: TowerData
var base_data: TowerData
var transform_data: TowerData

var target_priority: TargetPriority = TargetPriority.FIRST

# Debugs
var debug_attack_line: Line2D = Line2D.new()

var prev_enemy_progress: float
var cur_enemy_progress: float
var progress_diff: float


var attack_timer: Timer = Timer.new()

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

	attack_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	attack_timer.autostart = false
	attack_timer.timeout.connect(on_attack_timer_timeout)
	add_child(attack_timer)

## Must be called after `Tower` has been added to scene with `add_child()`.
func initialize(element: Constants.Element):
	base_data = get_tower_data_copy(Constants.tower_data[element])
	transform_data = get_tower_data_copy(Constants.tower_data[Constants.get_next_element(element)])
	data = base_data

	update_current_combat_data()
	update_debuff_data()
	update_buff_data()
	update_bullet_modifier_data()
	update_textures()
	update_colliders()
	update_audio()

	transform_timer.timeout.connect(on_transform_timer_timeout)
	transform_timer.one_shot = true
	add_child(transform_timer)
	transform_timer.start(transform_delay) # time until you can transform a tower (so it doesn't when you click to spawn it)

	can_show_range = false

	# Buff manager
	buff_manager.add_new_buff.connect(on_add_new_buff)
	buff_manager.remove_active_buff.connect(on_remove_active_buff)

	# Hex manager
	hex_manager.new_hex_added.connect(on_add_new_hex)
	hex_manager.active_hex_removed.connect(on_remove_active_hex)

	attack_timer.start(curr_speed)
	ap.play("idle")

func _physics_process(_delta):	
	if can_attack:
		attack()

func attack() -> void:
	active_target = tower_targeting.get_active_target(target_priority, in_range_targets)
	if active_target:
		can_attack = false
		attack_timer.start(curr_speed)
		flip_to_face_active_target()
		spawn_bullet()
		play_shot_sfx()

func on_attack_timer_timeout() -> void:
	can_attack = true
	
func spawn_bullet() -> void:
	var new_bullet = data.bullet.instantiate()
	new_bullet.initialize(active_target, data.base_element, curr_damage, data.debuff_data, data.bullet_speed, curr_range, data.attack_range, data.bullet_modifier_data)
	new_bullet.position += new_bullet._pos_offset
	add_child(new_bullet)

## Transform into the next tower type in the cycle. 
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

	swap_sprite.hide()
	cross_sprite.hide()

func evolve(selected_element: Constants.Element) -> void:
	is_evolved = true
	base_data = get_tower_data_copy(Constants.tower_data[selected_element])
	transform_data = get_tower_data_copy(Constants.tower_data[Constants.get_next_element(selected_element)])
	data = base_data
	reset_tower()

## Wrapper for lots of smaller update functions. 
## Remove all debuffs, refresh colliders so that buffs can be reapplied, update collider sizes, update textures, update audio.
func reset_tower() -> void:
	buff_manager.remove_all_buffs()
	update_current_combat_data()
	update_debuff_data()
	update_buff_data()
	update_bullet_modifier_data()
	refresh_transform_collider()
	refresh_buff_collider()
	update_colliders()
	update_textures()
	update_audio()

func update_current_combat_data() -> void:
	_leveled_damage = data.damage + (damage_level * (data.damage * DAMAGE_MODIFIER))  
	_leveled_speed = data.speed / (1.0 + (speed_level * SPEED_MODIFIER))
	_leveled_range = data.attack_range * (1.0 + (range_level * RANGE_MODIFIER))
	curr_damage = (_leveled_damage + _damage_buff) * _hex_damage_multiplier
	curr_speed = (_leveled_speed + _speed_buff) * _hex_speed_multiplier
	curr_range = (_leveled_range + _range_buff) * _hex_range_multiplier
	update_colliders()
	update_preview_combat_data()

func update_preview_combat_data() -> void:
	_preview_leveled_damage = data.damage + ((damage_level + 1) * (data.damage * DAMAGE_MODIFIER))
	_preview_leveled_speed = data.speed / (1.0 + ((speed_level + 1) * SPEED_MODIFIER))
	_preview_leveled_range = data.attack_range * (1.0 + ((range_level + 1 )* RANGE_MODIFIER))

	preview_damage = _preview_leveled_damage + _damage_buff
	preview_speed = _preview_leveled_speed + _speed_buff
	preview_range = _preview_leveled_range + _range_buff

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
	# Connect to BuffArea
	if data.buff_data_list.size() > 0:
		buff_area.initialize()
	else:
		buff_area.uninitialize()

	for buff_data: BuffData in data.buff_data_list:
		buff_data.leveled_value = buff_data.value

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

func update_bullet_modifier_data() -> void:
	if data.bullet_modifier_data:
		match data.bullet_modifier_data.type:
			BulletModifierData.Type.COIN:
				data.bullet_modifier_data.leveled_value = ((data.bullet_modifier_data.value * DROP_CHANCE_MODIFIER) * special_level) + data.bullet_modifier_data.value
	update_preview_bullet_modifier_data()

func update_preview_bullet_modifier_data() -> void:
	if data.bullet_modifier_data:
		match data.bullet_modifier_data.type:
			BulletModifierData.Type.COIN:
				data.bullet_modifier_data.preview_leveled_value = ((data.bullet_modifier_data.value * DROP_CHANCE_MODIFIER) * (special_level + 1)) + data.bullet_modifier_data.value
				
func flip_to_face_active_target():
	if active_target:
		var direction: Vector2 = global_position.direction_to(active_target.global_position)
		if direction > Vector2.ZERO:
			sprite.flip_h = false
		else:
			sprite.flip_h = true

func play_shot_sfx() -> void:
	tower_audio.play_shot()

func update_textures() -> void:
	sprite.texture = data.atlas
	transform_hint_sprite.texture = data.transform_hint_texture

func update_audio() -> void: 
	tower_audio.element = data.base_element
	tower_audio.initialize()

func increment_level() -> void:
	level += 1
	level_upgrade_price = min(level_upgrade_price + LEVEL_COST_INCREMENT, MAX_LEVEL_PRICE)

func on_enemy_died(enemy: Enemy) -> void:
	var index = in_range_targets.find(enemy)
	if index != -1:
		in_range_targets.remove_at(index)

	if enemy == active_target: 
		active_target = null
		
func on_area_entered(intruder: Area2D) -> void:
	if intruder is Enemy:
		in_range_targets.append(intruder)
		if not intruder.died.is_connected(on_enemy_died):
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

func on_transform_timer_timeout() -> void: 
	can_transform = true

func _draw():
	if can_show_range:
		draw_circle(Vector2.ZERO + Vector2(8,8), curr_range, Color.WHITE, false, -1.0, false)

	if can_show_buff_range and data.buff_data_list and data.buff_data_list[0]:
		draw_circle(Vector2.ZERO + Vector2(8,8), curr_range, Color(color_buff_range_indicator, buff_range_transparency), false, -1.0, false)

# Buffs
func on_add_new_buff(buff: Buff):
	match buff.data.type:
		Buff.Type.RANGE:
			_range_buff += _leveled_range * buff.data.modified_value
		Buff.Type.SPEED:
			_speed_buff +=  -(_leveled_speed * buff.data.modified_value)
			print(_speed_buff)
		Buff.Type.DAMAGE:
			_damage_buff += _leveled_damage * buff.data.modified_value
		_: pass
	update_current_combat_data()

func on_remove_active_buff(buff: Buff):
	match buff.data.type:
		Buff.Type.RANGE:
			_range_buff -= _leveled_range * buff.data.modified_value
		Buff.Type.SPEED:
			_speed_buff -=  -(_leveled_speed * buff.data.modified_value)
		Buff.Type.DAMAGE:
			_damage_buff -= _leveled_damage * buff.data.modified_value
		_: pass
	update_current_combat_data()

func refresh_transform_collider() -> void:
	transform_collider.set_deferred("disabled", true)
	await get_tree().create_timer(.1).timeout
	transform_collider.set_deferred("disabled", false)

func refresh_buff_collider() -> void:
	buff_collider.set_deferred("disabled", true)
	await get_tree().create_timer(.1).timeout
	buff_collider.set_deferred("disabled", false)

func update_colliders() -> void:
	buff_collider.shape.radius = curr_range
	collider.shape.radius =  curr_range
	queue_redraw()

## Returns a deep, custom copy of a `TowerData` resource
func get_tower_data_copy(_input_data: TowerData) -> TowerData:
	var new_data: TowerData = _input_data.duplicate(true)

	# duplicate(true) on a custom-resource will NOT deep-copy arrays or dicts; do that manually here
	new_data.buff_data_list = []
	for buff_data: BuffData in _input_data.buff_data_list:
		new_data.buff_data_list.append(buff_data.duplicate(true))
	return new_data

func set_checkpoint_levels() -> void:
	checkpoint_damage_level = damage_level
	checkpoint_speed_level = speed_level
	checkpoint_range_level = range_level
	checkpoint_special_level = special_level
	checkpoint_level = level
	checkpoint_level_upgrade_price = level_upgrade_price

	if is_evolved and not is_evolve_checkpointed:
		is_evolve_checkpointed = true

func revert_to_checkpoint() -> void:
	damage_level = checkpoint_damage_level
	speed_level = checkpoint_speed_level
	range_level = checkpoint_range_level
	special_level = checkpoint_special_level
	level = checkpoint_level
	level_upgrade_price = checkpoint_level_upgrade_price

	if not is_evolve_checkpointed:
		is_evolved = false
		revert_to_base_evolution()

func revert_to_base_evolution() -> void:
	TowerGlobalData.tower_evolution_status[data.element] = true
	base_data = get_tower_data_copy(Constants.tower_data[data.base_element])
	transform_data = get_tower_data_copy(Constants.tower_data[Constants.get_next_element(base_data.element)])
	data = base_data
	reset_tower()

# Hexes
func on_add_new_hex(hex: Hex):
	match hex.data.type:
		Hex.Type.DAMAGE:
			_hex_damage_multiplier -= hex.data.modified_value
		Hex.Type.SPEED:
			_hex_speed_multiplier -=  -(hex.data.modified_value) # this value SHOULD be positive
		Hex.Type.RANGE:
			_hex_range_multiplier -= hex.data.modified_value
		_: pass
	update_current_combat_data()

func on_remove_active_hex(hex: Hex):
	match hex.data.type:
		Hex.Type.DAMAGE:
			_hex_damage_multiplier += hex.data.modified_value
		Hex.Type.SPEED:
			_hex_speed_multiplier +=  -(hex.data.modified_value)
		Hex.Type.RANGE:
			_hex_range_multiplier += hex.data.modified_value
		_: pass
	update_current_combat_data()
