class_name PitHurtbox
extends Area2D

@onready var collider: CollisionShape2D = $PitHurtboxCollider
var pre_coyote_timer: Timer = Timer.new()
var pre_coyote_time: float # Set by PlayerCharacter
## Can be disabled by another class to prevent pitfall on pre_coyote_timer.timeout
var activate: bool = true 

var pit_fall_global_position: Vector2

signal pit_entered

func _ready():
	area_entered.connect(start_pre_coyote_timer)
	pre_coyote_timer.one_shot = true
	pre_coyote_timer.autostart = false
	add_child(pre_coyote_timer)
	pre_coyote_timer.timeout.connect(on_pre_coyote_timer_timeout)

func debug(_intruder) -> void:
	print("intruder: ", _intruder)

func start_pre_coyote_timer(intruder: PitArea) -> void:
	pit_fall_global_position = intruder.global_position
	update_collider(true)
	pre_coyote_timer.start(pre_coyote_time)

func on_pre_coyote_timer_timeout() -> void:
	if activate: 
		pit_entered.emit()
		# If pitfall, PlayerCharacter.respawn() will handle resetting collider, to avoid timer -> pitfall cycle
	else:
		update_collider(false)

	activate = true

func update_collider(_value) -> void:
	collider.set_deferred("disabled", _value)

func update_activate(_value) -> void:
	activate = not _value
