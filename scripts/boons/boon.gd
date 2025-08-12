class_name Boon
extends Node

enum Type {HEAL}
enum Mode {TIMER, COLLISION}

signal boon_triggered
signal boon_expired

var source: BoonArea
var type: Boon.Type
var value: float
var one_shot: bool
var total_duration: float
var repeat_duration: float
var total_timer: Timer = Timer.new()
var repeat_timer: Timer = Timer.new()
var _boon_action_name: String
var _boon_action: Callable

func _init(_data: BoonData):
	value = _data.value
	type = _data.type
	total_duration = _data.total_duration
	repeat_duration = _data.repeat_duration
	one_shot = _data.one_shot

func _ready():
	match type:
		Boon.Type.HEAL: _boon_action_name = "heal"
	
	_boon_action = Callable(self, _boon_action_name)
	_boon_action.call()

	if one_shot:
		boon_expired.emit()
	else:
		add_child(total_timer)
		add_child(repeat_timer)
		total_timer.timeout.connect(on_total_timer_timeout)
		repeat_timer.timeout.connect(on_repeat_timer_timeout)
		total_timer.start(total_duration)
		repeat_timer.start(repeat_duration)

func heal() -> void:
	boon_triggered.emit()

func on_total_timer_timeout() -> void:
	boon_expired.emit()

func on_repeat_timer_timeout() -> void:
	_boon_action.call()
	repeat_timer.start(repeat_duration)
