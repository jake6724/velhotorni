class_name BoonArea
extends Area2D

@onready var boon_collider: CollisionShape2D = $BoonCollider

var boon_data: BoonData
var cast_timer: Timer

func initialize(_boon_data: BoonData):
	boon_data = _boon_data
	boon_collider.shape.radius = _boon_data.cast_radius
	match boon_data.mode:
		Boon.Mode.TIMER: 
			cast_timer = Timer.new()
			add_child(cast_timer)
			cast_timer.timeout.connect(on_cast_timer_timeout)
			cast_timer.start(boon_data.cast_speed)

		Boon.Mode.COLLISION:
			area_entered.connect(on_buff_area_entered)
			area_exited.connect(on_buff_area_exited)

func on_cast_timer_timeout() -> void:
	var allies: Array[Area2D] = get_overlapping_areas()
	for ally in allies:
		connect_boon(ally.owner)

	cast_timer.start(boon_data.cast_speed)

func on_buff_area_entered(intruder) -> void:
	connect_boon(intruder.owner)

func on_buff_area_exited(intruder) -> void:
	if intruder.owner:
		intruder.owner.boon_manager.expire_boon_by_source(self)

## Handle the logic for determining if an boon should be connected to self or enemy
func connect_boon(enemy: Enemy) -> void: 
	if enemy:
		if boon_data.ally_cast and enemy != self.owner:
			enemy.boon_manager.connect_boon(create_boon(boon_data))

		elif boon_data.self_cast and enemy == self.owner:
			enemy.boon_manager.connect_boon(create_boon(boon_data))

func disconnect_boon(enemy: Enemy) -> void:
	if boon_data.ally_cast and enemy != self.owner:
		enemy.owner.boon_manager.expire_boon_by_source(self)

	elif boon_data.self_cast and enemy == self.owner:
		enemy.owner.boon_manager.expire_boon_by_source(self)

func create_boon(_boon_data) -> Boon:
	var new_boon: Boon = Boon.new(_boon_data)
	new_boon.source = self
	return new_boon
