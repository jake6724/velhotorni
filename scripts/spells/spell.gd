class_name Spell
extends Sprite2D

var data: SpellData
var damage: float
var execution_threshold: float = 0.0
var double_spell_mana_drop: bool = false
var perk_debuffs: Array[DebuffData] = []

signal damage_dealt

func start(_cast_direction: Vector2) -> void:
	pass

func set_damage(_data: SpellData, spell_element_damage_perk_modifier: float) -> void:
	damage = _data.damage * spell_element_damage_perk_modifier

func deal_damage(enemy: Enemy) -> void:
	var damage_applied: float = enemy.take_damage(damage, data.element, execution_threshold, double_spell_mana_drop)

	if data.debuff_data and enemy.debuff_manager:
		print("Adding debuff from spell")
		enemy.debuff_manager.add_debuff(data.debuff_data)

	for perk_debuff_data in perk_debuffs:
		enemy.debuff_manager.add_debuff(perk_debuff_data)

	damage_dealt.emit(damage_applied)