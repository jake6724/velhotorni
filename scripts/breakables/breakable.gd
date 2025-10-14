class_name Breakable
extends Node2D

@onready var break_area: Area2D = $BreakArea
@onready var break_collider: CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var ap: AnimationPlayer = $AnimationPlayer
var broken: bool = false
var timer: Timer = Timer.new()
var shimmer_delay: float = 3.0
var drop_chance: float = 3.0

signal coin_dropped

func _ready():
	# Randomly modify shimmer_delay
	var shimmer_delay_modifier: float = Constants.weighted_random_rng.randf_range(0, 1)
	shimmer_delay += shimmer_delay_modifier

	break_area.area_entered.connect(on_area_entered)
	ap.play("idle")
	timer.autostart = false
	timer.one_shot = true
	timer.timeout.connect(on_timer_timeout)
	add_child(timer)
	timer.start(shimmer_delay)
	z_index = Constants.z_index_map["tower"]

func on_area_entered(_intruder) -> void:
	if not broken:
		broken = true
		timer.stop()
		ap.play("hit")
		ap.queue("corpse")
		coin_dropped.emit(global_position, drop_chance)

func on_timer_timeout() -> void:
	ap.play("shimmer")
	await ap.animation_finished
	ap.play("idle")
	timer.start(shimmer_delay)
