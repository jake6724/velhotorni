class_name HexArea
extends Area2D

var hex_data_list: Array[HexData] = []

## Called directly by parent tower
func initialize() -> void:
	if not is_connected("area_entered", on_area_entered): area_entered.connect(on_area_entered) # Only look for towers if a hex to apply is set
	if not is_connected("area_exited", on_area_exited): area_exited.connect(on_area_exited)

func uninitialize() -> void:
	if is_connected("area_entered", on_area_entered): disconnect("area_entered", on_area_entered)
	if is_connected("area_exited", on_area_exited): disconnect("area_exited", on_area_exited)

func on_area_entered(intruder) -> void:
	print("HexArea entered")
	if intruder.owner != owner and intruder.owner is Tower:	
		print("Intruder was Tower")
		apply_hex_to_tower(intruder.owner.hex_manager)

func apply_hex_to_tower(tower_hex_manager: HexManager) -> void:
	for hex_data: HexData in hex_data_list:
		tower_hex_manager.add_hex(hex_data.duplicate(true), self)
		tower_hex_manager.prioritize_hexes()

func on_area_exited(intruder) -> void:
	if intruder.owner != owner and intruder.owner is Tower:	
		var tower_hex_manager: HexManager = intruder.owner.hex_manager
		var active_hexes: Array[Hex] = tower_hex_manager.get_hexes_by_source(self)
		for hex: Hex in active_hexes:
			tower_hex_manager.remove_hex(hex)
		tower_hex_manager.prioritize_hexes()
