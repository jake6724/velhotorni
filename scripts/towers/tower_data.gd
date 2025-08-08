class_name TowerData
extends Resource

@export_category("Elements")
## The base element of the `Tower`. `Tower` will revert back to this after wave completes.
@export var element: Constants.Element
## The next element in the cycle from `element`. The `Tower` will transform into this element.
@export var transform_element: Constants.Element
@export_category("Base Stats")
@export var damage: float
@export var speed: float
@export var attack_range: float
@export var num_targets: int
@export_category("Assets")
## The sprite atlas containing every animation for the tower. 
@export var atlas: Texture
@export var transform_hint_texture: Texture
@export var portrait: Texture
## A reference to the `Bullet` scene which the `Tower` will spawn when attacking.
@export_category("Bullet")
@export var bullet: PackedScene
@export var bullet_speed: float
## This value may be left as <empty> if no Debuff is required.
@export var debuff_data: DebuffData = null
@export_category("Buff")
@export var buff_data_list: Array[BuffData]
