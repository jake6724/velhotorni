class_name PiercingBullet
extends Bullet

# @onready var ap: AnimationPlayer = $AnimationPlayer

# var element: Constants.Element
# var damage: int 
# var target: Enemy

# var pos_offset: Vector2 = Vector2(8,8) # Hard-code works unless tower sprite size changes
# var min_distance: float = 11
# var speed: float = 100
# var is_active: bool = true # False if hit target, but not despawned yet while hit animation plays

@onready var area: Area2D = $Area2D
@onready var collider: CollisionShape2D = $Area2D/CollisionShape2D

var enemies_hit_max: int = 3
var enemies_hit: int = 0

var direction: Vector2

var original_global_position: Vector2
var max_distance: float = (50 * 2) - 10 # TODO: Take value from tower

func _ready():
	# Collision signals
	original_global_position = global_position
	area.area_entered.connect(on_area_entered)

	speed = 300
	ap.animation_finished.connect(on_animation_finished)
	if target and target.is_alive:
		direction = global_position.direction_to(target.global_position + pos_offset)
	else:
		is_active = false
		queue_free()

func _physics_process(delta):
	if is_active:
		ap.play("move")
		global_position += speed * direction * delta

		if global_position.distance_to(original_global_position) >= max_distance:
			is_active = false
			ap.play("hit")

func on_area_entered(intruder):
	if is_active:
		if intruder is Enemy:
			intruder.take_damage(damage, element)
			enemies_hit += 1

		if enemies_hit >= enemies_hit_max:
			is_active = false
			ap.play("hit")

	# if is_active:
	# 	if target and target.is_alive:
	# 		if global_position.distance_to(target.global_position + pos_offset) > min_distance:
	# 			ap.play("move")
	# 			global_position = global_position + ((global_position.direction_to(target.global_position + pos_offset)) * speed * delta)
			
	# 		else: # If target has been reached
	# 			is_active = false
	# 			target.take_damage(damage, element)
	# 			ap.play("hit")

	# 	else: # Do nothing if target is null or dead
	# 		queue_free()

func on_animation_finished(anim_name):
	if anim_name == "hit":
		queue_free()
