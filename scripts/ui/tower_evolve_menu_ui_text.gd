class_name TowerEvolveMenuUIText
extends Object

var evolve_desc_lava: String = "Evolve into a lava tower"
var evolve_desc_plasma: String = "Evolve into a plasma tower"
var evolve_desc_storm: String = "Evolve into a storm tower"
var evolve_desc_lightning: String = "Evolve into a lightning tower"
var evolve_desc_ice: String = "Evolve into an ice tower"
var evolve_desc_flood: String = "Evolve into a flood tower"
var evolve_desc_mud: String = "Evolve into a mud tower"
var evolve_desc_crystal: String = "Evolve into a crystal tower"
var evolve_desc_spirit: String = "Evolve into a spirit tower"
var evolve_desc_sun: String = "Evolve into a sun tower"
var evolve_desc_curse: String = "Evolve into a curse tower"
var evolve_desc_void: String = "Evolve into a void tower"
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
