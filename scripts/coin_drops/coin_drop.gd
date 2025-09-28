class_name CoinDrop
extends Area2D

@onready var ap: AnimationPlayer = $AnimationPlayer

var countdown: float = 20 # in seconds
var destination: Vector2 = Vector2.ZERO
var destination_direction: Vector2 = Vector2.ZERO
var destination_reached: bool = false
var speed: float = 150
var float_speed: float = 20

var blink_start: float = 4 # second that blink starts
var blink_rate: float = .25
var blink_rate_multiplier: float = .1
var blink_checkpoint: float = 0.0

var is_reward: bool = false

func _ready():
	ap.play("spin")