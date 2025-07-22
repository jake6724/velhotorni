class_name Tower
extends Node2D

@export var tower_data: TowerData

# Child references
@onready var sprite: Sprite2D = $Sprite2D
@onready var swap_sprite: Sprite2D = $SwapSprite
@onready var cross_sprite: Sprite2D = $CrossSprite
@onready var area: Area2D = $Area2D
@onready var transform_area: Area2D = %TransformArea
@onready var collider: CollisionShape2D = $Area2D/CollisionShape2D
@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var range_indicator = $RangeIndicator

var active_target: Enemy
var in_range_targets: Array[Enemy] = []
var attack_timer: Timer = Timer.new()
var transform_timer: Timer = Timer.new()
var transform_delay: float = 0.1

var can_transform: bool = true # Set to true after brief delay in on_transform_timer_timeout()
# var transform_delay_complete: bool = false

# Data from TowerData resource
var element: Constants.Element
var transform_element: Constants.Element
var damage: float
var speed: float
var attack_range: float = 50.0
var num_targets: int
var can_attack: bool = true

var base_element: Constants.Element = Constants.Element.NONE

# Tower data (for transformations)
var tower_resources: Dictionary[Constants.Element, TowerData] = {
	Constants.Element.FIRE: preload("res://data/towers/fire.tres"),
	Constants.Element.EARTH: preload("res://data/towers/earth.tres"),
	Constants.Element.WATER: preload("res://data/towers/water.tres"),}

# Bullets
var bullets: Dictionary[Constants.Element, PackedScene] = {
	Constants.Element.FIRE: preload("res://scenes/towers/bullets/FireBullet.tscn"),
	Constants.Element.EARTH: preload("res://scenes/towers/bullets/EarthBullet.tscn"),
	Constants.Element.WATER: preload("res://scenes/towers/bullets/WaterBullet.tscn"),}

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

	# Configure CollisionShape2D
	var shape: CircleShape2D = collider.shape
	shape.radius = attack_range

	range_indicator.hide()

	# Configure Timers
	attack_timer.timeout.connect(on_attack_timer_timeout)
	attack_timer.one_shot = true
	add_child(attack_timer)
	attack_timer.start(speed)

	transform_timer.timeout.connect(on_transform_timer_timeout)
	transform_timer.one_shot = true
	add_child(transform_timer)
	transform_timer.start(transform_delay) # time until you can transform a tower (so it doesn't when you click to spawn it)

## Used to update `Tower` class with data from a `TowerData` resource. Must be called immeadiately after a tower is instantiated
## by `PlayerController`. Used in `transform()` and `revert()` as well. **MUST be called after `Tower` has been added to scene
func configure_tower(_element: Constants.Element) -> void:
	tower_data = tower_resources[_element]

	# Set vars from data resource assigned above
	element = tower_data.element
	damage = tower_data.damage
	speed = tower_data.speed
	attack_range = tower_data.attack_range
	num_targets = tower_data.num_targets
	sprite.texture = tower_data.atlas
	transform_element = tower_data.transform_element

	if base_element == Constants.Element.NONE:
		base_element = element

## Transform into the next tower type in the cycle. Defined in `TowerData.transform_element`. 
func transform() -> void:
	configure_tower(transform_element)
	can_transform = false
	swap_sprite.hide()
	cross_sprite.show()

func revert() -> void:
	configure_tower(base_element)
	cross_sprite.hide()
	swap_sprite.hide()
	can_transform = true

func _physics_process(_delta):	
	if can_attack:
		active_target = get_active_target()
		if active_target:
			attack()
			can_attack = false
			attack_timer.start(speed)

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
	var new_bullet: Bullet = bullets[element].instantiate()
	new_bullet.element = element
	new_bullet.damage = int(damage)
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
	match element:
		Constants.Element.FIRE: SFXPlayer.play_sfx("fire_shot")
		Constants.Element.EARTH: SFXPlayer.play_sfx("earth_shot")
		Constants.Element.WATER: SFXPlayer.play_sfx("water_shot")

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
