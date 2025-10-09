class_name CoinCollector
extends Node2D

@onready var collect_area: Area2D = $CollectArea
@onready var magnet_area: Area2D = $MagnetArea

var magnetized_coins: Array[CoinDrop] = []

signal coin_collected
signal reward_collected

func _ready():
	collect_area.area_entered.connect(on_collect_area_entered)
	magnet_area.area_entered.connect(on_magnet_area_entered)
	magnet_area.area_exited.connect(on_magnet_area_exited)

# func _process(_delta): # Follow mouse
# 	global_position = get_global_mouse_position()

func _physics_process(delta):
	for coin: CoinDrop in magnetized_coins:
		if coin:
			var direction = coin.global_position.direction_to(global_position)
			coin.global_position += direction * Constants.MAGNET_SPEED * delta

func on_collect_area_entered(intruder) -> void:
	var coin: CoinDrop = intruder as CoinDrop
	if coin:
		var index: int = magnetized_coins.find(coin)
		if index != -1:
			magnetized_coins.remove_at(magnetized_coins.find(coin))
		
		SFXPlayer.play_sfx("coin_collect")
		coin_collected.emit()
		if coin.is_reward:
			reward_collected.emit()
		coin.queue_free()
		
func on_magnet_area_entered(intruder) -> void:
	var coin: CoinDrop = intruder as CoinDrop
	if coin:
		coin.destination_reached = true
		magnetized_coins.append(coin)

func on_magnet_area_exited(intruder) -> void:
	var coin: CoinDrop = intruder as CoinDrop
	if coin:
		var index: int = magnetized_coins.find(coin)
		if index != -1:
			magnetized_coins.remove_at(magnetized_coins.find(coin))
