class_name DebuffDataSlow
extends DebuffData

## Priority determines whether this slow will overwrite an already active slow. The slow with the highest priority will
## always be the active debuff. In the case of a priority tie, the debuff with the highest total_duration or total_duration
## remaining will be prioritized
@export var priority: Debuff.Priority
 
## Slow percentage. Define as a whole number; for example a %60 slow = 60.0
@export var value: float

var debuff_script: Script = preload("res://scripts/debuffs/debuff_slow.gd")

func _init():
	type = Debuff.Type.SLOW