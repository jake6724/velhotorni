class_name DebuffDataStun
extends DebuffData

var debuff_script: Script = preload("res://scripts/debuffs/debuff_stun.gd")

func _init():
	type = Debuff.Type.STUN