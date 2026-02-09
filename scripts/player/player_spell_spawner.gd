class_name PlayerSpellSpawner
extends Node

@onready var player: PlayerCharacter = get_owner()

var spell_spawn_points: Array[Node2D] # Set by PlayerCharacter
var melee_spell_spawn_points: Array[Node2D] 
var shield_spell_spawn_points: Array[Node2D]
 
var spell_func: Callable = Callable(parent_spawn_bullet_spell)

var can_attack: bool = true
var attack_timer: Timer = Timer.new()

var spell_scenes: Dictionary[SpellData.Type, PackedScene] = {
	SpellData.Type.BULLET: preload("res://scenes/Spells/SpellBullet.tscn"), 
	SpellData.Type.BULLET_AOE: preload("res://scenes/Spells/SpellBulletAOE.tscn"),
	SpellData.Type.MELEE_BULLET: preload("res://scenes/Spells/SpellBullet.tscn"), ## TODO: Make the spell data provide these scenes
	SpellData.Type.MELEE: preload("res://scenes/Spells/SpellMelee.tscn"),
	SpellData.Type.BULLET_CHARGED: preload("res://scenes/Spells/SpellBulletCharged.tscn"),
	SpellData.Type.SHIELD_DIRECTIONAL: preload("res://scenes/Spells/SpellShield.tscn")
}

var curr_spell_data: SpellData
var curr_spell_is_melee: bool = false
var spread_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var free_cast_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var double_spell_mana_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var perk_debuff_rng: RandomNumberGenerator = RandomNumberGenerator.new()

var spell_element_damage_perk_modifier: Dictionary[Constants.Element, float] = {
	Constants.Element.FIRE: 1.0,
	Constants.Element.WIND: 1.0,
	Constants.Element.WATER: 1.0,
	Constants.Element.EARTH: 1.0,
	Constants.Element.LIGHT: 1.0,
	Constants.Element.DARK: 1.0,
	Constants.Element.ARCANE: 1.0,
}

var spell_element_cooldown_perk_modifier: Dictionary[Constants.Element, float] = {
	Constants.Element.FIRE: 0.0,
	Constants.Element.WIND: 0.0,
	Constants.Element.WATER: 0.0,
	Constants.Element.EARTH: 0.0,
	Constants.Element.LIGHT: 0.0,
	Constants.Element.DARK: 0.0,
	Constants.Element.ARCANE: 0.0,
}

var spell_element_free_cast_perk_modifier: Dictionary[Constants.Element, float] = {
	Constants.Element.FIRE: 0.0,
	Constants.Element.WIND: 0.0,
	Constants.Element.WATER: 0.0,
	Constants.Element.EARTH: 0.0,
	Constants.Element.LIGHT: 0.0,
	Constants.Element.DARK: 0.0,
	Constants.Element.ARCANE: 0.0,
}

## DebuffData to apply and chance to pass on to spell
var perk_debuffs: Dictionary[DebuffData, float] = {
	preload("res://data/debuffs/perk_debuffs/debuff_data_knockback_perk.tres"): 0.0,
	preload("res://data/debuffs/perk_debuffs/debuff_data_slow_perk.tres"): 0.0,
	preload("res://data/debuffs/perk_debuffs/debuff_data_burn_perk.tres"): 0.0,
	preload("res://data/debuffs/perk_debuffs/debuff_data_weaken_perk.tres"): 0.0,
	preload("res://data/debuffs/perk_debuffs/debuff_data_freeze_perk.tres"): 0.0,
	preload("res://data/debuffs/perk_debuffs/debuff_data_stun_perk.tres"): 0.0,
}

var spell_execution_threshold: float = 0.0
var double_spell_mana_drop_chance: float = 0.0

signal spell_cast
signal staff_switched
signal melee_spell_cast # Just used to call the swing sword function; not for mana data
signal check_can_afford_failed
signal spell_damage_dealt

func _ready():
	attack_timer.autostart = false
	attack_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	attack_timer.timeout.connect(on_attack_timer_timeout)
	add_child(attack_timer)
	initialize_perk_debuffs()

func set_active_spell(_active_spell_data: SpellData) -> void:
	curr_spell_data = _active_spell_data
	spell_func = get_spell_func(curr_spell_data.type)

## Wrapper for the `spell_func` Callable. Used as an easy interface for other scripts to call.
func spawn_spell(player_aim_direction: Vector2, spell_data: SpellData) -> void:
	if can_attack:
		can_attack = false
		if check_can_afford(spell_data):
			spell_func.call(player_aim_direction.normalized(), spell_data)
		else:
			check_can_afford_failed.emit()
			start_attack_cooldown(spell_data)

