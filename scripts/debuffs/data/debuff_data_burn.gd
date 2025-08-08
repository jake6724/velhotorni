class_name DebuffDataBurn
extends DebuffData

## Priority determines whether this burn will overwrite an already active burn. The burn with the highest priority will
## always be the active debuff. In the case of a priority tie, the debuff with the highest total_duration or total_duration
## remaining will be prioritized
@export var priority: Debuff.Priority

## `repeat_duration` is the time between applying burn damage. For example, if this value is 5, the target will 
## take `value` amount of burn damage every `repeat_duration` seconds.
@export var repeat_duration: float

## Value defines the amount of burn damage applied every `repeat_duration` seconds.
@export var value: float


var debuff_script: Script = preload("res://scripts/debuffs/debuff_burn.gd")

func _init():
	type = Debuff.Type.BURN
