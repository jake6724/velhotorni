class_name BoonData
extends Resource

@export_category("Caster Options")
@export var type: Boon.Type
@export var mode: Boon.Mode
@export var self_cast: bool
@export var cast_speed: float

@export_category("Effect Data")
@export var value: float
@export var total_duration: float
@export var repeat_duration: float