func on_switch_spell(new_spell_data: SpellData) -> void:
	curr_spell_data = new_spell_data
	# Update spell_func()
	spell_func = get_spell_func(curr_spell_data.type)
	# Update staff
	staff_switched.emit(curr_spell_data) # this could move to player_spells.gd

func get_spell_func(_spell_type: SpellData.Type) -> Callable:
	match _spell_type:
		SpellData.Type.BULLET: 
			curr_spell_is_melee = false
			return parent_spawn_bullet_spell
		SpellData.Type.BULLET_AOE: 
			curr_spell_is_melee = false
			return parent_spawn_bullet_spell
		# SpellData.Type.BULLET_CHARGED:
		# 	curr_spell_is_melee = false
		# 	return spawn_bullet_spell_charged
		SpellData.Type.MELEE: 
			curr_spell_is_melee = true
			return spawn_melee_spell

		SpellData.Type.MELEE_BULLET:
			curr_spell_is_melee = true
			return parent_spawn_melee_bullet_spell

		SpellData.Type.SHIELD_DIRECTIONAL:
			curr_spell_is_melee = false
			return spawn_shield_spell
		SpellData.Type.EMPTY:
			curr_spell_is_melee = false
			return spawn_empty_spell
		_: 
			push_error("Unknown spell type")
			curr_spell_is_melee = false
			return parent_spawn_bullet_spell

## Spawn all bullets defined in the SpellDataBullet resource
func parent_spawn_bullet_spell(player_aim_direction: Vector2, active_spell_data: SpellData, spell_data_mana_key=null, consume_mana: bool=true) -> void:
	if not spell_data_mana_key:
		spell_data_mana_key = active_spell_data

	var new_spell_data: SpellDataBullet = active_spell_data
	var new_spell_scene: PackedScene = spell_scenes[new_spell_data.type]

	var angle_seperation: float = 0
	var angle_sign: float = 1.0

	# Spawn initial center bullet
	spawn_bullet_spell(player_aim_direction, new_spell_data, new_spell_scene, angle_seperation, angle_sign)
	angle_seperation += new_spell_data.angle_seperation

	# Stuff that is done 1 time for all bullets in this burst group

	if new_spell_data.sound_effect:
		AudioManager.create_2d_audio_at_location(spell_spawn_points[0].global_position, new_spell_data.sound_effect.type)

	start_attack_cooldown(new_spell_data)
	player.player_camera.apply_shake(new_spell_data.camera_shake)

	for i in range(new_spell_data.num_bullets - 1):
		spawn_bullet_spell(player_aim_direction, new_spell_data, new_spell_scene, angle_seperation, angle_sign)

		if i % 2 == 1:
			angle_seperation += new_spell_data.angle_seperation
		angle_sign = -angle_sign
	player.velocity_bonus_kickback = active_spell_data.kickback_power * -player_aim_direction
	spell_cast.emit(spell_data_mana_key, consume_mana)

## Spawn a single spell bullet
func spawn_bullet_spell(player_aim_direction: Vector2, new_spell_data: SpellDataBullet, new_spell_scene: PackedScene, angle_seperation: float, angle_sign: float) -> void:
	for spell_spawn_point: Node2D in spell_spawn_points:
		var new_spell: SpellBullet = new_spell_scene.instantiate()
		new_spell.global_position = spell_spawn_point.global_position
		new_spell.z_index = player.z_index + 2
		var angle = spread_rng.randf_range(-new_spell_data.spread, new_spell_data.spread) + angle_seperation * angle_sign
		add_child(new_spell)

		new_spell.initialize(new_spell_data, player_aim_direction.normalized().rotated(deg_to_rad(angle)), 
		spell_element_damage_perk_modifier[new_spell_data.element], spell_execution_threshold, 
		check_should_drop_double_spell_mana(), get_perk_debuffs())

		new_spell.damage_dealt.connect(on_spell_damage_dealt)

