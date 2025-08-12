class_name Enemy
extends Area2D

enum Size {SMALL, MEDIUM, LARGE}

@export var data: EnemyData

# Child references
@onready var sprite: Sprite2D = $Sprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var shield: Sprite2D = $Shield
@onready var weak: Sprite2D = $Weak
@onready var debuff_manager: DebuffManager = $DebuffManager
@onready var boon_area: BoonArea = $BoonArea
@onready var boon_manager: BoonManager = $BoonManager

# Pathing 
var path_follow: PathFollow2D # Update `progress_ration` to move along path
var prev_global_position: Vector2 # Used for flipping sprite

var min_distance: float = 2

# Enemy Stats from Enemy Data Resource
var element: Constants.Element
var weak_against_element: Constants.Element
var strong_against_element: Constants.Element
var speed: float
var atlas: Texture

var max_health: float # Do not set manually; used in health bar
var health: float:
	set(new_health):
		health = new_health
		health_bar.value = (health / max_health) * 100

var damage: int = 1
var negative_modifier: float = .5
var positive_modifier: float = 2.0

var can_attack: bool = true
var is_alive: bool = true
var is_taking_damage = false

var base: Base

# Debuffs
var slow_percent: float = 0.0
var weaken_percent: float = 0.0
var is_frozen: bool = false
var is_stunned: bool = false

# Signals
signal died # Pass ref to the enemy object
signal death_position # Pass global_position

func _ready():
	data.resource_local_to_scene = true
	element = data.element
	strong_against_element = data.strong_against_element
	weak_against_element = data.weak_against_element 
	health = data.health
	speed = data.speed
	atlas = data.atlas
	max_health = health
	base = LevelManager.active_level.base # TODO: This is potentially bad; a collision box with layer that can only see base would be better ? 
	sprite.texture = atlas
	ap.animation_finished.connect(on_animation_finished)

	# Configure DebuffManager
	debuff_manager.add_new_debuff.connect(on_add_new_debuff)
	debuff_manager.cc_multiplier = data.cc_multiplier
	debuff_manager.knockback_multiplier = data.knockback_multiplier

	# Configure Boons
	if data.boon_data:
		boon_area.initialize(data.boon_data)
		boon_area.owner = self
	boon_manager.boon_connected.connect(on_boon_connected)

func _physics_process(delta):
	move(delta)
	debuff_manager.enemy_progress = path_follow.progress

func move(delta) -> void:
	if is_alive:
		if not is_frozen and not is_stunned:
			if not is_taking_damage:
				ap.play("walk")

			if path_follow.rotation_degrees >= 91: # Flip when moving right
				sprite.flip_h = true
			else: 
				sprite.flip_h = false
			if path_follow.progress_ratio < .99:
				path_follow.progress += ((speed - (speed * (slow_percent/100))) * delta)
			else:
				base.take_damage(damage)
				die()
		else:
			ap.play("idle")

	prev_global_position = global_position
	
## Reduce enemies `health` stat by `damage_recieved`. Return `true` if enemy died, `false` otherwise.
## Handles despawning enemy in the case of death.
func take_damage(damage_recieved: float, tower_element: Constants.Element):
	if is_alive:
		is_taking_damage = true
		ap.play("hit")

		# Hit by resisted element
		if tower_element == element or tower_element == strong_against_element:
			weak.hide()
			shield.show()
			damage_recieved *= negative_modifier

		# Hit by weak-to element
		elif tower_element == weak_against_element:
			weak.show()
			shield.hide()
			damage_recieved *= positive_modifier

		if not health_bar.is_visible():
			health_bar.show()

		# Apply Weaken modifier
		damage_recieved = damage_recieved + (damage_recieved * (weaken_percent/100))

		health -= damage_recieved

		if health <= 0:
			die()

func die() -> void:
	is_alive = false
	collider.set_deferred("disabled", true) # Collisions can't be changed until pp idle time
	ap.play("die")
	SFXPlayer.play_sfx_resource(data.explosion_sfx)
	died.emit(self)
	death_position.emit(global_position)

	# Hide graphics
	health_bar.hide()
	shield.hide()
	weak.hide()

func on_animation_finished(anim_name):
	if anim_name == "hit":
		is_taking_damage = false

	if anim_name == "die":
		ap.play("corpse")

	if anim_name == "corpse":
		queue_free()

# Debuffs

func on_add_new_debuff(_debuff: Debuff) -> void:
	for signal_dict in _debuff.get_signal_list():
		var signal_name: String = signal_dict["name"]
		match signal_name:
			"debuff_apply_slow": _debuff.connect(signal_name, Callable(self, "on_debuff_apply_slow"))
			"debuff_remove_slow": _debuff.connect(signal_name, Callable(self, "on_debuff_remove_slow"))
			"debuff_apply_freeze": _debuff.connect(signal_name, Callable(self, "on_debuff_apply_freeze"))
			"debuff_remove_freeze": _debuff.connect(signal_name, Callable(self, "on_debuff_remove_freeze"))
			"debuff_apply_stun": _debuff.connect(signal_name, Callable(self, "on_debuff_apply_stun"))
			"debuff_remove_stun": _debuff.connect(signal_name, Callable(self, "on_debuff_remove_stun"))
			"debuff_apply_burn": _debuff.connect(signal_name, Callable(self, "on_debuff_apply_burn"))
			"debuff_remove_burn": _debuff.connect(signal_name, Callable(self, "on_debuff_remove_burn"))
			"debuff_apply_weaken": _debuff.connect(signal_name, Callable(self, "on_debuff_apply_weaken"))
			"debuff_remove_weaken": _debuff.connect(signal_name, Callable(self, "on_debuff_remove_weaken"))
			"debuff_apply_knockback": _debuff.connect(signal_name, Callable(self, "on_debuff_apply_knockback"))
			"debuff_remove_knockback": _debuff.connect(signal_name, Callable(self, "on_debuff_remove_knockback"))
			_: pass

func on_debuff_apply_slow(_slow_percent: float) -> void:
	slow_percent = _slow_percent

func on_debuff_remove_slow() -> void:
	slow_percent = 0.0

func on_debuff_apply_freeze() -> void:
	is_frozen = true

func on_debuff_remove_freeze() -> void:
	is_frozen = false

func on_debuff_apply_stun() -> void:
	is_stunned = true

func on_debuff_remove_stun() -> void:
	is_stunned = false

func on_debuff_apply_burn(_value, _element) -> void:
	take_damage(_value, _element)

func on_debuff_remove_burn(_debuff: Debuff) -> void:
	_debuff.debuff_apply_burn.disconnect(on_debuff_apply_burn)
	_debuff.debuff_remove_burn.disconnect(on_debuff_remove_burn)

func on_debuff_apply_weaken(_value) -> void:
	weaken_percent = _value

func on_debuff_remove_weaken() -> void:
	weaken_percent = 0.0

func on_debuff_apply_knockback(_value) -> void:
	var tween: Tween = get_tree().create_tween()
	var progress_target: float = max(0, path_follow.progress - _value)
	var _knockback_tween_speed: float = .3
	tween.tween_property(path_follow, "progress", progress_target, _knockback_tween_speed)

func on_debuff_remove_knockback() -> void:
	pass

# Boons
func on_boon_connected(new_boon: Boon) -> void:
	new_boon.boon_triggered.connect(on_boon_triggered.bind(new_boon))
	boon_manager.add_boon(new_boon)

func on_boon_triggered(boon: Boon) -> void:
	match boon.type:
		Boon.Type.HEAL:
			if (health + boon.value) > max_health: health = max_health
			else:
				health += boon.value
