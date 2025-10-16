class_name PlayerCharacter
extends CharacterBody2D

@export var data: PlayerData

# Components
@onready var player_movement: PlayerMovement = $PlayerMovement
@onready var player_aim: PlayerAim = $PlayerAim
@onready var player_animation: PlayerAnimation = $PlayerAnimation
@onready var player_input: PlayerInput = $PlayerInput
@onready var player_spells: PlayerSpells = $PlayerSpells
@onready var player_spell_spawner: PlayerSpellSpawner = $PlayerSpellSpawner
@onready var player_stats: PlayerCharacterStats = $PlayerCharacterStats
@onready var player_hurtbox: Area2D = $PlayerHurtbox
@onready var player_camera: PlayerCamera = %PlayerCamera
@onready var player_audio: PlayerAudio = %PlayerAudio
@onready var player_particles: GPUParticles2D = %PlayerParticles
@onready var player_build: PlayerBuild = $PlayerBuild
@onready var player_hud: PlayerHUD = %PlayerHUD
@onready var player_mana: PlayerMana = %PlayerMana
@onready var player_special: PlayerSpecial = %PlayerSpecial
@onready var player_number_popup: NumberPopup = %PlayerNumberPopup

@onready var character_sprite: Sprite2D = $CharacterSprite
@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var staff_sprite: Sprite2D = $StaffSprite
@onready var staff_ap: AnimationPlayer = $StaffAnimationPlayer
@onready var reticle_sprite: AnimatedSprite2D = $ReticleSprite
@onready var reticle_charge: TextureProgressBar = $ReticleSprite/ReticleCharge
@onready var spell_spawn_point: Node2D = %SpellSpawnPoint
@onready var coin_collector: CoinCollector = $CoinCollector
@onready var mana_drop_collector: ManaDropCollector = %ManaDropCollector
@onready var build_grid_sprite = $PlayerBuild/BuildGridSprite
@onready var special_charges_sprite: Sprite2D = %SpecialChargesSprite
@onready var special_charges_hide_timer: Timer = Timer.new()
@onready var tower_detect_area: Area2D = %TowerDetectArea
@onready var tower_detect_collider: CollisionShape2D = %TowerDetectCollider

@onready var player_build_ui: PlayerBuildUI = %PlayerBuildUI

var staff_texture: CompressedTexture2D = preload("res://assets/art/atlases/atl_player_mage_staff.png")

var alive: bool = true
var respawn_time: float = 1.0
var respawn_timer: Timer = Timer.new()
var respawn_iframe_duration: float = 3.0
var spawn_point: Vector2 = Vector2.ZERO # Set manually by main

var aim_input: Vector2
var prev_aim_input: Vector2

var falling: bool = false

var can_fire: bool = true
var hit: bool = false

var hitstun_recovery_multiplier: float = 300 # Influences how quickly the player stops sliding when hitstun and recovers back to normal mode
var hurtbox_iframe_duration: float = 1.0
var hurtbox_reset_timer: Timer = Timer.new()

var building: bool = false
var primary_action_func: Callable = Callable(cast_spell)
var switch_action_func: Callable = Callable(switch_spell)
var switch_delay_timer: Timer = Timer.new()
var switch_delay: float = .25
var can_switch_mode: bool = true

signal player_respawned

