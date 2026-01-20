class_name Spell
extends Sprite2D

var data: SpellData
var damage: float

signal damage_dealt

func start(_cast_direction: Vector2) -> void:
	pass

func set_damage(_data: SpellData, spell_element_damage_perk_modifier: float) -> void:
	damage = _data.damage * spell_element_damage_perk_modifier

func deal_damage(enemy: Enemy) -> void:
	var damage_applied: float = enemy.take_damage(damage, data.element)

	if data.debuff_data and enemy.debuff_manager:
		enemy.debuff_manager.add_debuff(data.debuff_data)

	damage_dealt.emit(damage_applied)