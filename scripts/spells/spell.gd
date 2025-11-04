class_name Spell
extends Sprite2D

var data: SpellData

func start(_cast_direction: Vector2) -> void:
	pass

func deal_damage(enemy: Enemy) -> void:
	# TODO: Add option to deal debuff as well
	enemy.take_damage(data.damage, data.element)

	if data.debuff_data and enemy.debuff_manager:
		enemy.debuff_manager.add_debuff(data.debuff_data)
