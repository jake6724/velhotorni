## Manages all information related to debuffs for an entity. 
class_name DebuffManager
extends Node2D

var freeze_timer: Timer = Timer.new()
var stun_timer: Timer = Timer.new()
var knockback_timer: Timer = Timer.new()

var freeze_cooldown: float
var stun_cooldown: float
var knockback_cooldown: float

var can_freeze: bool = true
var can_stun: bool = true
var can_knockback = true

signal add_new_debuff
signal remove_active_debuff

func _ready():
	# Configure Cooldown Timers
	add_child(freeze_timer)
	add_child(stun_timer)
	add_child(knockback_timer)
	freeze_timer.timeout.connect(on_freeze_timer_timeout)
	stun_timer.timeout.connect(on_stun_timer_timeout)
	knockback_timer.timeout.connect(on_knockback_timer_timeout)

func add_debuff(new_debuff_data: DebuffData) -> void:

	if check_debuff_allowed(new_debuff_data):
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
	else:
		print("Cannot apply this debuff yet (cooldown active)")

func check_debuff_type_present(type: Constants.Debuff) -> bool:
	for child in get_children():
		if child is Debuff:
			if child.data.type == type:
				return true
	return false

func get_active_debuff_by_type(_type: Constants.Debuff) -> Debuff:
	for child in get_children():
		if child is Debuff:
			if child.data.type == _type:
				return child
	return null

func check_debuff_allowed(_data: DebuffData) -> bool:
	if _data.type == Constants.Debuff.FREEZE and not can_freeze:
		return false

	elif _data.type == Constants.Debuff.STUN and not can_stun:
		return false

	elif _data.type == Constants.Debuff.KNOCKBACK and not can_knockback:
		return false
	
	return true

func create_debuff(_data: DebuffData) -> void:
	# Create a new Debuff object of the class defined in debuff_script
	var new_debuff: Debuff = _data.debuff_script.new(_data)
	add_child(new_debuff)
	add_new_debuff.emit(new_debuff)
	new_debuff.call_deferred("start_debuff")
	start_debuff_cooldown(_data.type)

func start_debuff_cooldown(_type: Constants.Debuff) -> void:
	match _type:
		Constants.Debuff.FREEZE: 
			can_freeze = false
			freeze_timer.start(freeze_cooldown)
		Constants.Debuff.STUN: 
			can_stun = false
			stun_timer.start(stun_cooldown)
		Constants.Debuff.KNOCKBACK: 
			can_knockback = false
			knockback_timer.start(knockback_cooldown)
		_: pass

func on_freeze_timer_timeout() -> void:
	can_freeze = true

func on_stun_timer_timeout() -> void:
	can_stun = true

func on_knockback_timer_timeout() -> void:
	can_knockback = true
