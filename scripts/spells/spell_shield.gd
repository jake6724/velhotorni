class_name SpellShield
extends Spell

@onready var area: Area2D = $Area2D
@onready var ap: AnimationPlayer = $AnimationPlayer

var timer: Timer = Timer.new()
var health: float
var target: Node2D

const POSITION_LERP_SCALE: float = 15

func _enter_tree():
	set_physics_process(false)

func _ready():
	ap.animation_finished.connect(on_animation_finished)
	ap.play("spawn")

	timer.one_shot = true
	timer.autostart = false
	timer.timeout.connect(on_timer_timeout)
	add_child(timer)

func initialize(spell_data: SpellDataShieldDirectional, _target: Node2D) -> void:
	health = spell_data.shield_health
	timer.start(spell_data.shield_duration)

	target = _target
	set_physics_process(true)

func _physics_process(delta):
	global_position = global_position.lerp(target.global_position, delta * POSITION_LERP_SCALE)

func take_damage(damage: int) -> void:
	health -= damage
	
	if health <= 0:
		ap.play("die")
		print("Test")
	else:
		ap.play("move")

func on_timer_timeout() -> void:
	ap.play("die")

func on_animation_finished(anim_name: String) -> void:
	print(anim_name)
	if anim_name == "die":
		queue_free()
	if anim_name == "move":
		ap.play("idle")