## Manages all information related to debuffs for an entity. 
class_name DebuffManager
extends Node2D

@export var knockback_multiplier: float # Set by enemy
@export var cc_multiplier: float # Set by enemy

var cc_timer: Timer = Timer.new()
var cc_cooldown: float
var can_cc: bool = true

var can_knockback = true
var knockback_reset_distance: float

var enemy_progress: float:
	set(progress):
		enemy_progress = progress
		check_knockback_reset_distance_reached(enemy_progress)

signal add_new_debuff
signal remove_active_debuff

func _ready():
	# Configure Cooldown Timers
	add_child(cc_timer)
	cc_timer.timeout.connect(on_cc_timer_timeout)

func add_debuff(new_debuff_data: DebuffData) -> void:
	if check_cc_cooldowns(new_debuff_data):
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

func check_cc_cooldowns(_data: DebuffData) -> bool:
	if _data.type == Constants.Debuff.FREEZE and not can_cc:
		return false

	elif _data.type == Constants.Debuff.STUN and not can_cc:
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

	start_cc_cooldown(_data)
	set_knockback_reset_distance(_data)

func start_cc_cooldown(_data: DebuffData) -> void:
	# Only set a new cooldown if not already CC'd
	if can_cc:
		if _data.type == Constants.Debuff.FREEZE or _data.type == Constants.Debuff.STUN:
			can_cc = false
			cc_cooldown = _data.total_duration * cc_multiplier
			cc_timer.start(cc_cooldown)

func set_knockback_reset_distance(_data) -> void:
	if can_knockback and _data.type == Constants.Debuff.KNOCKBACK:
		can_knockback = false
		knockback_reset_distance = (enemy_progress - _data.value) + (_data.value * knockback_multiplier)

func on_cc_timer_timeout() -> void:
	can_cc = true

func check_knockback_reset_distance_reached(progress: float) -> void:
	if not can_knockback:
		if progress >= knockback_reset_distance:
			can_knockback = true
