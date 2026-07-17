class_name Breakable
extends Node2D

@onready var break_area: Area2D = $BreakArea
@onready var break_collider: CollisionShape2D = $BreakArea/BreakCollider
@onready var sprite: Sprite2D = $Sprite2D
@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var breakable_hitbox_collider: CollisionShape2D = %BreakableHitboxCollider
var broken: bool = true
var shimmer_timer: Timer = Timer.new()
var shimmer_delay: float = 3.0
var drop_chance: float = 75

var spawn_timer: Timer = Timer.new()
var spawn_delay_base: float = 5.0
var spawn_delay_range: float = 2.0 # Added to spawn_delay_base, only selected in the positive direction (0, spawn_delay_range)
var spawn_delay: float

signal coin_dropped

func _ready():
	on_spawn_timer_timeout()

	# Randomly modify shimmer_delay
	var shimmer_delay_modifier: float = Constants.weighted_random_rng.randf_range(0, 1)
	shimmer_delay += shimmer_delay_modifier

	break_area.area_entered.connect(on_area_entered)

	shimmer_timer.autostart = false
	shimmer_timer.one_shot = true
	shimmer_timer.timeout.connect(on_shimmer_timer_timeout)
	add_child(shimmer_timer)

	# spawn_timer.autostart = false
	# spawn_timer.one_shot = true
	# spawn_timer.timeout.connect(on_spawn_timer_timeout)
	# add_child(spawn_timer)

	z_index = Constants.z_index_map["tower"]

	WaveManager.wave_completed.connect(on_spawn_timer_timeout)

	# ap.play("corpse")

func start_grow() -> void:
	pass
	# if broken:
	# 	spawn_delay = Constants.weighted_random_rng.randf_range(0, spawn_delay_range)
	# 	spawn_timer.start(spawn_delay)

func on_area_entered(_intruder) -> void:
	if not broken:
		broken = true
		AudioManager.create_2d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.BREAKABLE_MANA_CRYSTAL_SHATTER)
		shimmer_timer.stop()
		ap.play("hit")
		ap.queue("corpse")
		coin_dropped.emit(global_position, drop_chance)
		breakable_hitbox_collider.set_deferred("disabled", true)
		break_collider.set_deferred("disabled", true)

func on_spawn_timer_timeout() -> void:
	ap.play("spawn")
	await ap.animation_finished
	ap.play("idle")
	shimmer_timer.start(shimmer_delay)
	breakable_hitbox_collider.set_deferred("disabled", false)
	break_collider.set_deferred("disabled", false)
	broken = false

func on_shimmer_timer_timeout() -> void:
	if not broken:
		ap.play("shimmer")
		await ap.animation_finished
		ap.play("idle")
		shimmer_timer.start(shimmer_delay)
