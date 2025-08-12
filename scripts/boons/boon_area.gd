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
			boon_collider.area_entered.connect(on_buff_area_entered)
			boon_collider.area_exited.connect(on_buff_area_exited)
			
func on_cast_timer_timeout() -> void:
	var allies: Array[Area2D] = get_overlapping_areas()
	for ally in allies:
		if boon_data.ally_cast and ally != self.owner:
			ally.boon_manager.connect_boon(create_boon(boon_data))

		elif boon_data.self_cast and ally == self.owner:
			ally.boon_manager.connect_boon(create_boon(boon_data))

	cast_timer.start(boon_data.cast_speed)

func on_buff_area_entered(ally) -> void:
	ally.boon_manager.connect_boon(create_boon(boon_data))

func on_buff_area_exited(ally) -> void:
	ally.boon_manager.remove_boon_from_source(self)

func create_boon(_boon_data) -> Boon:
	var new_boon: Boon = Boon.new(_boon_data)
	new_boon.source = self
	return new_boon
