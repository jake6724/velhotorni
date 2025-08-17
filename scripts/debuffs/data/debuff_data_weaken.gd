class_name DebuffDataWeaken
extends DebuffData

## Weaken percentage. Incoming damage will be increased by this amount, AFTER elemental resistances have been calculated.
## Example: 100 incoming damage with %50 weaken value, neutral element, will result in 150 total damage taken.
@export var value: float

## Priority determines whether this weaken will overwrite an already active weaken. The weaken with the highest priority will
## always be the active debuff. In the case of a priority tie, the debuff with the highest total_duration or total_duration
## remaining will be prioritized
@export var priority: Debuff.Priority

var debuff_script: Script = preload("res://scripts/debuffs/debuff_weaken.gd")

func _init():
	type = Debuff.Type.WEAKEN
