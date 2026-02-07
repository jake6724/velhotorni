class_name Enemy
extends Area2D

enum Size {SMALL, LARGE, FLYING_SMALL, FLYING_LARGE, RANGED_SMALL, RANGED_LARGE, REPEATER_SMALL, REPEATER_LARGE, DUMMY_SMALL, SNAKE}

@export var data: EnemyData

# Child references
@onready var sprite: Sprite2D = $Sprite2D
@onready var light: Sprite2D = $Light
@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var shield: Sprite2D = $Shield
@onready var weak: Sprite2D = $Weak
@onready var debuff_manager: DebuffManager = $DebuffManager
@onready var boon_area: BoonArea = $BoonArea
@onready var boon_collider: CollisionShape2D = $BoonArea/BoonCollider
@onready var boon_manager: BoonManager = $BoonManager
@onready var boon_receive_area: Area2D = $BoonReceiveArea
@onready var boon_receive_collider: CollisionShape2D = $BoonReceiveArea/BoonReceiveCollider
@onready var hex_area: HexArea = $HexArea
@onready var hex_collider: CollisionShape2D = $HexArea/HexCollider
@onready var indicator: EnemyIndicator = $EnemyIndicator
@onready var number_popup: NumberPopup = %NumberPopup

@onready var enemy_movement: EnemyMovement = $EnemyMovement

@onready var fx_burn: AnimatedSprite2D = $Sprite2D/FXBurn
@onready var fx_weaken: AnimatedSprite2D = $Sprite2D/FXWeaken
@onready var fx_speed: AnimatedSprite2D = $Sprite2D/FXSpeed
@onready var fx_stun: AnimatedSprite2D = $Sprite2D/FXStun
@onready var fx_heal: AnimatedSprite2D = $Sprite2D/FXHeal
@onready var fx_prevent: AnimatedSprite2D = $Sprite2D/FXPrevent
@onready var fx_freeze: AnimatedSprite2D = $Sprite2D/FXFreeze
@onready var fx_cleanse: AnimatedSprite2D = $Sprite2D/FXCleanse
@onready var fx_slow: AnimatedSprite2D = $Sprite2D/FXSlow

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

var damage: int
var negative_modifier: float = .75
var positive_modifier: float = 2.0

var is_alive: bool = true
var is_taking_damage = false
var winding_up: bool = false

var base: Base

var is_boss: bool = false

# Debuffs
var slow_percent: float = 0.0
var weaken_percent: float = 0.0
var is_frozen: bool = false
var is_stunned: bool = false

var drop_chance: float # data.drop_chance_base + drop_chance_bonus passed by bullet
var spell_mana_drop_chance: float

@onready var knockback_tween: Tween

const EXECUTION_POPUP_VALUE: int = 999

# Signals
signal died # Pass ref to the enemy object
signal death_position # Pass global_position
signal coin_dropped
signal enemy_damage_recieved
signal wind_up_completed

func _ready():
	data.resource_local_to_scene = true # TODO: probably/maybe not needed
	element = data.element
	strong_against_element = data.strong_against_element
	weak_against_element = data.weak_against_element 
	health = data.health
	speed = data.speed
	damage = data.damage
	atlas = data.atlas
	max_health = health
	base = LevelManager.active_level.base # TODO: This is potentially bad; a collision box with layer that can only see base would be better ? 
	sprite.texture = atlas
	ap.animation_finished.connect(on_animation_finished)
	light.visible = data.show_light
	drop_chance = data.tower_mana_drop_chance_base
	spell_mana_drop_chance = data.element_mana_drop_chance

	set_pos_offset()

	z_as_relative = false

	# Configure DebuffManager
	debuff_manager.add_new_debuff.connect(on_add_new_debuff)
	debuff_manager.knockback_multiplier = data.knockback_multiplier

	# Configure Boons
	if data.boon_data:
		boon_area.initialize(data.boon_data)
		boon_area.owner = self
		# indicator.can_show_boon_range = true
	boon_manager.boon_connected.connect(on_boon_connected)

	# Configure Hexes
	if data.hex_data_list and data.hex_data_list[0]:
		hex_area.hex_data_list = data.hex_data_list
		hex_area.initialize()
		# indicator.can_show_hex_range = true

	# Configure EnemyMovement
	enemy_movement.animation_requested.connect(on_animation_requested)
	enemy_movement.sprite_flip_requested.connect(on_sprite_flip_requested)
	enemy_movement.damage_base_requested.connect(on_damage_base_requested)
	enemy_movement.death_requested.connect(on_death_requested)

	# Configure z_indexes
	health_bar.z_index = Constants.z_index_map["enemy_healthbar"]

