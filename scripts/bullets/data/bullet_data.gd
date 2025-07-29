class_name BulletData
extends Resource

@export var follow_on_hit: bool = false

## Set by Tower
var debuff_data: DebuffData = null
var element: Constants.Element
var damage: float
var speed: float
var max_distance: float