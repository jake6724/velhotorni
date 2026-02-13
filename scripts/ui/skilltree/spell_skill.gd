class_name SpellSkill
extends Skill

@export var data: SpellData

func _ready():
	pivot_offset = Vector2(8,8)
	set_texture()

func set_texture() -> void:	
	if not locked:
		texture_normal = unlocked_icon
	else:
		texture_normal = locked_icon