func _physics_process(delta):
	if is_alive:
		move(delta)

func move(delta) -> void:
	if not winding_up:
		if is_alive:
			if not is_frozen and not is_stunned:
				if not is_taking_damage:
					ap.play("walk")

				sprite.flip_h = path_follow.rotation_degrees >= 91
					
				if path_follow.progress_ratio < .99:
					path_follow.progress += (speed - ((speed * (slow_percent/100)))) * delta
				else:
					base.take_damage(damage)
					die()
			else:
				ap.play("idle")

	debuff_manager.enemy_progress = path_follow.progress

func apply_drop_chance_bonus(_drop_chance_bonus: float) -> void:
	drop_chance = data.tower_mana_drop_chance_base + _drop_chance_bonus
	
func reset_drop_chance() -> void:
	drop_chance = data.tower_mana_drop_chance_base

## Reduce enemies `health` stat by `damage_recieved`. Return `true` if enemy died, `false` otherwise.
## Handles despawning enemy in the case of death.
## Returns the amount of damage actually received (after calculating resistances and other modifiers)
func take_damage(damage_recieved: float, tower_element: Constants.Element, execution_threshold_recieved: float, _double_spell_mana_drop: bool) -> float:
	if is_alive:
		is_taking_damage = true
		ap.play("hit")
		AudioManager.create_2d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.BULLET_IMPACT_FLESH)
		# Hit by same element
		if tower_element == data.element:
			damage_recieved *= negative_modifier

		if not health_bar.is_visible():
			health_bar.show()

		# Apply Weaken modifier
		damage_recieved = damage_recieved + (damage_recieved * (weaken_percent/100))
		number_popup.display_damage_number(damage_recieved, global_position)

		var damage_applied: float = min(health, damage_recieved)

		health = max(0, health - damage_recieved)

		if is_boss: enemy_damage_recieved.emit(damage_recieved)
		if health <= 0:
			if _double_spell_mana_drop:
				spell_mana_drop_chance *= 2
			die()
		# Check if should execute
		elif (health / max_health) <= execution_threshold_recieved:
			if _double_spell_mana_drop:
				spell_mana_drop_chance *= 2
			die()

		return damage_applied
	else:
		return 0

func die() -> void:
	is_alive = false
	# Update immediatedly required death properties
	died.emit(self)
	death_position.emit(global_position)
	coin_dropped.emit(global_position, drop_chance)

	collider.set_deferred("disabled", true) 
	debuff_manager.remove_all_debuffs()

	# Hide graphics
	health_bar.hide()
	shield.hide()
	weak.hide()
	z_index = Constants.z_index_map["enemy_corpse"]

	# SFXPlayer.play_sfx_resource(data.explosion_sfx)
	AudioManager.create_2d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.ENEMY_DEATH_FLESH)
	ap.play("die")

	light.visible = false

	# Give time for collision boons and hexes to be removed
	boon_collider.set_deferred("disabled", true)
	indicator.can_show_boon_range = false
	hex_collider.set_deferred("disabled", true)
	indicator.can_show_hex_range = false
	await get_tree().create_timer(.1).timeout

	hide_all_fx() # Somehow, the burn fx can turn back on. The debuff not seem to be active, just the fx. Ensure it is off

func on_animation_finished(anim_name):
	if anim_name == "hit":
		is_taking_damage = false

	if anim_name == "die":
		sprite.z_index = -sprite.z_index
		ap.play("corpse")

	if anim_name == "corpse":
		set_physics_process(false)
		# queue_free()

# Child component signal requests
func on_animation_requested(anim_name: String) -> void:
	ap.play(anim_name)

func on_animation_queue_requested(anim_name: String) -> void:
	ap.queue(anim_name)

func on_sprite_flip_requested(flip: bool) -> void:
	sprite.flip_h = flip

func on_damage_base_requested() -> void:
	base.take_damage(damage)

func on_death_requested() -> void:
	die()

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
	if is_alive:
		slow_percent = _slow_percent
		fx_slow.show()
		fx_slow.play("slow")

func on_debuff_remove_slow() -> void:
	slow_percent = 0.0
	fx_slow.hide()
	fx_slow.stop()

func on_debuff_apply_freeze() -> void:
	if is_alive:
		is_frozen = true
		fx_freeze.show()
		fx_freeze.play("start_freeze")

func on_debuff_remove_freeze() -> void:
	is_frozen = false
	is_taking_damage = false
	debuff_manager.start_cc_cooldown(Debuff.Type.FREEZE)
	fx_freeze.play("end_freeze")
	await fx_freeze.animation_finished
	fx_freeze.hide()

