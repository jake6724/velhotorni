class_name PlayerCharacter
extends CharacterBody2D

@export var player_data: PlayerData

# Components
@onready var player_movement: PlayerMovement = $PlayerMovement
@onready var player_aim: PlayerAim = $PlayerAim
@onready var player_animation: PlayerAnimation = $PlayerAnimation
@onready var player_input: PlayerInput = $PlayerInput
@onready var player_spells: PlayerSpells = $PlayerSpells
@onready var player_spell_spawner: PlayerSpellSpawner = $PlayerSpellSpawner
@onready var player_stats: PlayerCharacterStats = $PlayerCharacterStats
@onready var player_hurtbox: Area2D = %PlayerHurtbox
@onready var player_camera: PlayerCamera = %PlayerCamera
@onready var player_audio: PlayerAudio = %PlayerAudio
@onready var player_particles: GPUParticles2D = %PlayerParticles
@onready var player_build: PlayerBuild = $PlayerBuild
@onready var player_hud: PlayerHUD = %PlayerHUD
@onready var player_mana: PlayerMana = %PlayerMana
@onready var player_special: PlayerSpecial = %PlayerSpecial
@onready var player_number_popup: PlayerNumberPopup = %PlayerNumberPopup
@onready var player_perk_manager: PlayerPerkManager = %PlayerPerkManager
@onready var player_spell_perk_manager: PlayerSpellPerkManager = %PlayerSpellPerkManager
@onready var pit_hurtbox: PitHurtbox = %PitHurtbox
@onready var graphics_parent: Node2D = %GraphicsParent
@onready var player_hearts: HBoxContainer = %PlayerHearts
@onready var player_aoe: PlayerAOE = %PlayerAOE

@onready var character_sprite: Sprite2D = %CharacterSprite
@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var staff_sprite: StaffSprite = %StaffSprite
@onready var staff_ap: AnimationPlayer = $StaffAnimationPlayer
@onready var reticle_sprite: AnimatedSprite2D = %ReticleSprite
@onready var reticle_ammo: TextureProgressBar = %ReticleAmmo
# @onready var reticle_charge: TextureProgressBar = $ReticleSprite/ReticleCharge
@onready var spell_spawn_point: Node2D = %SpellSpawnPoint
@onready var coin_collector: CoinCollector = $CoinCollector
@onready var mana_drop_collector: ManaDropCollector = %ManaDropCollector
@onready var build_grid_sprite = $PlayerBuild/BuildGridSprite
@onready var special_bar_dash: Sprite2D = %SpecialBarDash
@onready var special_bar_clone: TextureProgressBar = %SpecialBarClone
@onready var special_charges_hide_timer: Timer = Timer.new()
@onready var tower_detect_area: Area2D = %TowerDetectArea
@onready var tower_detect_collider: CollisionShape2D = %TowerDetectCollider
@onready var upgrade_action_charge_cirlce: TextureProgressBar = %UpgradeActionChargeCircle
@onready var tower_action_hint: TowerActionHint = %TowerActionHint

@onready var player_build_ui: PlayerBuildUI = %PlayerBuildUI

var staff_texture: CompressedTexture2D = preload("res://assets/art/atlases/atl_player_mage_staff.png")
var reticle_ammo_texture: Texture2D = preload("res://assets/art/sprites/ui/reticle_ammo_progress.png")
var reticle_ammo_low_texture: Texture2D = preload("res://assets/art/sprites/ui/reticle_ammo_progress_low.png")

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

var hurtbox_reset_timer: Timer = Timer.new()

var building: bool = false
var primary_action_func: Callable = Callable(cast_spell)
var switch_action_func: Callable = Callable(switch_spell)
var switch_delay_timer: Timer = Timer.new()
var switch_delay: float = .25
var can_switch_mode: bool = true

var player_hearts_timer: Timer = Timer.new()
const DISPLAY_HEARTS_DURATION: float = 2

# Used to trigger the firing playerhud player portrait after a delay of PRIMARY_ACTION_TIMER_DELAY
var primary_action_timer: Timer = Timer.new()
const PRIMARY_ACTION_TIMER_DELAY: float = 2

