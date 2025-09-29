class_name PlayerSpellSpawner
extends Node

@onready var player: PlayerCharacter = get_owner()
@export var spell_spawn_point: Node2D

var spell_func: Callable = Callable(parent_spawn_bullet_spell)

var can_attack: bool = true
var attack_timer: Timer = Timer.new()

var spell_scenes: Dictionary[Spell.Type, PackedScene] = {
	Spell.Type.BULLET: preload("res://scenes/Spells/SpellBullet.tscn"), 
	Spell.Type.BULLET_AOE: preload("res://scenes/Spells/SpellBulletAOE.tscn"),
}

var spell_data: Dictionary[String, SpellData] ={
	"BasicArcane": preload("res://data/spells/spell_data_bullet_arcane_basic.tres"),
	"BasicArcaneTriple": preload("res://data/spells/spell_data_bullet_arcane_basic_triple.tres"),
	"BasicArcaneLongshot": preload("res://data/spells/spell_data_bullet_arcane_basic_longshot.tres"),
	"FireFireball": preload("res://data/spells/fire/spell_data_bullet_aoe_fireball.tres")
}

var curr_spell_data: SpellData
var curr_spell_index: int = 0

# All spells that are available in the current level
var selected_spells: Array[SpellData] = [spell_data["BasicArcane"], spell_data["BasicArcaneTriple"], spell_data["BasicArcaneLongshot"], spell_data["FireFireball"]]

var spread_rng: RandomNumberGenerator = RandomNumberGenerator.new()

signal spell_cast

func _ready():
	attack_timer.autostart = false
	attack_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	attack_timer.timeout.connect(on_attack_timer_timeout)
	add_child(attack_timer)

	curr_spell_data = selected_spells[curr_spell_index]

## Wrapper for the `spell_func` Callable. Used as an easy interface for other scripts to call.
func spawn_spell(player_aim_direction: Vector2) -> void:
	spell_func.call(player_aim_direction)

func switch_spell(_switch_direction: int) -> void:
	if curr_spell_index + _switch_direction < 0: # Go to last spell
		curr_spell_index = (selected_spells.size() - 1) 
	elif curr_spell_index + _switch_direction > (selected_spells.size() - 1): # Go to first spell
		curr_spell_index = 0 
	else:
		curr_spell_index += _switch_direction

	curr_spell_data = selected_spells[curr_spell_index]
	print(curr_spell_index)

## Spawn all bullets defined in the SpellDataBullet resource
func parent_spawn_bullet_spell(player_aim_direction: Vector2) -> void:
	if can_attack:
		can_attack = false
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
		player.player_camera.apply_shake(.1)

		# apply_spell_kick(100)

		for i in range(new_spell_data.num_bullets - 1):
			spawn_bullet_spell(player_aim_direction, new_spell_data, new_spell_scene, angle_seperation, angle_sign)

			if i % 2 == 1:
				angle_seperation += new_spell_data.angle_seperation
			angle_sign = -angle_sign

## Spawn a single spell bullet
func spawn_bullet_spell(player_aim_direction: Vector2, new_spell_data: SpellDataBullet, new_spell_scene: PackedScene, angle_seperation: float, angle_sign: float) -> void:
		var new_spell: Spell = new_spell_scene.instantiate()
		new_spell.global_position = spell_spawn_point.global_position
		new_spell.z_index = player.z_index + 2
		var angle = spread_rng.randf_range(-new_spell_data.spread, new_spell_data.spread) + angle_seperation * angle_sign
		add_child(new_spell)
		new_spell.initialize(new_spell_data, player_aim_direction.normalized().rotated(deg_to_rad(angle)))
		spell_cast.emit()

# func apply_spell_kick(kick_amount: float) -> void:
# 	print("applying kick")
# 	player.velocity += -player.aim_input * kick_amount

func on_attack_timer_timeout() -> void:
	can_attack = true
