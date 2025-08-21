class_name Boon
extends Node

enum Type {HEAL, CONCEAL, SPEED, DAMAGE, STEALTH, CLEANSE, PREVENT}
enum Mode {TIMER, COLLISION}

signal boon_triggered
signal boon_expired

var source: BoonArea
var type: Boon.Type
var value: float
var one_shot: bool
var manual_disable: bool
var repeats: bool
var total_duration: float
var repeat_duration: float
var total_timer: Timer = Timer.new()
var repeat_timer: Timer = Timer.new()

func _init(_data: BoonData):
	value = _data.value
	type = _data.type
	total_duration = _data.total_duration
	repeat_duration = _data.repeat_duration
	one_shot = _data.one_shot
	manual_disable = _data.manual_disable
	repeats = _data.repeats

func _ready():
	boon_triggered.emit()

	if one_shot:
		boon_expired.emit()
	elif not manual_disable:
		add_child(total_timer)
		total_timer.timeout.connect(on_total_timer_timeout)
		total_timer.start(total_duration)

		if repeats:
			add_child(repeat_timer)
			repeat_timer.timeout.connect(on_repeat_timer_timeout)
			repeat_timer.start(repeat_duration)

func on_total_timer_timeout() -> void:
	boon_expired.emit()

func on_repeat_timer_timeout() -> void:
	boon_triggered.emit()
	repeat_timer.start(repeat_duration)