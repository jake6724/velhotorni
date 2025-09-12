class_name PlayerSpellSpawner
extends Node

@export var spell_spawn_point: Node2D

@onready var player: PlayerCharacter = get_owner()

var can_attack: bool = true
var attack_timer: Timer = Timer.new()
var attack_delay: float = .1 # TODO: Set this each time a spell is changed

var spell_fire_basic_scene: PackedScene = preload("res://scenes/Spells/SpellBasicFire.tscn")

signal spell_cast

func _ready():
	attack_timer.autostart = false
	attack_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	attack_timer.timeout.connect(on_attack_timer_timeout)
	add_child(attack_timer)

func spawn_spell(player_aim_direction: Vector2) -> void:
	if can_attack:
		can_attack = false
		attack_timer.start(attack_delay)

		var new_spell: Spell = spell_fire_basic_scene.instantiate()
		add_child(new_spell)
		new_spell.global_position = spell_spawn_point.global_position
		new_spell.z_index = player.z_index + 2 # TODO: Map this to staff likely
		new_spell.start(player_aim_direction)

		spell_cast.emit() # TODO: pass the type later maybe? 

func on_attack_timer_timeout() -> void:
	can_attack = true
