class_name BulletModifierData
extends Resource

enum Type {COIN, NONE}

@export var type: BulletModifierData.Type
@export var value: float

var preview_leveled_value: float
var leveled_value: float