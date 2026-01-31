class_name TowerShield
extends Area2D

@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

var health: float = 5.0

func take_damage(damage: float) -> void:
    health -= damage
    if health > 0:
        ap.play("hit")
        ap.queue("idle")
    else:
        ap.play("hit")
        ap.queue("die")
        await ap.animation_finished
        queue_free()
    