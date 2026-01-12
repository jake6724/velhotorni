class_name SkillTree
extends Control

@onready var tower_skills_parent: Control = %TowerSkills
var tower_skills: Array[TowerSkill] = []

@onready var spell_skills_parent: Control = %SpellSkills
var spell_skills: Array[SpellSkill] = []

@onready var skill_name: Label = %SkillName
@onready var skill_element: Label = %SkillElement
@onready var skill_cost: Label = %SkillCost
@onready var skill_desc: Label = %SkillDesc

@onready var player_star_count: Label = %PlayerStarCount

func _ready():
	for child in tower_skills_parent.get_children():
		if child is TowerSkill:
			tower_skills.append(child)
			child.pressed.connect(on_skill_pressed.bind(child))
			child.mouse_entered.connect(on_skill_pressed.bind(child))
			print(child.data)
			child.is_locked = not PlayerLoadout.towers[child.data]

	for child in spell_skills_parent.get_children():
		if child is SpellSkill:
			spell_skills.append(child)
			child.pressed.connect(on_skill_pressed.bind(child))
			child.mouse_entered.connect(on_skill_pressed.bind(child))

	player_star_count.text = str(StarRegistry.player_star_count)
	StarRegistry.player_star_count_updated.connect(on_player_star_count_updated)

func on_skill_pressed(skill: Skill) -> void:
	# print("Skill: ", skill)

	if skill is SpellSkill:
		skill_name.text = skill.data.spell_name
		skill_desc.text = skill.data.desc

	if skill is TowerSkill:
		skill_name.text = skill.data.tower_name
		skill_desc.text = skill.data.desc

func on_player_star_count_updated() -> void:
	player_star_count.text = str(StarRegistry.player_star_count)
