class_name ManaDropCollector
extends Node2D

@onready var magnet_area: Area2D = $MagnetArea
@onready var collect_area: Area2D = $CollectArea

var magnetized_drops: Array[ManaDrop] = []

signal mana_drop_collected
signal mana_drop_collected_no_data

func _ready():
	magnet_area.area_entered.connect(on_magnet_area_entered)
	magnet_area.area_exited.connect(on_magnet_area_exited)
	collect_area.area_entered.connect(on_collect_area_entered)

func _physics_process(delta):
	for mana_drop: ManaDrop in magnetized_drops:
		if mana_drop:
			var direction = mana_drop.global_position.direction_to(global_position)
			mana_drop.global_position += direction * Constants.MAGNET_SPEED * delta

func on_collect_area_entered(mana_drop: ManaDrop) -> void:
	var index: int = magnetized_drops.find(mana_drop)
	if index != -1:
		magnetized_drops.remove_at(index)
	
	SFXPlayer.play_sfx("coin_collect")
	mana_drop_collected.emit(mana_drop.spell_data, mana_drop.amount_modifier)
	mana_drop_collected_no_data.emit()
	# match mana_drop.element:
	# 	Constants.Element.FIRE: print("Fire")
	# 	Constants.Element.WIND: print("Wind")
	# 	Constants.Element.WATER: print("Water")
	# 	Constants.Element.EARTH: print("Earth")
	# 	Constants.Element.LIGHT: print("Light")
	# 	Constants.Element.DARK: print("Dark")
	# 	Constants.Element.ARCANE: print("Arcane")
	mana_drop.queue_free()

func on_magnet_area_entered(mana_drop: ManaDrop) -> void:
	mana_drop.destination_reached = true
	magnetized_drops.append(mana_drop)

func on_magnet_area_exited(mana_drop: ManaDrop) -> void:
	var index: int = magnetized_drops.find(mana_drop)
	if index != -1:
		magnetized_drops.remove_at(index)
