class_name DebuffDataFreeze
extends DebuffData

var debuff_script: Script = preload("res://scripts/debuffs/debuff_freeze.gd")

func _init():
	type = Debuff.Type.FREEZE
