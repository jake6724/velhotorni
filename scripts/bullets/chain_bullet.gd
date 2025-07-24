class_name ChainBullet
extends Bullet

@onready var primary_area: Area2D = $PrimaryArea
@onready var primary_collider: CollisionShape2D = $ PrimaryArea/PrimaryCollider

@onready var aoe_area: Area2D = $AOEArea
@onready var aoe_collider: CollisionShape2D = $AOEArea/AOECollider

var in_range_enemies: Array[Enemy] = []
var chain_mode_enabled: bool = false

var target_death_pos: Vector2 # Req so that if the target dies we can still go to a position


func _ready():
	# Collision signals
	primary_area.area_entered.connect(on_primary_area_entered)
	aoe_area.area_entered.connect(on_aoe_area_entered)

	aoe_collider.disabled = true

	# Animation player
	ap.animation_finished.connect(on_animation_finished)

	# Connect to target if it is still alive
	if target and target.is_alive:
		target.death_position.connect(on_target_died)

	else:
		queue_free()

func _physics_process(delta):
	if is_active:
		if not chain_mode_enabled:
			ap.play("move")
			if target and target.is_alive:
				global_position = global_position + ((global_position.direction_to(target.global_position + pos_offset)) * speed * delta)

			elif target and not target.is_alive:
				if global_position.distance_to(target_death_pos + pos_offset) > min_distance:
					global_position = global_position + ((global_position.direction_to(target_death_pos + pos_offset)) * speed * delta)
				else:
					explode()
			else:
				# Don't want this one to blow up, just fizzle out. Maybe special animation?
				is_active = false
				queue_free()
		else:
			ap.play("chain")
			if target and target.is_alive:
				global_position = target.global_position + pos_offset
			else:
				is_active = false
				queue_free()

func explode() -> void:
	is_active = false
	primary_collider.set_deferred("disabled", true) # unecessary ? 
	aoe_collider.set_deferred("disabled", false)
	ap.play("aoe_hit")

	# ?
	if not chain_mode_enabled:
			#.take_damage(damage, element)
			chain_mode_enabled = true

func on_primary_area_entered(intruder):
	if intruder == target:
		intruder.take_damage(damage, element)
		if not chain_mode_enabled:
			chain_mode_enabled = true
		explode()

func on_aoe_area_entered(intruder):
	if intruder is Enemy and intruder != target and intruder not in in_range_enemies: # TODO: clean up
		if intruder.path_follow.progress_ratio < target.path_follow.progress_ratio:
			in_range_enemies.append(intruder)

# "hit" vs "aoe_hit" will need to be sorted out! Both could prob do the same thing 
func on_animation_finished(anim_name):
	if anim_name == "aoe_hit":
		order_targets()
		# target = get_next_target()
		
		primary_collider.set_deferred("disabled", false) # unecessary ? 
		aoe_collider.set_deferred("disabled", true)

		is_active = true

		target = get_next_target()

		# print("aoe hit done")
		# print(target)
		# queue_free()

func order_targets():
	print(in_range_enemies)
	# print("IRE pre-sort: ", in_range_enemies)
	in_range_enemies.sort_custom(compare_by_progress_ratio)
	# print("IRE post-sort: ", in_range_enemies)


# Just make a list of the order to visit, then do each. It should only make the list the first time it hits an enemy then run till
# lsit is empty
func get_next_target():
	var next_target: Enemy = null
	while not next_target and in_range_enemies.size() > 0:
		if in_range_enemies.size() > 0:
			next_target = in_range_enemies.pop_front()
		else: # qf if no more targets to move to
			queue_free()

	if next_target:
		return next_target
	else:
		queue_free()

	# print("in_range_enemies: ", in_range_enemies)
	# var min_progress_ratio: float = INF
	# var next_target: Enemy = null

	# for enemy: Enemy in in_range_enemies:
	# 	if enemy: # in_range_enemies could contain enemies that have died since being a
	# 		if enemy.path_follow.progress_ratio < min_progress_ratio:
	# 			next_target = enemy


	# if next_target:
	# 	return next_target
	# else:
	# 	return null # TODO: Idk

func compare_by_progress_ratio(enemy_a: Enemy, enemy_b: Enemy) -> bool:
	return enemy_a.path_follow.progress_ratio > enemy_b.path_follow.progress_ratio

func on_target_died(_pos):
	target_death_pos = _pos
