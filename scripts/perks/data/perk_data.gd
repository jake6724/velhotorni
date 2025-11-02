class_name PerkData
extends Resource

enum Rarity {Common, Rare, Epic}
enum Trigger {OneShot, OnWaveComplete, OnPlayerDamage}

## This value will be modified base on the selected rarity. Ensure that only the lowest level value is inputted here.
@export var base_value: float = 0.0

var rarity: Rarity = Rarity.Common