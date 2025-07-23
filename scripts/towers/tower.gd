class_name Tower
extends Node2D

# Child references
@onready var sprite: Sprite2D = $Sprite2D
@onready var swap_sprite: Sprite2D = $SwapSprite
@onready var cross_sprite: Sprite2D = $CrossSprite
@onready var area: Area2D = $Area2D
@onready var transform_area: Area2D = %TransformArea
@onready var collider: CollisionShape2D = $Area2D/CollisionShape2D
@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var range_indicator = $RangeIndicator
@onready var transform_hint_sprite: Sprite2D = %TransformHintSprite

# Internal data
var active_target: Enemy
var in_range_targets: Array[Enemy] = []
var attack_timer: Timer = Timer.new()
var transform_timer: Timer = Timer.new()
var transform_delay: float = 0.1
var can_transform: bool = true # Set to true after brief delay in on_transform_timer_timeout()
var can_attack: bool = true

# TowerData resources
var data: TowerData
var base_data: TowerData
var transform_data: TowerData

# Tower data (for transformations)
var tower_data: Dictionary[Constants.Element, TowerData] = {
	Constants.Element.FIRE: preload("res://data/towers/tower_data_fire.tres"),
	Constants.Element.EARTH: preload("res://data/towers/tower_data_earth.tres"),
	Constants.Element.WATER: preload("res://data/towers/tower_data_water.tres"),
	Constants.Element.WIND: preload("res://data/towers/tower_data_wind.tres"),
	Constants.Element.DARK: preload("res://data/towers/tower_data_dark.tres"),
	Constants.Element.LIGHT: preload("res://data/towers/tower_data_light.tres"),}

# Bullets
var bullets: Dictionary[Constants.Element, PackedScene] = {
	Constants.Element.FIRE: preload("res://scenes/towers/bullets/FireBullet.tscn"),
	Constants.Element.WIND: preload("res://scenes/towers/bullets/WindBullet.tscn"),
	Constants.Element.WATER: preload("res://scenes/towers/bullets/WaterBullet.tscn"),
	Constants.Element.EARTH: preload("res://scenes/towers/bullets/WaterBullet.tscn"),
	Constants.Element.LIGHT: preload("res://scenes/towers/bullets/WaterBullet.tscn"),
	Constants.Element.DARK: preload("res://scenes/towers/bullets/WaterBullet.tscn"),}

# Debug
var debug_attack_line: Line2D = Line2D.new()

signal transform_tower
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

func initialize(element: Constants.Element):
	base_data = tower_data[element]
	transform_data = tower_data[base_data.transform_element]
	data = base_data
	update_textures()

	# Configure CollisionShape2D
	var shape: CircleShape2D = collider.shape
	shape.radius = data.attack_range	
	range_indicator.hide()

	# Configure Timers
	attack_timer.timeout.connect(on_attack_timer_timeout)
	attack_timer.one_shot = true
	add_child(attack_timer)
	attack_timer.start(data.speed)

	transform_timer.timeout.connect(on_transform_timer_timeout)
	transform_timer.one_shot = true
	add_child(transform_timer)
	transform_timer.start(transform_delay) # time until you can transform a tower (so it doesn't when you click to spawn it)

## Transform into the next tower type in the cycle. Defined in `TowerData.transform_element`. 
func transform() -> void:
	data = transform_data
	swap_sprite.hide()
	cross_sprite.show()
	can_transform = false
	update_textures()

func revert() -> void:
	data = base_data
	cross_sprite.hide()
	swap_sprite.hide()
	can_transform = true
	update_textures()

func update_textures() -> void:
	sprite.texture = data.atlas
	transform_hint_sprite.texture = data.transform_hint_texture

func _physics_process(_delta):	
	if can_attack:
		active_target = get_active_target()
		if active_target:
			attack()
			can_attack = false
			attack_timer.start(data.speed)

	ap.play("idle")

func attack() -> void:
	flip_to_face_active_target()
	spawn_bullet()
	play_shot_sfx()

func get_active_target() -> Enemy:
	var max_progress: float = -INF
	if in_range_targets.size() != 0:
		for enemy: Enemy in in_range_targets:
			if enemy.path_follow.progress_ratio > max_progress:
				max_progress = enemy.path_follow.progress_ratio
				active_target = enemy
		return active_target
	else: 
		return null

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

func spawn_bullet() -> void:
	var new_bullet: Bullet = bullets[data.element].instantiate()
	new_bullet.element = data.element
	new_bullet.damage = int(data.damage)
	new_bullet.target = active_target
	new_bullet.position += new_bullet.pos_offset
	add_child(new_bullet)

func flip_to_face_active_target():
	if active_target:
		var direction: Vector2 = global_position.direction_to(active_target.global_position)
		if direction > Vector2.ZERO:
			sprite.flip_h = false
		else:
			sprite.flip_h = true

func play_shot_sfx() -> void:
	# TODO: THis should go inside bullet, play on spawn
	match data.element:
		Constants.Element.FIRE: SFXPlayer.play_sfx("fire_shot")
		Constants.Element.WIND: SFXPlayer.play_sfx("earth_shot")
		Constants.Element.WATER: SFXPlayer.play_sfx("water_shot")
		_: SFXPlayer.play_sfx("water_shot")

func on_mouse_entered_transform_area():
	range_indicator.show()
	tower_hovered.emit(self)

func on_mouse_exited_transform_area():
	range_indicator.hide()
	tower_unhovered.emit(self)

func on_transform_area_pressed(_viewport, _event, _shape_idx) -> void:
	if Input.is_action_just_pressed("left_click"):
		transform_tower.emit()
		
func on_attack_timer_timeout() -> void:
	can_attack = true

func on_transform_timer_timeout() -> void:
	can_transform = true
