class_name PlayerSpellSpawner
extends Node

@onready var player: PlayerCharacter = get_owner()
@export var spell_spawn_point: Node2D

var can_attack: bool = true
var attack_timer: Timer = Timer.new()
var attack_delay: float = .1 # TODO: Set this each time a spell is changed

var spell_fire_basic_scene: PackedScene = preload("res://scenes/Spells/SpellBasicFire.tscn")
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
	if can_attack:
		can_attack = false
		attack_timer.start(attack_delay)

		var new_spell: Spell = spell_bullet.instantiate()
		add_child(new_spell)
		new_spell.global_position = spell_spawn_point.global_position
		new_spell.z_index = player.z_index + 2 # TODO: Map this to staff likely

		var new_spell_data: SpellData = spell_data["BasicArcane"]
		# TODO: This will only need to be done for bullet type spells
		var spread = spread_rng.randf_range(-new_spell_data.spread, new_spell_data.spread)

		new_spell.initialize(new_spell_data, player_aim_direction.normalized().rotated(deg_to_rad(spread)))
		spell_cast.emit() # TODO: pass the type later maybe? 

func on_attack_timer_timeout() -> void:
	can_attack = true