func _ready():
	# Connect to PlayerInput
	player_input.secondary_action_pressed.connect(on_dash_input_pressed)
	player_input.switch_selection_pressed.connect(on_switch_selection_pressed)
	player_input.switch_player_mode_pressed.connect(on_switch_player_mode_pressed)

	# Configure PlayerSpellSpawner
	player_spell_spawner.initialize(player_spells.active_spell)
	player_spells.active_spell_switched.connect(player_spell_spawner.on_switch_spell)
	player_spell_spawner.spell_spawn_point = spell_spawn_point
	player_spell_spawner.spell_cast.connect(on_spell_cast)
	player_spell_spawner.staff_switched.connect(on_staff_switched)
	player_spell_spawner.check_can_afford_failed.connect(on_spell_cast_failed)

	# Configure PlayerSpecial
	player_special.velocity_update_requested.connect(on_velocity_update_requested)
	player_special.camera_shake_requested.connect(player_camera.apply_shake)
	player_special.hurtbox_update_requested.connect(update_hurtbox_collider)
	player_special.special_charge_sprite_update_requested.connect(on_special_charge_sprite_update_requested)
	player_special.special_animation_requested.connect(on_animation_requested)
	special_charges_hide_timer.autostart = false
	special_charges_hide_timer.one_shot = true
	special_charges_hide_timer.timeout.connect(on_special_charges_hide_timer_timeout)
	add_child(special_charges_hide_timer)

	# Configure AnimationPlayers
	staff_ap.animation_finished.connect(on_staff_animation_finished)
	ap.animation_finished.connect(on_animation_finished)

	# Connect to AnimationTree
	player_animation.animation_tree.animation_finished.connect(on_animation_finished)

	# Configure PlayerHurtbox
	player_hurtbox.damage_recieved.connect(on_damage_recieved)
	player_hurtbox.hit.connect(on_hit)
	player_hurtbox.pit_entered.connect(on_pit_entered)
	
	# Configure PlayerHUD
	player_hud.initialize(player_spells.spells.array, player_mana, player_stats)
	player_stats.health_updated.connect(player_hud.on_health_updated)

	# Configure PlayerBuild
	player_build.initialize(player_build_ui, build_grid_sprite, tower_detect_area)
	player_build.tower_mana_spent.connect(on_tower_mana_spent)

	# Connect to ManaDropCollector
	mana_drop_collector.mana_drop_collected.connect(on_element_mana_collected)

	# Connect to CoinCollector (Tower Mana)
	coin_collector.coin_collected.connect(on_tower_mana_collected)

	# Configure Timers
	respawn_timer.autostart = false
	respawn_timer.one_shot = true
	respawn_timer.timeout.connect(respawn)
	add_child(respawn_timer)
	hurtbox_reset_timer.autostart = false
	hurtbox_reset_timer.one_shot = true
	hurtbox_reset_timer.timeout.connect(on_hurtbox_reset_timer_timeout)
	add_child(hurtbox_reset_timer)
	switch_delay_timer.autostart = false
	switch_delay_timer.one_shot = true
	switch_delay_timer.timeout.connect(on_switch_delay_timer_timeout)
	add_child(switch_delay_timer)

	# Misc
	player_spell_spawner.melee_spell_cast.connect(player_aim.swing_staff)
	z_index = Constants.z_index_map["player_character"]

# DEV ONLY
# func _process(delta):
# 	if player_input.primary_action_charge:
# 		reticle_charge.show()
# 		var value = min(100, player_input.primary_action_charge * 100)
# 		reticle_charge.value = value
# 	else:
# 		reticle_charge.hide()

func _physics_process(delta): # This can go in a state eventually
	if alive:
		# Update Aim
		player_aim.update_aim(delta, player_input.get_aim_input())
		if not hit:
			if not player_special.active:
				# Update Movement
				velocity = player_movement.get_velocity(player_input.get_move_input(), player_stats.active_speed)
				player_animation.update_animation(delta)

		else: # Hit stun recovery
			velocity = player_movement.get_hitstun_velocity(delta, velocity, hitstun_recovery_multiplier)
			# Check if hitstun complete
			if velocity == Vector2.ZERO:
				hit = false
				# Hurtbox is re-enable on hurtbox_reset_timer.timeout()

		# Primary Action
		if player_input.primary_action_pressed:
			on_primary_action_pressed()

		if building:
			player_build.update_preview_tower_position(global_position, player_aim.aim_input)
			player_build.update_tower_detect_area_position()

		move_and_slide()

func on_primary_action_pressed() -> void:
	if alive and can_fire:
		primary_action_func.call()

func cast_spell() -> void:
	player_spell_spawner.spawn_spell(player_aim.aim_input)

func place_tower() -> void:
	player_build.place_tower(player_mana.tower_mana)
	player_input.primary_action_pressed = false

