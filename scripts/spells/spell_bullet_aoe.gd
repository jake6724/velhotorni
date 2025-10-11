class_name SpellBulletAOE
extends SpellBullet

@onready var aoe_area: Area2D = $AOEArea
@onready var aoe_collider: CollisionShape2D = $AOEArea/AOECollider

func initialize(_data: SpellDataBullet, cast_direction: Vector2) -> void:
	data = _data
	original_position = global_position
	if cast_direction:
		move_direction = cast_direction
	else:
		move_direction = Vector2(1, 0) # Need to be the direction player is facing? 

	texture = data.atlas

	aoe_area.area_entered.connect(on_aoe_area_entered)

	aoe_collider.shape.radius = data.aoe_radius
	aoe_collider.disabled = true

func on_area_entered(_enemy: Enemy) -> void:
	explode()

## Hit Terrain Obstacle
func on_body_entered(_intruder) -> void:
	explode()

func on_animation_finished(anim_name) -> void:
	if anim_name == "aoe_hit":
		queue_free()

func check_max_distance_reached() -> void:
	if active and abs(global_position.distance_to(original_position)) > data.max_distance:
		explode()

func explode() -> void:
	if active:
		active = false
		texture = data.explosion_atlas
		scale *= 1.3 # TODO: Temp scale up explosion size
		aoe_collider.set_deferred("disabled", false)
		ap.play("aoe_hit")

func on_aoe_area_entered(enemy: Enemy) -> void:
	deal_damage(enemy)
