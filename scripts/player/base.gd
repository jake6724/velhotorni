class_name Base
extends Node2D

@onready var ap: AnimationPlayer = $AnimationPlayer

var health: int = 10

signal base_destroyed
var is_alive: bool = true

func _ready():
	%Darkness.show()
	%Darkness.modulate.a = 0
	ap.animation_finished.connect(on_animation_finished)

func _physics_process(_delta):
	if is_alive:
		ap.play("idle")
	else:
		%Darkness.modulate.a = (ap.current_animation_position / ap.current_animation_length) + .01

func take_damage(damage_recieved: int):
	if is_alive:
		health -= damage_recieved
		update_health_label(health)

		if health <= 0:
			is_alive = false
			%HealthLabel.hide()

			# GameManager.level_failed = true

			MusicPlayer.fade_out()
			await MusicPlayer.fade_out_complete
			SFXPlayer.play_sfx("base_explosion")
			ap.play("die")

func update_health_label(new_health: int) -> void:
	%HealthLabel.text = str(new_health)

func on_animation_finished(anin_name: String):
	if anin_name == "die":
		base_destroyed.emit()
		MusicPlayer.fade_in()
		is_alive = true
		%Darkness.modulate.a = 0