signal player_respawned

## Used by PlayerClone
signal staff_switched
## Used by PlayerClone
signal spell_cast

func _ready():
	# Configure PlayerStats
	player_stats.load_player_data(player_data)

	# Connect to PlayerInput
	player_input.special_action_pressed.connect(on_special_input_pressed)
	player_input.switch_selection_pressed.connect(on_switch_selection_pressed)
	player_input.switch_player_mode_pressed.connect(on_switch_player_mode_pressed)
	player_input.switch_tower_action_pressed.connect(player_build.switch_tower_action.bind(player_input))
	player_input.ui_interact_pressed.connect(on_ui_interact_pressed)
	player_input.weapon_select_pressed.connect(on_weapon_select_pressed)
	player_input.primary_action_just_pressed.connect(func():primary_action_timer.start(PRIMARY_ACTION_TIMER_DELAY))
	player_input.primary_action_released.connect(on_primary_action_released)

	# Connect to GlobalSettings
	GlobalSettings.input_type_changed.connect(on_swap_input_type)

	# Configure PlayerSpellSpawner
	player_spell_spawner.set_active_spell(player_spells.active_spell)
	player_spells.active_spell_switched.connect(player_spell_spawner.on_switch_spell)
	player_spell_spawner.spell_spawn_points.append(spell_spawn_point)
	player_spell_spawner.melee_spell_spawn_points.append(self)
	player_spell_spawner.shield_spell_spawn_points.append(self)
	player_spell_spawner.spell_cast.connect(on_spell_cast)
	player_spell_spawner.staff_switched.connect(on_staff_switched)
	player_spell_spawner.check_can_afford_failed.connect(on_spell_cast_failed)

	# Configure PlayerSpecial
	player_special.camera_shake_requested.connect(player_camera.apply_shake)
	player_special.hurtbox_update_requested.connect(update_hurtbox_collider)
	player_special.special_charge_sprite_update_requested.connect(on_special_charge_sprite_update_requested)
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
	player_hurtbox.hit.connect(on_hit)
	player_hurtbox.reflect_chance = player_stats.reflect_chance
	player_stats.reflect_chance_updated.connect(player_hurtbox.on_reflect_chance_updated)
	player_hurtbox.camera_shake_requested.connect(player_camera.apply_shake)

	# Configure PitHurtbox
	pit_hurtbox.pit_entered.connect(on_pit_entered)
	
	# Configure PlayerMana
	player_mana.populate_spell_mana(player_spells.selected_spells)

	# Configure PlayerHUD
	player_hud.initialize(player_spells.spells.array, player_mana, player_stats, player_build)
	player_stats.health_updated.connect(player_hud.on_health_updated)
	WaveManager.wave_completed.connect(player_hud.blink_wave_complete)
	# WaveManager.wave_completed.connect(func(): coin_collector.magnet_collider.shape.radius *= 5)

	# Configure PlayerReticleAmmo
	player_hud.active_spell_mana_value_calculated.connect(update_reticle_ammo)

	# Configure PlayerBuild
	player_build.initialize(player_build_ui, build_grid_sprite, tower_detect_area, player_mana)
	player_build.tower_mana_spent.connect(on_tower_mana_spent)
	player_build.reset_tower_action.connect(on_reset_tower_action)
	player_build.tower_action_hint_requested.connect(on_tower_action_hint_requested)
	player_mana.tower_mana_updated.connect(player_build.on_tower_mana_updated)
	player_build.tower_action_changed.connect(tower_action_hint.display_tower_action_hint)

	# Connect to ManaDropCollector (SpellMana)
	mana_drop_collector.mana_drop_collected.connect(on_spell_mana_collected)

	# Connect to CoinCollector (Tower Mana)
	coin_collector.coin_collected.connect(on_tower_mana_collected)

	# Connect to PlayerLoadout
	PlayerLoadout.spell_loadout_updated.connect(on_spell_loadout_updated)
	PlayerLoadout.tower_loadout_updated.connect(on_tower_loadout_updated)

	# Configure Timers
	# Respawn Timer
	respawn_timer.autostart = false
	respawn_timer.one_shot = true
	respawn_timer.timeout.connect(respawn)
	add_child(respawn_timer)
	# Hurtbox Reset Timer
	hurtbox_reset_timer.autostart = false
	hurtbox_reset_timer.one_shot = true
	hurtbox_reset_timer.timeout.connect(on_hurtbox_reset_timer_timeout)
	add_child(hurtbox_reset_timer)
	# Switch Delay Timer
	switch_delay_timer.autostart = false
	switch_delay_timer.one_shot = true
	switch_delay_timer.timeout.connect(on_switch_delay_timer_timeout)
	add_child(switch_delay_timer)

	# Misc
	player_spell_spawner.melee_spell_cast.connect(player_aim.swing_staff)
	z_index = Constants.z_index_map["player_character"]
	reticle_sprite.z_index = Constants.z_index_map["reticle"]
	upgrade_action_charge_cirlce.z_index = Constants.z_index_map["top"]
	player_hearts_timer.one_shot = true
	player_hearts_timer.autostart = false
	add_child(player_hearts_timer)
	player_hearts_timer.timeout.connect(on_player_hearts_timer_timeout)
	primary_action_timer.one_shot = true
	primary_action_timer.autostart = false
	add_child(primary_action_timer)
	primary_action_timer.timeout.connect(on_primary_action_timer_timeout)