func spawn_melee_spell(_player_aim_direction: Vector2, active_spell_data: SpellData, spell_data_mana_key=null, consume_mana: bool=true) -> void:
	if not spell_data_mana_key:
		spell_data_mana_key = active_spell_data

	var new_spell_data: SpellDataMelee = active_spell_data


	var new_spell_scene: PackedScene
	if new_spell_data.melee_spell_scene:
		new_spell_scene = new_spell_data.melee_spell_scene
	else:
		new_spell_scene = spell_scenes[new_spell_data.type]

	for melee_spell_spawn_point: Node2D in melee_spell_spawn_points:
		var new_spell: Spell = new_spell_scene.instantiate()

		new_spell.initialize(new_spell_data, player, spell_element_damage_perk_modifier[new_spell_data.element], 
		spell_execution_threshold, check_should_drop_double_spell_mana(), get_perk_debuffs())

		new_spell.global_position = melee_spell_spawn_point.global_position + (_player_aim_direction * 16)
		new_spell.rotation = _player_aim_direction.angle()

		new_spell.z_index = player.z_index + 2
		add_child(new_spell)
		new_spell.damage_dealt.connect(on_spell_damage_dealt)
		spell_cast.emit(spell_data_mana_key, consume_mana)

	if new_spell_data.sound_effect:
		AudioManager.create_2d_audio_at_location(spell_spawn_points[0].global_position, new_spell_data.sound_effect.type)

	start_attack_cooldown(new_spell_data)
	player.player_camera.apply_shake(curr_spell_data.camera_shake)
	player.velocity_bonus_melee_dash = active_spell_data.melee_dash_power * _player_aim_direction
	player.velocity_bonus_kickback = active_spell_data.kickback_power * -_player_aim_direction
	melee_spell_cast.emit()

func parent_spawn_melee_bullet_spell(player_aim_direction: Vector2, active_spell_data: SpellData) -> void:

	# TODO: just go back to creating 2 nested data inside melee_bullet; one for the melee and one for the bullet. Then pull from
	# them and pass the mana_spell_key thing like currently doing

	var spell_data_melee: SpellDataMelee = SpellDataMelee.new()
	# spell_data_melee.atlas = active_spell_data.melee_atlas
	spell_data_melee.melee_spell_scene = active_spell_data.melee_spell_scene
	spell_data_melee.sfx = active_spell_data.melee_sfx
	spell_data_melee.type = active_spell_data.type
	# spell_data_melee.staff_type = active_spell_data.staff_type
	spell_data_melee.element = active_spell_data.element
	spell_data_melee.damage = active_spell_data.melee_damage
	spell_data_melee.cooldown = active_spell_data.cooldown
	spell_data_melee.debuff_data = active_spell_data.debuff_data
	spell_data_melee.base_spell_mana_per_drop = active_spell_data.base_spell_mana_per_drop
	spell_data_melee.initial_mana_amount = active_spell_data.initial_mana_amount
	spell_data_melee.max_mana_amount = active_spell_data.max_mana_amount
	spell_data_melee.mana_drop_chance = active_spell_data.mana_drop_chance
	spell_data_melee.mana_cost = active_spell_data.mana_cost
	spell_data_melee.mana_base_cost = active_spell_data.mana_base_cost
	spell_data_melee.spell_name = active_spell_data.spell_name
	spell_data_melee.popup_name = active_spell_data.popup_name
	spell_data_melee.desc = active_spell_data.desc
	spell_data_melee.active_icon = active_spell_data.active_icon
	spell_data_melee.inactive_icon = active_spell_data.inactive_icon
	spell_data_melee.staff_texture = active_spell_data.staff_texture
	spell_data_melee.sound_effect = active_spell_data.sound_effect
	spell_data_melee.camera_shake = active_spell_data.camera_shake
	spell_data_melee.unlock_cost = active_spell_data.unlock_cost
	spell_data_melee.kickback_power = 0
	spell_data_melee.melee_dash_power = 0

	spawn_melee_spell(player_aim_direction, spell_data_melee, active_spell_data)

	var spell_data_bullet: SpellDataBullet = SpellDataBullet.new()
	spell_data_bullet.atlas = active_spell_data.bullet_atlas
	spell_data_bullet.sfx = active_spell_data.bullet_sfx
	spell_data_bullet.type = active_spell_data.type
	# spell_data_bullet.staff_type = active_spell_data.staff_type
	spell_data_bullet.element = active_spell_data.element
	spell_data_bullet.damage = active_spell_data.bullet_damage
	spell_data_bullet.speed = active_spell_data.speed
	spell_data_bullet.num_bullets = active_spell_data.num_bullets
	spell_data_bullet.angle_seperation = active_spell_data.angle_seperation
	spell_data_bullet.max_distance = active_spell_data.max_distance
	spell_data_bullet.pierce = active_spell_data.pierce
	spell_data_bullet.cooldown = active_spell_data.cooldown
	spell_data_bullet.debuff_data = active_spell_data.debuff_data
	spell_data_bullet.base_spell_mana_per_drop = active_spell_data.base_spell_mana_per_drop
	spell_data_bullet.initial_mana_amount = active_spell_data.initial_mana_amount
	spell_data_bullet.max_mana_amount = active_spell_data.max_mana_amount
	spell_data_bullet.mana_drop_chance = active_spell_data.mana_drop_chance
	spell_data_bullet.mana_cost = active_spell_data.mana_cost
	spell_data_bullet.mana_base_cost = active_spell_data.mana_base_cost
	spell_data_bullet.spell_name = active_spell_data.spell_name
	spell_data_bullet.popup_name = active_spell_data.popup_name
	spell_data_bullet.desc = active_spell_data.desc
	spell_data_bullet.active_icon = active_spell_data.active_icon
	spell_data_bullet.inactive_icon = active_spell_data.inactive_icon
	spell_data_bullet.staff_texture = active_spell_data.staff_texture
	spell_data_bullet.sound_effect = active_spell_data.sound_effect
	spell_data_bullet.camera_shake = active_spell_data.camera_shake
	spell_data_bullet.unlock_cost = active_spell_data.unlock_cost
	spell_data_bullet.kickback_power = active_spell_data.kickback_power
	spell_data_bullet.melee_dash_power = active_spell_data.melee_dash_power

	parent_spawn_bullet_spell(player_aim_direction, spell_data_bullet, active_spell_data, false)

