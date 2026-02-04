class_name ManaDrop
extends Area2D

var spell_data: SpellData
var amount_modifier: float
var destination_reached: bool = false
var destination: Vector2
var wave_complete_collect: bool