func on_spell_cast(_element: Constants.Element, _mana_cost) -> void:
	player_mana.decrement_element_mana(_element, _mana_cost)
	player_hud.update_mana(player_spells.spells.array, player_mana)
	staff_ap.play("fire")

func on_spell_cast_failed() -> void:
	player_number_popup.display_mana_empty(global_position)
	player_hud.blink_no_mana_label()

func on_dash_input_pressed() -> void:
	if not player_special.active:
		player_special.special(player_input.move_input, player_aim.aim_input)

func on_switch_selection_pressed(_switch_direction) -> void:
	switch_action_func.call(_switch_direction)

## `PlayerSpellSpawner` determines the next spell type based on player input in `PlayerSpellSpawner.switch_spell()`
## and then returns this data via a signal connected to `PlayerCharacter.on_staff_switched()`
func switch_spell(_switch_direction: int) -> void:
	player_spells.switch_spells(_switch_direction)
	player_hud.update_spells(player_spells.spells.array)
	player_hud.update_mana(player_spells.spells.array, player_mana)

## Update the region of the staff atlas, changing the staff graphic. Plays the switch animation and temporarily hides
## the staff sprite. Prevents firing spells while switching.
func on_staff_switched(_spell_type: SpellData.Type) -> void:
	# The switch animation modifies the atlas and texture, then resets the values. It must 
	# complete before a normal staff animation plays
	can_fire = false
	staff_ap.play("switch")
	await staff_ap.animation_finished
	can_fire = true

	match _spell_type:
		SpellData.StaffType.ARCANE: 
			staff_sprite.texture.region = Rect2(0,0,217,15)
			player_aim.staff_rotation_offset_degrees = 0
			staff_sprite.position = Vector2(0, 5) 
			staff_sprite.offset = Vector2(4, 0.5) # TODO: Broke.

		SpellData.StaffType.FIRE_STAFF:
			staff_sprite.texture.region = Rect2(0,45,217,15)
			player_aim.staff_rotation_offset_degrees = 0
			staff_sprite.position = Vector2(0, 5) 
			staff_sprite.offset = Vector2(4, 0.5) # TODO: Broke.

		SpellData.StaffType.WATER_SWORD: 
			staff_sprite.texture.region = Rect2(0,15,217,15)
			player_aim.staff_rotation_offset_degrees = -120
			staff_sprite.offset = Vector2(8, .5)

		SpellData.StaffType.TRIPLE_STAFF: 
			staff_sprite.texture.region = Rect2(0,60,217,15)
			player_aim.staff_rotation_offset_degrees = -0
			staff_sprite.offset = Vector2(4, 0.5)

func switch_tower(_switch_direction: int) -> void:
	player_build.tower_index += _switch_direction
	player_build.preview_tower.queue_free()
	player_build.create_preview_tower()

## Switch between combat and building modes
func on_switch_player_mode_pressed() -> void: # TODO: Clean up, make functions
	if can_switch_mode:
		can_switch_mode = false
		building = !building
		if building:							# Switch to build mode
			primary_action_func = place_tower 
			switch_action_func = switch_tower
			staff_sprite.hide()
			player_build.create_preview_tower()
			player_build_ui.show()
			player_build_ui.raise_current()
			build_grid_sprite.show()
			player_stats.active_speed = player_stats.build_speed
			tower_detect_collider.set_deferred("disabled", false)
		else:								    # Switch to combat mode 
			staff_sprite.show()
			primary_action_func = cast_spell
			switch_action_func = switch_spell
			if player_build.preview_tower:		# Remove preview tower
				player_build.preview_tower.queue_free()
			player_build_ui.hide()
			build_grid_sprite.hide()
			player_stats.active_speed = player_stats.combat_speed
			tower_detect_collider.set_deferred("disabled", true)

		player_hud.animate_switch_mode(building)
		player_aim.switch_mode(building)
		switch_delay_timer.start(switch_delay)

