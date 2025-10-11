class_name SpellData
extends Resource

enum Type {BULLET, BULLET_AOE, MELEE, BULLET_CHARGED}
enum StaffType {ARCANE, WATER_SWORD, FIRE_STAFF, TRIPLE_STAFF}

@export var type: Type
@export var staff_type: StaffType = StaffType.ARCANE

@export var element: Constants.Element
@export var damage: float
@export var mana_cost: float = 0

@export var active_icon_region: Rect2 = Rect2(0,0,32,31)
@export var inactive_icon_region: Rect2 = Rect2(0,0,16,16)