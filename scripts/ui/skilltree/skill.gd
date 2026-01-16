class_name Skill
extends TextureButton

var cost: int
@export var locked_icon: AtlasTexture
@export var unlocked_icon: AtlasTexture
var locked: bool = true:
	set(value):
		locked = value
		set_icon()

@export var prereq_skills: Array[Skill] = []
		
func set_icon() -> void:
	if locked:
		texture_normal = locked_icon
	else:
		texture_normal = unlocked_icon

func check_prereq_met() -> bool:
	for skill: Skill in prereq_skills:
		if not skill.locked:
			return true

	return false
