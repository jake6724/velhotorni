class_name TowerEvolveMenuUIText
extends Object

var evolve_desc_lava: String = "Powerful AOE attacks with burn"
var evolve_desc_plasma: String = "Rapid-fire with piercing 2 and burn"
var evolve_desc_storm: String = "Massive knockback with pierce 10"
var evolve_desc_lightning: String = "Chain lightning bullets which stun enemies"
var evolve_desc_ice: String = "Freeze enemies, pierce 3"
var evolve_desc_flood: String = "Rapid-fire with slow"
var evolve_desc_mud: String = "AOE attacks with slow"
var evolve_desc_crystal: String = "Enemies killed by this tower may drop additional gems. Pierce 3"
var evolve_desc_spirit: String = "Buffs allied range, speed, and damage"
var evolve_desc_sun: String = "Long-range, high-damage"
var evolve_desc_curse: String = "AOE explosion bullets with weaken"
var evolve_desc_void: String = "Extremely fast attacks with weaken"
var evolve_desc_options: Dictionary[Constants.Element, String] = {
	Constants.Element.LAVA: evolve_desc_lava,
	Constants.Element.PLASMA: evolve_desc_plasma,
	Constants.Element.STORM: evolve_desc_storm,
	Constants.Element.LIGHTNING: evolve_desc_lightning,
	Constants.Element.ICE: evolve_desc_ice,
	Constants.Element.FLOOD: evolve_desc_flood,
	Constants.Element.MUD: evolve_desc_mud,
	Constants.Element.CRYSTAL: evolve_desc_crystal,
	Constants.Element.SPIRIT: evolve_desc_spirit,
	Constants.Element.SUN: evolve_desc_sun,
	Constants.Element.CURSE: evolve_desc_curse,
	Constants.Element.VOID: evolve_desc_void,
}

var info_locked: String = "Evolve Token Required!"
var info_unlocked: String = "Choose an evolution"
