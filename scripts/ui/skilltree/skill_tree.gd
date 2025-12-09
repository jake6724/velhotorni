class_name SkillTree
extends Control

@onready var tower_skills_parent: Control = %TowerSkills
var tower_skills: Array[TowerSkill] = []

@onready var spell_skills_parent: Control = %SpellSkills
var spell_skills: Array[SpellSkill] = []

func _ready():
	for child in tower_skills_parent.get_children():
		if child is TowerSkill:
			tower_skills.append(child)
			child.press.connect(on_skill_pressed.bind(child))

	for child in spell_skills_parent.get_children():
		if child is SpellSkill:
			spell_skills.append(child)

func on_skill_pressed(skill: Skill) -> void:
	pass

# func on_tower_skill_pressed(tower_skill: TowerSkill) -> void:
# 	if tower_skill.cost <= PlayerLoadout.stars:
# 		PlayerLoadout.stars -= tower_skill.cost
# 		PlayerLoadout.towers[tower_skill.tower_data] = true