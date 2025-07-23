class_name AOEBullet
extends Bullet

@onready var primary_area: Area2D = $PrimaryArea
@onready var primary_collider: CollisionShape2D = $ PrimaryArea/PrimaryCollider

@onready var aoe_area: Area2D = $AOEArea
@onready var aoe_collider: CollisionShape2D = $AOEArea/AOECollider

var target_death_pos: Vector2 # Req so that if the target dies we can still go to a position

func _ready():
	# Collision signals
	primary_area.area_entered.connect(on_primary_area_entered)
	aoe_area.area_entered.connect(on_aoe_area_entered)

	# Animation player
	ap.animation_finished.connect(on_animation_finished)

	# Connect to target if it is still alive
	if target and target.is_alive:
		target.death_position.connect(on_target_died)

	else:
		queue_free()

func _physics_process(delta):
	if is_active:
		ap.play("move")

		if target and target.is_alive:
			# TODO: The move function can be a pointer to the correct move function? for export vars (maybe an enum actually)?
			global_position = global_position + ((global_position.direction_to(target.global_position + pos_offset)) * speed * delta)

		elif target and not target.is_alive:
			if global_position.distance_to(target_death_pos + pos_offset) > min_distance:
				global_position = global_position + ((global_position.direction_to(target_death_pos + pos_offset)) * speed * delta)
			else:
				explode()
		
		else:
			explode()

func explode() -> void:
	is_active = false
	primary_collider.set_deferred("disabled", true) # unecessary ? 
	aoe_collider.set_deferred("disabled", false)
	ap.play("aoe_hit")

func on_primary_area_entered(intruder):
	if intruder == target:
		explode()

func on_aoe_area_entered(intruder):
	if intruder is Enemy:
		intruder.take_damage(damage, element)
	
func on_animation_finished(anim_name):
	if anim_name == "aoe_hit":
		queue_free()

func on_target_died(_pos):
	target_death_pos = _pos
