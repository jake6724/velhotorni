## Manages all information related to debuffs for an entity. 
class_name DebuffManager
extends Node2D

var can_debuff: bool = true

var stun_timer: Timer = Timer.new()
var freeze_timer: Timer = Timer.new()

var stun_cooldown: float = .1
var can_stun: bool = true
const STUN_COOLDOWN_INCREMENT: float = .05

var freeze_cooldown: float = .5
var can_freeze: bool = true
const FREEZE_COOLDOWN_INCREMENT: float = .2 

var can_knockback = true
var knockback_reset_distance: float
var times_knocked_back: int = 1
var knockback_reset_distance_interval: float = 4.0
var knockback_multiplier # set by parent enemy

var enemy_progress: float:
	set(progress):
		enemy_progress = progress
		check_knockback_reset_distance_reached(enemy_progress)

signal add_new_debuff
signal remove_active_debuff

func _ready():
	# Configure Cooldown Timers
	add_child(stun_timer)
	add_child(freeze_timer)
	stun_timer.one_shot = true
	freeze_timer.one_shot = true
	stun_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	freeze_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	stun_timer.timeout.connect(on_stun_timer_timeout)
	freeze_timer.timeout.connect(on_freeze_timer_timeout)

func add_debuff(new_debuff_data: DebuffData) -> void:
	if can_debuff:
		if check_can_cc(new_debuff_data):
			if "priority" in new_debuff_data:
				if check_debuff_type_present(new_debuff_data.type): # A debuff of this type is already active
					var active_debuff: Debuff = get_active_debuff_by_type(new_debuff_data.type)
					if active_debuff:
						if active_debuff.data.priority > new_debuff_data.priority:
							return

						elif active_debuff.data.priority == new_debuff_data.priority:
							if active_debuff.total_timer.time_left > new_debuff_data.total_duration:
								return

						# This will only be reached if the active debuff priority is lower than new debuff, 
						# or the priorities are the same but with less time left in active_debuff's total_timer
						# than the new debuff's total_duration
						remove_active_debuff.emit(active_debuff) # TODO: Determine if this is needed
						active_debuff.queue_free()
						create_debuff(new_debuff_data)
				else:
					create_debuff(new_debuff_data)

			else:
				create_debuff(new_debuff_data)

func create_debuff(_data: DebuffData) -> void:
	# Create a new Debuff object of the class defined in debuff_script
	var new_debuff: Debuff = _data.debuff_script.new(_data)
	call_deferred("add_child",new_debuff)
	await new_debuff.ready
	add_new_debuff.emit(new_debuff)
	if new_debuff.is_node_ready():
		new_debuff.call_deferred("start_debuff")

func check_can_cc(_data: DebuffData) -> bool:
	match _data.type:
		Debuff.Type.FREEZE:
			if can_freeze:
				can_freeze = false
				return true
			else:
				return false
		Debuff.Type.STUN:
			if can_stun:
				can_stun = false
				return true
			else:
				return false
		Debuff.Type.KNOCKBACK:
			if can_knockback:
				can_knockback = false
				set_knockback_reset_distance(_data)
				return true
			else:
				return false
		_: return true

func start_cc_cooldown(_debuff_type: Debuff.Type) -> void:
	match _debuff_type:
		Debuff.Type.STUN: 
			stun_timer.start(stun_cooldown)
			stun_cooldown += STUN_COOLDOWN_INCREMENT

		Debuff.Type.FREEZE:
			freeze_timer.start(freeze_cooldown)
			freeze_cooldown += FREEZE_COOLDOWN_INCREMENT
		_: pass

func on_stun_timer_timeout() -> void:
	can_stun = true

func on_freeze_timer_timeout() -> void:
	can_freeze = true

func set_knockback_reset_distance(_data) -> void:
	knockback_reset_distance = enemy_progress + ((knockback_reset_distance_interval * times_knocked_back) * knockback_multiplier)
	times_knocked_back += 1

func check_knockback_reset_distance_reached(progress: float) -> void:
	if not can_knockback:
		if progress >= knockback_reset_distance:
			can_knockback = true

func check_debuff_type_present(type: Debuff.Type) -> bool:
	for child in get_children():
		if child is Debuff:
			if child.data.type == type:
				return true
	return false

func get_active_debuff_by_type(_type: Debuff.Type) -> Debuff:
	for child in get_children():
		if child is Debuff:
			if child.data.type == _type:
				return child
	return null

func remove_all_debuffs() -> void:
	for child in get_children():
		var debuff: Debuff = child as Debuff
		if debuff:
			remove_child(debuff)
			debuff.on_total_timer_timeout()

func get_debuff_count_by_type(_match_type: Debuff.Type) -> int:
	var count: int = 0
	for child in get_children():
		var debuff: Debuff = child as Debuff
		if debuff:
			if debuff.data.type == _match_type:
				count += 1
	return count
