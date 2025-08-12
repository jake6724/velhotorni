class_name BoonData
extends Resource

@export_category("Caster Options")
@export var mode: Boon.Mode
@export var self_cast: bool
@export var ally_cast: bool
@export var cast_speed: float
@export var cast_radius: float

@export_category("Effect Data")
@export var type: Boon.Type
@export var value: float
@export var one_shot: bool
@export var manual_disable: bool
@export var total_duration: float
@export var repeats: bool
@export var repeat_duration: float