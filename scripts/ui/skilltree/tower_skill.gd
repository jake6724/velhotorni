class_name TowerSkill
extends Skill

@export var data: TowerData

func _ready():
	if unlocked_icon:
		texture_normal = unlocked_icon
	else:
		texture_normal = locked_icon