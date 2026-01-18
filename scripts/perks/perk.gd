class_name Perk
extends Object

# This data has been duplicated already;
# changes can be made to data without affecting other instances
var data: PerkData

func perk_action() -> void:
	pass

func set_rarity_value() -> void:
	match data.rarity:
		PerkData.Rarity.ONE: pass
		PerkData.Rarity.TWO: data.base_value *= 2
		PerkData.Rarity.THREE: data.base_value *= 4
		PerkData.Rarity.FOUR: pass