func spawn_shield_spell(_player_aim_direction: Vector2, active_spell_data: SpellData, spell_data_mana_key=active_spell_data, consume_mana: bool=true) -> void:
	var new_spell_data: SpellDataShieldDirectional = active_spell_data
	var new_spell_scene: PackedScene = spell_scenes[new_spell_data.type]

	for shield_spell_spawn_point: Node2D in shield_spell_spawn_points:
		var new_spell: SpellShield = new_spell_scene.instantiate()
		new_spell.data = curr_spell_data

		new_spell.z_index = player.z_index + 2 # TODO: ?
		add_child(new_spell)
		new_spell.initialize(curr_spell_data, shield_spell_spawn_point)

		new_spell.global_position = shield_spell_spawn_point.global_position
		new_spell.rotation = _player_aim_direction.angle()
		new_spell.player_aim = player.player_aim
		new_spell.damage_dealt.connect(on_spell_damage_dealt)
		spell_cast.emit(spell_data_mana_key, consume_mana)

	start_attack_cooldown(new_spell_data)
	player.player_camera.apply_shake(curr_spell_data.camera_shake)
	player.jump_forward()
	# melee_spell_cast.emit()

func start_attack_cooldown(_spell_data: SpellData) -> void:
	var _cooldown: float = _spell_data.cooldown - (_spell_data.cooldown * spell_element_cooldown_perk_modifier[_spell_data.element])
	attack_timer.start(_cooldown)

func on_attack_timer_timeout() -> void:
	can_attack = true

func check_can_afford(new_spell_data: SpellData) -> bool:
	if new_spell_data.type != SpellData.Type.EMPTY:
		# var mana_cost: float = new_spell_data.mana_cost * spell_element_cost_perk_modifier[new_spell_data.element]
		if new_spell_data.mana_cost <= player.player_mana.spell_mana[new_spell_data]:
			return true
		else:
			return false
	else:
		return false

func check_should_drop_double_spell_mana() -> bool:
	return double_spell_mana_rng.randf() < double_spell_mana_drop_chance

func get_perk_debuffs() -> Array[DebuffData]:
	var res: Array[DebuffData] = []
	for debuff_data: DebuffData in perk_debuffs.keys():
		if perk_debuff_rng.randf() < perk_debuffs[debuff_data]:
			res.append(debuff_data)
	return res

func on_spell_damage_dealt(damage_amount: float) -> void:
	spell_damage_dealt.emit(damage_amount)

func spawn_empty_spell(_player_aim_direction: Vector2) -> void:
	pass

func initialize_perk_debuffs() -> void:
	for debuff_data: DebuffData in perk_debuffs:
		var _value = debuff_data.get("value")
		if _value:
			debuff_data.modified_value = _value

# func spawn_bullet_spell_charged(_player_aim_direction: Vector2) -> void:
# 	var charge_value = min(100, player.player_input.primary_action_charge)
# 	var new_spell_data: SpellDataBullet = curr_spell_data.duplicate()
# 	var new_spell_scene: PackedScene = spell_scenes[new_spell_data.type]

# 	new_spell_data.speed = new_spell_data.speed * charge_value

# 	spawn_bullet_spell(_player_aim_direction, new_spell_data, new_spell_scene, 0, 1)

# func apply_spell_kick(kick_amount: float) -> void:
# 	print("applying kick")
# 	player.velocity += -player.aim_input * kick_amount
