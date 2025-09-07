class_name Base
extends Node2D

@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var health_bar: Label = %HealthLabel
@onready var light: TextureRect = %Light

var health: int:
	set(value):
		health = value
		health_bar.text = str(health)
var health_checkpoint: int
var max_health: int = 10

signal destroyed
signal damaged
var is_alive: bool = true

func _ready():
	health = max_health
	health_checkpoint = health
	light.show()
	light.modulate.a = 0
	ap.animation_finished.connect(on_animation_finished)

	# Connect to WaveManager
	WaveManager.wave_completed.connect(on_wave_completed)
	
func _physics_process(_delta):
	if is_alive:
		ap.play("idle")
	else:
		light.modulate.a = (ap.current_animation_position / ap.current_animation_length) + .01

func take_damage(damage_recieved: int) -> void:
	health -= damage_recieved
	update_health_label(health)
	damaged.emit()
	if is_alive and health <= 0:
		die()

func on_animation_finished(anin_name: String):
	if anin_name == "die":
		reset()

func die() -> void:
	is_alive = false
	health_bar.hide()
	MusicPlayer.fade_out()
	await MusicPlayer.fade_out_complete
	SFXPlayer.play_sfx("base_explosion")
	ap.play("die")

func reset() -> void:
	MusicPlayer.fade_in()
	is_alive = true
	light.modulate.a = 0
	health = health_checkpoint
	health_bar.show()
	destroyed.emit()

func on_wave_completed() -> void:
	health_checkpoint = health

func update_health_label(new_health: int) -> void:
	health_bar.text = str(new_health)
