class_name PlayerSpellSpawner
extends Node

@onready var player: PlayerCharacter = get_owner()
@export var spell_spawn_point: Node2D

var spell_func: Callable = Callable(parent_spawn_bullet_spell)

var can_attack: bool = true
var attack_timer: Timer = Timer.new()
var attack_delay: float = .1 # TODO: Set this each time a spell is changed

var spell_bullet: PackedScene = preload("res://scenes/Spells/SpellBullet.tscn")

var spell_data: Dictionary[String, SpellData] ={
	"BasicArcane": load("res://data/spells/spell_data_bullet_arcane_basic.tres"),
}

var spread_rng: RandomNumberGenerator = RandomNumberGenerator.new()

signal spell_cast

func _ready():
	attack_timer.autostart = false
	attack_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	attack_timer.timeout.connect(on_attack_timer_timeout)
	add_child(attack_timer)

# TODO: Prob func refs for the diff types of spells
func spawn_spell(player_aim_direction: Vector2) -> void:
	spell_func.call(player_aim_direction)

## Spawn all bullets defined in the SpellDataBullet resource
func parent_spawn_bullet_spell(player_aim_direction: Vector2) -> void:
	if can_attack:
		can_attack = false
		attack_timer.start(attack_delay)
		var new_spell_data: SpellData = spell_data["BasicArcane"]

		var angle_seperation: float = 0
		var angle_sign: float = 1.0

		# Spawn initial center bullet
		spawn_bullet_spell(player_aim_direction, new_spell_data, angle_seperation, angle_sign)
		angle_seperation += new_spell_data.angle_seperation

		for i in range(new_spell_data.num_bullets - 1):
			print(i)
			spawn_bullet_spell(player_aim_direction, new_spell_data, angle_seperation, angle_sign)

			if i % 2 == 1:
				angle_seperation += new_spell_data.angle_seperation
			angle_sign = -angle_sign

## Spawn a single spell bullet
func spawn_bullet_spell(player_aim_direction: Vector2, new_spell_data: SpellDataBullet, angle_seperation: float, angle_sign: float) -> void:
		var new_spell: Spell = spell_bullet.instantiate()
		add_child(new_spell)
		new_spell.global_position = spell_spawn_point.global_position
		new_spell.z_index = player.z_index + 2 # TODO: Map this to staff likely
		var angle = spread_rng.randf_range(-new_spell_data.spread, new_spell_data.spread) + angle_seperation * angle_sign
		new_spell.initialize(new_spell_data, player_aim_direction.normalized().rotated(deg_to_rad(angle)))
		spell_cast.emit() # TODO: pass the type later maybe? 

func on_attack_timer_timeout() -> void:
	can_attack = true
