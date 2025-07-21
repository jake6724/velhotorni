class_name Bullet
extends Sprite2D

@onready var ap: AnimationPlayer = $AnimationPlayer

var element: Constants.Element
var damage: int 
var target: Enemy

var pos_offset: Vector2 = Vector2(8,8) # Hard-code works unless tower sprite size changes
var min_distance: float = 11
var speed: float = 100
var is_active: bool = true # False if hit target, but not despawned yet while hit animation plays

func _ready():
	ap.animation_finished.connect(on_animation_finished)

func _physics_process(delta):
	if is_active:
		if target and target.is_alive:
			if global_position.distance_to(target.global_position + pos_offset) > min_distance:
				ap.play("move")
				global_position = global_position + ((global_position.direction_to(target.global_position + pos_offset)) * speed * delta)
			
			else: # If target has been reached
				is_active = false
				target.take_damage(damage, element)
				ap.play("hit")

		else: # Do nothing if target is null or dead
			queue_free()

func on_animation_finished(anim_name):
	if anim_name == "hit":
		queue_free()