func _physics_process(delta): # This can go in a state eventually

	if alive:
		# Update Aim
		player_aim.update_aim(delta, player_input.get_aim_input())
		if not hit:
			if not player_special.active:
				# Update Movement
				velocity = player_movement.get_velocity(player_input.get_move_input(), player_stats.move_speed)
				player_animation.update_animation(delta)

		else: # Hit stun recovery
			velocity = player_movement.get_hitstun_velocity(delta, velocity, player_stats.hitstun_recovery_multiplier)
			# Check if hitstun complete
			if velocity == Vector2.ZERO:
				hit = false

		# Primary Action
		if player_input.primary_action_pressed:
			on_primary_action_pressed()

		if building:
			player_build.update_preview_tower_position(global_position, player_aim.aim_input)
			player_build.update_tower_detect_area_position()
			player_build.run(delta, player_input, upgrade_action_charge_cirlce)

		move_and_slide()

func on_primary_action_pressed() -> void:
	if alive and can_fire:
		primary_action_func.call()
		
func on_ui_interact_pressed() -> void:
	if alive and building:
		place_tower()

func cast_spell() -> void:
	player_spell_spawner.spawn_spell(player_aim.aim_input)

func place_tower() -> void:
	player_build.place_tower()
	player_input.primary_action_pressed = false

func on_spell_cast(spell_data) -> void:
	if player_spell_spawner.free_cast_rng.randf() > player_spell_spawner.spell_element_free_cast_perk_modifier[spell_data.element]:
		player_mana.decrement_spell_mana(spell_data)
		player_hud.update_mana(player_spells.spells.array, player_mana)

	staff_ap.play("fire")
	spell_cast.emit()
	
func on_spell_cast_failed() -> void:
	player_number_popup.display_mana_empty(global_position)

	player_hud.blink_no_mana_label()
	player_input.primary_action_pressed = false

func on_special_input_pressed() -> void:
	if not player_special.active:
		player_special.special(player_input.move_input, player_aim.aim_input)

func on_switch_selection_pressed(_switch_direction) -> void:
	switch_action_func.call(_switch_direction)

## `PlayerSpellSpawner` determines the next spell type based on player input in `PlayerSpellSpawner.switch_spell()`
## and then PlayerSpellSpawner returns this data via a signal connected to `PlayerCharacter.on_staff_switched()`
func switch_spell(_switch_direction: int) -> void:
	player_spells.switch_spells(_switch_direction)
	player_hud.update_spells(player_spells.spells.array)
	player_hud.update_mana(player_spells.spells.array, player_mana)

