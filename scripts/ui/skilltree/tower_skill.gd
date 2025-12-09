class_name TowerSkill
extends Skill

@export var locked_icon: AtlasTexture
@export var unlocked_icon: AtlasTexture
@export var data: TowerData

func _ready():
	if unlocked_icon:
		texture_normal = unlocked_icon