class_name Debuff
extends Node

var type: Constants.Debuff
var priority: Constants.DebuffPriority
var element: Constants.Element
var value: float

var total_timer: Timer = Timer.new()
var repeat_timer: Timer = Timer.new()
var total_duration: float
var repeat_duration: float

func _init(_type: Constants.Debuff, _priority: Constants.DebuffPriority, _element: Constants.Element, _value: float, 
_total_duration: float, _repeat_duration: float) -> void:
	type = _type
	priority = _priority
	element = _element
	value = _value
	total_duration = _total_duration
	repeat_duration = _repeat_duration