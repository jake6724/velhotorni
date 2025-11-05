class_name PerkData
extends Resource

## One: Common, Two: Rare, Three: Epic, Four: Legendary
enum Rarity {One, Two, Three, Four}
enum Trigger {OneShot, OnWaveComplete, OnPlayerDamage, OnSpellManaPickup}

## This value will be modified base on the selected rarity. Ensure that only the lowest level value is inputted here.
@export var base_value: float = 0.0
@export var legendary: bool = false

var rarity: Rarity = Rarity.One