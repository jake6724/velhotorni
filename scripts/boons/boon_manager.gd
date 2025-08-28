class_name BoonManager
extends Node

signal boon_connected

func connect_boon(_new_boon: Boon) -> void:
	_new_boon.value = calc_boon_modified_value(_new_boon)
	boon_connected.emit(_new_boon)

func add_boon(boon: Boon) -> void:
	add_child(boon)

func expire_boon_by_source(match_source: BoonArea) -> void:
	for child in get_children():
		var boon: Boon = child as Boon
		if boon.source == match_source:
			boon.boon_expired.emit()

func calc_boon_modified_value(boon: Boon) -> float:
	return (boon.value / (2 ** get_boon_count_by_type(boon.type)))

func get_boon_count_by_type(match_type: Boon.Type) -> int:
	var count: int = 0 
	for child in get_children():
		var boon: Boon = child as Boon
		if boon and boon.type == match_type:
			count += 1
	return count

## Called manually by Enemy
func on_boon_expired(expired_boon: Boon) -> void:
	remove_child(expired_boon)
	expired_boon.queue_free()