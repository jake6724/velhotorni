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
@onready var unlock_button: Button = %UnlockButton
@onready var unlock_progress: TextureProgressBar = %UnlockProgress

@onready var tower_skill_fire: TowerSkill = %TowerSkillFire

@onready var selected_skill: Skill = tower_skill_fire

@onready var unlock_section: Control = %UnlockSection

const UNLOCK_PROGRESS_SPEED_MULTIPLIER: float = 200

func _ready(): 
	print("Selected Skill: ", selected_skill)

	for child in tower_skills_parent.get_children():
		if child is TowerSkill:
			tower_skills.append(child)
			child.pressed.connect(on_skill_pressed.bind(child))
			# child.mouse_entered.connect(on_skill_pressed.bind(child))
			print(child.data)
			child.locked = not PlayerLoadout.towers[child.data]

	for child in spell_skills_parent.get_children():
		if child is SpellSkill:
			spell_skills.append(child)
			child.pressed.connect(on_skill_pressed.bind(child))
			# child.mouse_entered.connect(on_skill_pressed.bind(child))
		
	on_skill_pressed(selected_skill)

	player_star_count.text = str(StarRegistry.player_star_count)
	StarRegistry.player_star_count_updated.connect(on_player_star_count_updated)

	unlock_button.button_down.connect(on_unlock_button_down)
	unlock_button.button_up.connect(on_unlock_button_up)

	set_process(false)

func _process(delta):
	unlock_progress.value += delta * UNLOCK_PROGRESS_SPEED_MULTIPLIER

	if unlock_progress.value >= 100:
		unlock_button.button_pressed = false
		unlock_skill(selected_skill)
		

func on_skill_pressed(skill: Skill) -> void:
	selected_skill = skill
	if skill is SpellSkill:
		skill_name.text = skill.data.spell_name
		skill_desc.text = skill.data.desc
 
	if skill is TowerSkill:
		skill_name.text = skill.data.tower_name
		skill_desc.text = skill.data.desc

	if skill.locked:
		unlock_section.show()
	else:
		unlock_section.hide()

func on_player_star_count_updated() -> void:
	player_star_count.text = str(StarRegistry.player_star_count)

func on_unlock_button_down() -> void:
	if selected_skill and selected_skill.data:
		if selected_skill.data.unlock_cost <= StarRegistry.player_star_count:
			print("Process true")
			set_process(true)

func on_unlock_button_up() -> void:
	# print("Button Up!")
	set_process(false)

	unlock_progress.value = 0.0

func unlock_skill(skill: Skill) -> void:
	if skill is TowerSkill:
		PlayerLoadout.towers[skill.data] = true
	
	if skill is SpellSkill:
		PlayerLoadout.spells[skill.data] = true

	skill.locked = false
	StarRegistry.player_star_count -= skill.data.unlock_cost
	unlock_section.hide()

	shake_skill(selected_skill)

func shake_skill(skill: Skill) -> void:
	var movement_tween: Tween = get_tree().create_tween()
	var rotation_tween: Tween = get_tree().create_tween()

	var prev_pos_y: float = skill.position.y
	movement_tween.tween_property(skill, "position:y", prev_pos_y - 5, .02)
	movement_tween.tween_interval(.5)
	movement_tween.tween_property(skill, "position:y", prev_pos_y, .02)

	rotation_tween.tween_property(skill, "rotation_degrees", 40, .05)
	rotation_tween.tween_interval(.5)
	rotation_tween.tween_property(skill, "rotation_degrees", 0, .05)