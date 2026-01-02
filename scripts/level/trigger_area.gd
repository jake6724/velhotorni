class_name TriggerArea
extends Area2D

@onready var collider: CollisionShape2D = $CollisionShape2D

signal dialogue_triggered
signal wave_started_allowed

@export var trigger_dialogue: bool = true
@export var disable_after_exit: bool = true
@export var allow_wave_start: bool = false

func _ready():
	area_entered.connect(on_area_entered)
	area_exited.connect(on_area_exited)

func on_area_entered(_intruder) -> void:
	if trigger_dialogue:
		dialogue_triggered.emit()
	if allow_wave_start:
		wave_started_allowed.emit(true)

func on_area_exited(_intruder) -> void:
	if disable_after_exit:
		collider.set_deferred("disabled", true)
