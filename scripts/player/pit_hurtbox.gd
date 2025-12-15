class_name PitHurtbox
extends Area2D

@onready var collider: CollisionShape2D = $PitHurtboxCollider

signal pit_entered

func _ready():
	body_entered.connect(on_body_entered)

func on_body_entered(_intruder) -> void: 
	pit_entered.emit()