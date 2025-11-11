class_name PerkData
extends Resource

## One: Common, Two: Rare, Three: Epic, Four: Legendary
enum Rarity {ONE, TWO, THREE, FOUR}
enum Trigger {OneShot, OnWaveComplete, OnPlayerDamage, OnSpellManaPickup, OnPlayerSpellDamageDealt}

## This value will be modified base on the selected rarity. Ensure that only the lowest level value is inputted here.
@export var base_value: float = 0.0
@export var legendary: bool = false
@export_category("Perk UI")
@export var perk_icon: AtlasTexture
@export var perk_name: String
@export var perk_desc: String

var rarity: Rarity = Rarity.ONE