## Update the region of the staff atlas, changing the staff graphic. Plays the switch animation and temporarily hides
## the staff sprite. Prevents firing spells while switching.
func on_staff_switched(_spell_data: SpellData) -> void:
	# The switch animation modifies the atlas and texture, then resets the values. It must 
	# complete before a normal staff animation plays
	can_fire = false
	staff_ap.play("switch")
	await staff_ap.animation_finished
	can_fire = true
	player_aim.staff_rotation_offset_degrees = staff_sprite.switch_staff_texture(_spell_data)
	staff_switched.emit()

func switch_tower(_switch_direction: int) -> void:
	player_build.tower_index += _switch_direction
	player_build.remove_preview_tower()
	player_build.create_preview_tower()

## Switch between combat and building modes
func on_switch_player_mode_pressed() -> void: # TODO: Clean up, make functions
	if can_switch_mode:
		can_switch_mode = false
		building = !building

		player_aim.switch_mode(building)
		switch_delay_timer.start(switch_delay)

		if building: switch_to_build_mode()
		else: switch_to_combat_mode()

func switch_to_build_mode() -> void:
	primary_action_func = place_tower 
	switch_action_func = switch_tower
	staff_sprite.hide()
	player_build_ui.show()
	player_build_ui.raise_current()
	player_build.create_preview_tower()
	build_grid_sprite.show()
	# player_stats.active_speed = player_stats.build_speed
	tower_detect_collider.set_deferred("disabled", false)
	reticle_sprite.hide()
	reticle_ammo.hide()
	await get_tree().create_timer(.1).timeout
	reticle_sprite.play("build")
	reticle_sprite.show()

func switch_to_combat_mode() -> void:
	staff_sprite.show()
	primary_action_func = cast_spell
	switch_action_func = switch_spell
	if player_build.preview_tower:		# Remove preview tower
		player_build.preview_tower.queue_free()
	player_build_ui.hide()
	build_grid_sprite.hide()
	# player_stats.active_speed = player_stats.combat_speed
	tower_detect_collider.set_deferred("disabled", true)
	reticle_sprite.hide()
	await get_tree().create_timer(.05).timeout
	reticle_sprite.play("combat")
	reticle_sprite.show()
	reticle_ammo.show()

func on_animation_finished(anim_name) -> void:
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
		update_hurtbox_collider(true)
		velocity = _direction * player_stats.knockback_multiplier
		hurtbox_reset_timer.start(player_stats.hurtbox_iframe_duration)

		player_camera.apply_shake(1)
		TimeManager.apply_hitstop()
		hit_blink()

		display_hearts(player_stats.health)

		player_hud.set_player_portrait(player_stats.health, player_stats.max_health) # Called here because it needs max health data that PlayerHUD does not have

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
	player_hud.set_player_portrait(player_stats.health, player_stats.max_health)

func respawn() -> void:
	character_sprite.show()
	reticle_sprite.show()
	if not building: staff_sprite.show()
	global_position = spawn_point
	alive = true
	player_stats.health = player_stats.max_health
	update_hurtbox_collider(false)
	hurtbox_reset_timer.start(player_stats.hurtbox_iframe_duration)
	player_hud.set_player_portrait(player_stats.health, player_stats.max_health)
	player_respawned.emit()	
	hit_blink()

func hit_blink() -> void:
	var blink_time: float = .075
	var loops: int = player_stats.hurtbox_iframe_duration / blink_time
	var blink_tween: Tween = get_tree().create_tween().set_loops(loops/2) # Loops halved because you are waiting twice in the tween loop below
	blink_tween.tween_property(character_sprite, "modulate:a", 0.0, .01)
	blink_tween.tween_interval(blink_time)
	blink_tween.tween_property(character_sprite, "modulate:a", 1.0, .01)
	blink_tween.tween_interval(blink_time)

func on_hurtbox_reset_timer_timeout() -> void:
	update_hurtbox_collider(false)

func show_staff_sprite_custom(): 
	if alive and not building:
		staff_sprite.show()