func on_debuff_apply_stun() -> void:
	if is_alive:
		is_stunned = true
		fx_stun.show()
		fx_stun.play("stun")

func on_debuff_remove_stun() -> void:
	is_stunned = false
	is_taking_damage = false
	debuff_manager.start_cc_cooldown(Debuff.Type.STUN)
	fx_stun.hide()
	fx_stun.stop()

func on_debuff_apply_burn(_value, _element) -> void:
	if is_alive:
		reset_drop_chance()
		take_damage(_value, _element, 0.0, false)
		fx_burn.show()
		fx_burn.play("burn")

func on_debuff_remove_burn(_debuff: Debuff) -> void:
	_debuff.debuff_apply_burn.disconnect(on_debuff_apply_burn)
	_debuff.debuff_remove_burn.disconnect(on_debuff_remove_burn)
	fx_burn.hide()
	fx_burn.stop()

	_debuff.can_burn = false
	_debuff.queue_free()

func on_debuff_apply_weaken(_value) -> void:
	if is_alive:
		weaken_percent = _value
		fx_weaken.show()
		fx_weaken.play("weaken")

func on_debuff_remove_weaken() -> void:
	weaken_percent = 0.0
	fx_weaken.hide()
	fx_weaken.stop()

func on_debuff_apply_knockback(_value, _total_duration) -> void:
	if is_alive:
		knockback_tween = create_tween()
		var progress_target: float = max(0, path_follow.progress - _value)
		knockback_tween.tween_property(path_follow, "progress", progress_target, _total_duration)

func on_debuff_remove_knockback() -> void:
	if knockback_tween:
		knockback_tween.stop()

func set_pos_offset() -> void:
	match data.size:
		Enemy.Size.SMALL: data.pos_offset = Vector2(8,8)
		Enemy.Size.LARGE: data.pos_offset = Vector2(8,8)

# Boons
func on_boon_connected(new_boon: Boon) -> void:
	if is_alive:
		new_boon.boon_triggered.connect(on_boon_triggered.bind(new_boon))
		new_boon.boon_expired.connect(on_boon_expired.bind(new_boon))
		boon_manager.add_boon(new_boon)

func on_boon_triggered(boon: Boon) -> void:
	match boon.type:
		Boon.Type.HEAL:
			if (health + boon.value) > max_health:
				health = max_health
			else:
				health += boon.value
			fx_heal.show()
			fx_heal.play("heal")
			await fx_heal.animation_finished
			fx_heal.hide()
		Boon.Type.SPEED: 
			speed += (data.speed * boon.value)
			fx_speed.show()
			fx_speed.play("speed")
		Boon.Type.DAMAGE:
			damage += boon.value
		Boon.Type.STEALTH:
			collider.set_deferred("disabled", true)
			sprite.modulate.a = .65
			death_position.emit(global_position)
		Boon.Type.CLEANSE:
			debuff_manager.remove_all_debuffs()
			fx_cleanse.show()
			fx_cleanse.play("cleanse")
			await fx_cleanse.animation_finished
			fx_cleanse.hide()
		Boon.Type.PREVENT:
			fx_prevent.show()
			fx_prevent.play("start_prevent")
			await fx_prevent.animation_finished
			fx_prevent.play("loop_prevent")
			debuff_manager.can_debuff = false
		_: pass

func on_boon_expired(boon: Boon) -> void:
	boon_manager.on_boon_expired(boon)
	match boon.type:
		Boon.Type.SPEED: 
			speed -= (data.speed * boon.value)
			if boon_manager.get_boon_count_by_type(Boon.Type.SPEED) <= 0:
				fx_speed.hide()
				fx_speed.stop()
		Boon.Type.DAMAGE:
			damage -= boon.value
			
		Boon.Type.CLEANSE: pass
		Boon.Type.PREVENT: 
			fx_prevent.play("end_prevent")
			await fx_prevent.animation_finished
			fx_prevent.hide()
			fx_prevent.stop()
			debuff_manager.can_debuff = true
		Boon.Type.STEALTH:
			sprite.modulate.a = 1
			collider.set_deferred("disabled", false)
		_: pass

func wind_up() -> void:
	pass
	# ap.play("wind_up")

func hide_all_fx() -> void:
	fx_burn.hide()
	fx_freeze.hide()
	fx_cleanse.hide()
	fx_heal.hide()
	fx_slow.hide()
	fx_slow.hide()
	fx_speed.hide()
	fx_stun.hide()
