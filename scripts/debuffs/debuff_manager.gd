## Manages all information related to debuffs for an entity. 
class_name DebuffManager
extends Node2D

const KNOCKBACK_INCREMENT: float = 0.1

var cc_timer: Timer = Timer.new()
var can_cc: bool = true
var stun_cooldown: float = .1
var stun_cooldown_increment: float = .05
var freeze_cooldown: float = .5
var freeze_cooldown_increment: float = .25 

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

func check_cc_cooldowns(_data: DebuffData) -> bool:
	if _data.type == Debuff.Type.FREEZE and not can_cc:
		return false

	elif _data.type == Debuff.Type.STUN and not can_cc:
		return false

	elif _data.type == Debuff.Type.KNOCKBACK and not can_knockback:
		return false
	
	return true

func create_debuff(_data: DebuffData) -> void:
	# Create a new Debuff object of the class defined in debuff_script
	var new_debuff: Debuff = _data.debuff_script.new(_data)
	add_child(new_debuff)
	add_new_debuff.emit(new_debuff)
	new_debuff.call_deferred("start_debuff")

	set_can_cc(_data)
	set_knockback_reset_distance(_data)

func set_can_cc(_data: DebuffData) -> void:
	if can_cc:
		if _data.type == Debuff.Type.FREEZE or _data.type == Debuff.Type.STUN:
			can_cc = false

func start_cc_cooldown(_debuff_type: Debuff.Type) -> void:
	var _cd: float
	match _debuff_type:
		Debuff.Type.STUN: 
			cc_timer.start(stun_cooldown)
			stun_cooldown += stun_cooldown_increment

		Debuff.Type.FREEZE:
			cc_timer.start(freeze_cooldown)
			freeze_cooldown += freeze_cooldown_increment
		_: pass

func on_cc_timer_timeout() -> void:
	can_cc = true

func set_knockback_reset_distance(_data) -> void:
	if can_knockback and _data.type == Debuff.Type.KNOCKBACK:
		can_knockback = false
		knockback_reset_distance = 1 
		# knockback_reset_distance = (enemy_progress - _data.modified_value) + (_data.modified_value * knockback_multiplier)
		# knockback_multiplier += KNOCKBACK_INCREMENT

func check_knockback_reset_distance_reached(progress: float) -> void:
	if not can_knockback:
		if progress >= knockback_reset_distance:
			can_knockback = true