func on_spell_mana_collected(spell_data: SpellData, _amount_modifier: float) -> void:
	var spell_mana_collected: int = player_mana.increment_spell_mana(spell_data, _amount_modifier)
	player_hud.update_mana(player_spells.spells.array, player_mana)
	# player_number_popup.display_mana_number(spell_mana_collected, global_position + Vector2(0,-6), spell_data)
	# player_number_popup.increase_up_distance()
	player_hud.add_spell_mana_popup(spell_data, spell_mana_collected)
	
func on_tower_mana_collected(_value: int = 1) -> void:
	player_mana.tower_mana += _value
	player_hud.update_tower_mana(player_mana)
	player_build_ui.update(player_mana)

func on_tower_mana_spent(_value) -> void:
	player_mana.tower_mana -= _value
	player_hud.update_tower_mana(player_mana)
	player_build_ui.update(player_mana)

func on_velocity_update_requested(new_velocity: Vector2) -> void:
	velocity = new_velocity

func update_hurtbox_collider(_value) -> void:
	player_hurtbox.collider.set_deferred("disabled", _value)
	pit_hurtbox.collider.set_deferred("disabled", _value)

func on_special_charge_sprite_update_requested(_charges: int) -> void:
	special_bar_dash.texture.region = Rect2(0, (4 - _charges) * 6, 24, 6)

	if _charges == player_stats.special_charges_max:
		special_charges_hide_timer.start(1)
	else:
		special_charges_hide_timer.stop()
		special_bar_dash.show()

func on_special_charges_hide_timer_timeout() -> void:
	special_bar_dash.hide()

func on_animation_requested(_anim_name: String) -> void:
	ap.play(_anim_name)

func on_switch_delay_timer_timeout() -> void:
	can_switch_mode = true

func jump_forward() -> void:
	pass

func on_reset_tower_action(_disable_press: bool) -> void:
	player_input.upgrade_action_charge = 0
	if _disable_press:
		player_input.upgrade_action_pressed = false

func on_tower_action_hint_requested(_value: bool) -> void:
	tower_action_hint.visible = _value

func on_swap_input_type() -> void:
	player_camera.swap_input_type()
	player_aim.swap_input_type()

func on_weapon_select_pressed(index: int) -> void:
	player_spells.switch_to_index(index)
	player_hud.update_spells(player_spells.spells.array)
	player_hud.update_mana(player_spells.spells.array, player_mana)

func update_reticle_ammo(_value: float) -> void:
	reticle_ammo.value = _value
	if _value <= player_mana.SPELL_MANA_LOW_THRESHOLD * 100:
		reticle_ammo.texture_progress = reticle_ammo_low_texture
	else:
		reticle_ammo.texture_progress = reticle_ammo_texture

func on_spell_loadout_updated() -> void:
	player_spells.configure_spells()
	player_mana.populate_spell_mana(player_spells.selected_spells)
	player_hud.on_spell_loadout_updated(player_spells.spells.array, player_mana)
	player_spell_spawner.set_active_spell(player_spells.active_spell)
	player_spell_spawner.on_switch_spell(player_spells.active_spell)

func on_tower_loadout_updated() -> void:
	player_build.loadout_updated()
	player_build_ui.update(player_mana)

func display_hearts(_health) -> void:
	player_hearts.show()
	for heart: PlayerHeart in player_hearts.get_children():
		if _health >= 2:
			heart.set_texture_full()
			_health -= 2

		elif _health == 1:
			heart.set_texture_half()
			_health -= 1

		else:
			heart.set_texture_empty()

	for heart: PlayerHeart in player_hearts.get_children():
		heart.flash()

	player_hearts_timer.start(DISPLAY_HEARTS_DURATION)

func on_player_hearts_timer_timeout() -> void:
	player_hearts.hide()

func on_primary_action_timer_timeout() -> void:
	player_hud.set_player_portrait_firing()

func on_primary_action_released() -> void:
	primary_action_timer.stop()
	player_hud.reset_player_portrait()
