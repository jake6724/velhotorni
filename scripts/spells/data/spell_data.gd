class_name SpellData
extends Resource

enum Type {BULLET, BULLET_AOE, MELEE, BULLET_CHARGED, SHIELD_DIRECTIONAL}
enum StaffType {ARCANE, WATER_SWORD, FIRE_STAFF, TRIPLE_STAFF}

@export var type: Type
@export var staff_type: StaffType = StaffType.ARCANE

@export var element: Constants.Element
@export var damage: float
@export var cooldown: float
@export var debuff_data: DebuffData

## How many base individual charges for this weapon per spell mana drop pickup
@export var base_spell_mana_per_drop: int = 10
@export var initial_mana_amount: int = 100
@export var max_mana_amount: int = 100
var mana_cost: float = 1

@export var spell_name: String = ""
@export var popup_name: String = ""
@export var desc: String = ""

@export var active_icon: AtlasTexture
@export var active_icon_region: Rect2 = Rect2(0,0,32,31)
@export var inactive_icon_region: Rect2 = Rect2(0,0,16,16)

@export var camera_shake: float = .1