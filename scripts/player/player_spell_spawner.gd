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
	SpellData.Type.MELEE: preload("res://scenes/Spells/SpellMelee.tscn"),
	SpellData.Type.BULLET_CHARGED: preload("res://scenes/Spells/SpellBulletCharged.tscn"),
	SpellData.Type.SHIELD_DIRECTIONAL: preload("res://scenes/Spells/SpellShield.tscn")
}

var curr_spell_data: SpellData
var curr_spell_is_melee: bool = false
var spread_rng: RandomNumberGenerator = RandomNumberGenerator.new()

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

func initialize(_spell_data: SpellData) -> void:
	curr_spell_data = _spell_data
	spell_func = get_spell_func(curr_spell_data.type)

## Wrapper for the `spell_func` Callable. Used as an easy interface for other scripts to call.
func spawn_spell(player_aim_direction: Vector2) -> void:
	if can_attack:
		can_attack = false
		if check_can_afford(curr_spell_data):
			spell_func.call(player_aim_direction.normalized())
		else:
			check_can_afford_failed.emit()
			attack_timer.start(curr_spell_data.cooldown)

func on_switch_spell(new_spell_data: SpellData) -> void:
	curr_spell_data = new_spell_data
	# Update spell_func()
	spell_func = get_spell_func(curr_spell_data.type)
	# Update staff
	staff_switched.emit(curr_spell_data.staff_type) # this could move to player_spells.gd

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
		SpellData.Type.SHIELD_DIRECTIONAL:
			curr_spell_is_melee = false
			return spawn_shield_spell
		_: 
			push_error("Unknown spell type")
			curr_spell_is_melee = false
			return parent_spawn_bullet_spell

## Spawn all bullets defined in the SpellDataBullet resource
func parent_spawn_bullet_spell(player_aim_direction: Vector2) -> void:
	var new_spell_data: SpellDataBullet = curr_spell_data
	var new_spell_scene: PackedScene = spell_scenes[new_spell_data.type]

	var angle_seperation: float = 0
	var angle_sign: float = 1.0

	# Spawn initial center bullet
	spawn_bullet_spell(player_aim_direction, new_spell_data, new_spell_scene, angle_seperation, angle_sign)
	angle_seperation += new_spell_data.angle_seperation

	# Stuff that is done 1 time for all bullets in this burst group
	player.player_audio.play_audio_stream(new_spell_data.sfx)
	attack_timer.start(new_spell_data.cooldown)
	player.player_camera.apply_shake(new_spell_data.camera_shake)

	for i in range(new_spell_data.num_bullets - 1):
		spawn_bullet_spell(player_aim_direction, new_spell_data, new_spell_scene, angle_seperation, angle_sign)

		if i % 2 == 1:
			angle_seperation += new_spell_data.angle_seperation
		angle_sign = -angle_sign
		
	spell_cast.emit(new_spell_data)

## Spawn a single spell bullet
func spawn_bullet_spell(player_aim_direction: Vector2, new_spell_data: SpellDataBullet, new_spell_scene: PackedScene, angle_seperation: float, angle_sign: float) -> void:
	for spell_spawn_point: Node2D in spell_spawn_points:
		var new_spell: Spell = new_spell_scene.instantiate()
		new_spell.global_position = spell_spawn_point.global_position
		new_spell.z_index = player.z_index + 2
		var angle = spread_rng.randf_range(-new_spell_data.spread, new_spell_data.spread) + angle_seperation * angle_sign
		add_child(new_spell)
		new_spell.initialize(new_spell_data, player_aim_direction.normalized().rotated(deg_to_rad(angle)))
		new_spell.damage_dealt.connect(on_spell_damage_dealt)

func spawn_melee_spell(_player_aim_direction: Vector2) -> void:
	var new_spell_data: SpellDataMelee = curr_spell_data
	var new_spell_scene: PackedScene = spell_scenes[new_spell_data.type]

	for melee_spell_spawn_point: Node2D in melee_spell_spawn_points:
		var new_spell: Spell = new_spell_scene.instantiate()
		new_spell.initialize(new_spell_data, player)
		new_spell.global_position = melee_spell_spawn_point.global_position + (_player_aim_direction * 16)
		new_spell.rotation = _player_aim_direction.angle()

		new_spell.z_index = player.z_index + 2
		add_child(new_spell)
		new_spell.damage_dealt.connect(on_spell_damage_dealt)
		spell_cast.emit(new_spell_data)

	attack_timer.start(new_spell_data.cooldown)
	player.player_camera.apply_shake(curr_spell_data.camera_shake)
	player.jump_forward()
	melee_spell_cast.emit()

func spawn_shield_spell(_player_aim_direction: Vector2) -> void:
	var new_spell_data: SpellDataShieldDirectional = curr_spell_data
	var new_spell_scene: PackedScene = spell_scenes[new_spell_data.type]

	for shield_spell_spawn_point: Node2D in shield_spell_spawn_points:
		var new_spell: Spell = new_spell_scene.instantiate()
		new_spell.data = curr_spell_data

		new_spell.z_index = player.z_index + 2 # TODO: ?
		add_child(new_spell)
		new_spell.initialize(curr_spell_data, player)

		new_spell.global_position = shield_spell_spawn_point.global_position
		new_spell.rotation = _player_aim_direction.angle()

		new_spell.damage_dealt.connect(on_spell_damage_dealt)
		spell_cast.emit(new_spell_data)

	attack_timer.start(new_spell_data.cooldown)
	player.player_camera.apply_shake(curr_spell_data.camera_shake)
	player.jump_forward()
	# melee_spell_cast.emit()

func on_attack_timer_timeout() -> void:
	can_attack = true
	
func check_can_afford(new_spell_data: SpellData) -> bool:
	if new_spell_data.mana_cost <= player.player_mana.spell_mana[new_spell_data]:
		return true
	else:
		return false

# func apply_spell_kick(kick_amount: float) -> void:
# 	print("applying kick")
# 	player.velocity += -player.aim_input * kick_amount

func on_spell_damage_dealt(damage_amount: float) -> void:
	spell_damage_dealt.emit(damage_amount)


# func spawn_bullet_spell_charged(_player_aim_direction: Vector2) -> void:
# 	var charge_value = min(100, player.player_input.primary_action_charge)
# 	var new_spell_data: SpellDataBullet = curr_spell_data.duplicate()
# 	var new_spell_scene: PackedScene = spell_scenes[new_spell_data.type]

# 	new_spell_data.speed = new_spell_data.speed * charge_value

# 	spawn_bullet_spell(_player_aim_direction, new_spell_data, new_spell_scene, 0, 1)
