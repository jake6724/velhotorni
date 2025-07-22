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
@export var bullet: PackedScene