func on_animation_finished(anim_name) -> void:
	# if anim_name == "dash":
	# 	player_special.active = false
	# 	update_hurtbox_collider(false)

	if anim_name == "fall":
		falling = false
		character_sprite.hide()
		respawn_timer.start(respawn_time)
		
	if anim_name == "die":
		respawn_timer.start(respawn_time)

func on_staff_animation_finished(_anim_name) -> void:
	if _anim_name == "switch":
		staff_ap.play("idle")

	if _anim_name == "fire":
		staff_ap.play("idle")

func on_damage_recieved(_damage) -> void:
	player_stats.health -= 1
	if player_stats.health < 0:
		die()

## Does not update health
func on_hit(_direction) -> void:
	_direction = Constants.get_closest_cardinal_direction_normalized(_direction)
	if not hit:
		hit = true
		player_stats.health -= 1
		if player_stats.health <= 0:
			modulate.a = 1
			die()
			return
			
		velocity = _direction * player_stats.knockback_multiplier
		update_hurtbox_collider(false)
		velocity = _direction * player_stats.knockback_multiplier
		hurtbox_reset_timer.start(hurtbox_iframe_duration)

		player_camera.apply_shake(1)
		TimeManager.apply_hitstop()
		hit_blink()

func jump_forward() -> void:
	pass

func on_pit_entered() -> void:
	global_position += player_input.move_input.normalized() * 10 # Move the character to be fully over the pit
	reticle_sprite.hide()
	staff_sprite.hide()
	falling = true
	alive = false

func die() -> void:
	reticle_sprite.hide()
	staff_sprite.hide()
	alive = false

func respawn() -> void:
	reticle_sprite.show()
	staff_sprite.show()
	character_sprite.show()
	global_position = spawn_point
	alive = true
	player_stats.health = player_stats.max_health
	player_hurtbox.collider.set_deferred("disabled", true)
	hurtbox_reset_timer.start(hurtbox_iframe_duration)
	player_respawned.emit()	
	hit_blink()

func hit_blink() -> void:
	var loops: int = 10
	var blink_time: float = (hurtbox_iframe_duration / loops) / 2
	var blink_tween: Tween = get_tree().create_tween().set_loops(loops)
	blink_tween.tween_property(self, "modulate:a", 0.0, .01)
	blink_tween.tween_interval(blink_time)
	blink_tween.tween_property(self, "modulate:a", 1.0, .01)
	blink_tween.tween_interval(blink_time)

func on_hurtbox_reset_timer_timeout() -> void:
	player_hurtbox.collider.set_deferred("disabled", false)

func show_staff_sprite_custom(): 
	if alive and not building:
		staff_sprite.show()

func on_element_mana_collected(_element: Constants.Element, _amount_modifier) -> void:
	player_mana.increment_element_mana(_element, _amount_modifier)
	player_hud.update_mana(player_spells.spells.array, player_mana)
	player_number_popup.display_mana_number(player_mana.element_drop_amount_base[_element] * _amount_modifier, global_position + Vector2(0,-6), _element)

func on_tower_mana_collected(_value: int = 1) -> void:
	player_mana.tower_mana += _value
	player_hud.update_tower_mana(player_mana)

func on_tower_mana_spent(_value) -> void:
	player_mana.tower_mana -= _value
	player_hud.update_tower_mana(player_mana)

func on_velocity_update_requested(new_velocity: Vector2) -> void:
	velocity = new_velocity

func update_hurtbox_collider(_value) -> void:
	player_hurtbox.collider.set_deferred("disabled", _value)

func on_special_charge_sprite_update_requested(_charges: int) -> void:
	special_charges_sprite.texture.region = Rect2(0, (3 - _charges) * 6, 24, 6)

	if _charges == player_special.charge_max:
		special_charges_hide_timer.start(1)
	else:
		special_charges_hide_timer.stop()
		special_charges_sprite.show()

func on_special_charges_hide_timer_timeout() -> void:
	special_charges_sprite.hide()

func on_animation_requested(_anim_name: String) -> void:
	ap.play(_anim_name)

func on_switch_delay_timer_timeout() -> void:
	can_switch_mode = true
