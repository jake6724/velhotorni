class_name AOERingBullet
extends Bullet

@onready var primary_area: Area2D = $PrimaryArea
@onready var primary_collider: CollisionShape2D = $ PrimaryArea/PrimaryCollider

@onready var aoe_area: Area2D = $AOEArea
@onready var aoe_collider: CollisionShape2D = $AOEArea/AOECollider

var target_death_pos: Vector2 # Req so that if the target dies we can still go to a position

func _ready():
	# Collision signals
	#primary_area.area_entered.connect(on_primary_area_entered)
	aoe_area.area_entered.connect(on_aoe_area_entered)
	
	aoe_collider.disabled = true

	# Animation player
	ap.animation_finished.connect(on_animation_finished)

	# # Connect to target if it is still alive
	# if target and target.is_alive:
	# 	target.death_position.connect(on_target_died)

	# else:
	# 	queue_free()

	ap.play("aoe_ring")

func _physics_process(_delta):
	pass

func on_aoe_area_entered(intruder):
	if intruder is Enemy:
		intruder.take_damage(damage, element)

func on_animation_finished(anim_name):
	if anim_name == "aoe_ring":
		queue_free()

func enable_aoe_collider() -> void:
	aoe_collider.set_deferred("disabled", false)