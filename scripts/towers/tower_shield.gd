class_name TowerShield
extends Area2D

@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D

var health: float = 20.0

func _ready():
	sprite.z_index = Constants.z_index_map["tower_shield"]
	ap.animation_finished.connect(on_animation_finished)

func take_damage(damage: float) -> void:
	health -= damage
	if health > 0:
		ap.play("hit")
	else:
		die()
	
func die() -> void:
	ap.play("die")

func on_animation_finished(_anim_name: String) -> void:
	if _anim_name == "die":
		queue_free()
	
	if _anim_name == "hit":
		ap.play("idle")
