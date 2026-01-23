class_name PlayerAOE
extends Area2D

# var aoe_damage: float
# var aoe_debuffs: Array[DebuffData]
# var aoe_element: Constants.Element = Constants.Element.ARCANE

var execution_threshold: float = 0.0

@onready var player_aoe_collider: CollisionShape2D = $PlayerAOECollider

# func _input(_event):
#     if Input.is_action_just_pressed("g"):
#         print("Attacking with AOE")
#         attack()

# func initialize(_aoe_damage: float, _aoe_debuffs: Array[DebuffData]) -> void:
#      aoe_damage = _aoe_damage
#      aoe_debuffs = _aoe_debuffs

func attack(aoe_damage: float, aoe_debuffs: Array[DebuffData], aoe_element: Constants.Element) -> void:
    var enemies: Array[Enemy] = get_in_range_enemies()
    for enemy: Enemy in enemies:
        deal_damage(enemy, aoe_damage, aoe_debuffs, aoe_element)

func deal_damage(enemy: Enemy, aoe_damage, aoe_debuffs, aoe_element) -> void:
    enemy.take_damage(aoe_damage, aoe_element, execution_threshold, false)
        
    for aoe_debuff_data: DebuffData in aoe_debuffs:
        enemy.debuff_manager.add_debuff(aoe_debuff_data)

func get_in_range_enemies() -> Array[Enemy]:
    var enemies: Array[Enemy]
    var bodies: Array = get_overlapping_areas()
    for body in bodies:
        if body is Enemy:
            enemies.append(body)
    return enemies