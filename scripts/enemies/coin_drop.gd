class_name CoinDrop
extends Area2D

var countdown: float = 5 # in seconds
var destination: Vector2 = Vector2.ZERO
var destination_direction: Vector2 = Vector2.ZERO
var destination_reached: bool = false
var speed: float = 75