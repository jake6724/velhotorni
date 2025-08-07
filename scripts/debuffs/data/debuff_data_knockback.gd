class_name DebuffDataKnockback
extends DebuffData

## Weaken percentage. Incoming damage will be increased by this amount, AFTER elemental resistances have been calculated.
## Example: 100 incoming damage with %50 weaken value, neutral element, will result in 150 total damage taken.
@export var value: float

var debuff_script: Script = preload("res://scripts/debuffs/debuff_knockback.gd")

func _init():
	type = Debuff.Type.KNOCKBACK