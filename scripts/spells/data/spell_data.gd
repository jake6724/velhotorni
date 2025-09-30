class_name SpellData
extends Resource

enum Type {BULLET, BULLET_AOE, MELEE}
enum StaffType {ARCANE, WATER_SWORD}

@export var type: Type
@export var staff_type: StaffType = StaffType.ARCANE