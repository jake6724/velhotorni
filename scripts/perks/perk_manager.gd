class_name PerkManager
extends Node

# External references
# All references manually set by Main
# TODO: At this point just give it the fucking player
var player_perk_manager: PlayerPerkManager
var player_mana_drop_collector: ManaDropCollector
var player_hurtbox: PlayerHurtbox
var player_spell_spawner: PlayerSpellSpawner
var base_perk_manager: BasePerkManager
var player_spell_perk_manager: PlayerSpellPerkManager
var player_special: PlayerSpecial
var perk_ui: PerkUI

## Global for this class, used to track rarity between function calls from main
var current_perk_hand_rarity: PerkData.Rarity

## Perks that can be used this level. Does not include unusable elemental perks
## Populated at runtime
## TODO: Remove unusable elements
var valid_basic_perk_data: Array[PerkData] = []
var valid_legendary_perk_data: Array[PerkData] = []

var rarity_counts: Dictionary[PerkData.Rarity, int] = {
	PerkData.Rarity.ONE: 0,
	PerkData.Rarity.TWO: 0,
	PerkData.Rarity.THREE: 0,
	PerkData.Rarity.FOUR: 0
}

var rarity_maxes: Dictionary[PerkData.Rarity, int] = {
	PerkData.Rarity.ONE: 4,
	PerkData.Rarity.TWO: 3,
	PerkData.Rarity.THREE: 2,
	PerkData.Rarity.FOUR: 2,
}

# For testing
# var rarity_maxes: Dictionary[PerkData.Rarity, int] = {
# 	PerkData.Rarity.ONE: 1,
# 	PerkData.Rarity.TWO: 0,
# 	PerkData.Rarity.THREE: 0,
# 	PerkData.Rarity.FOUR: 0,
# }

var rarity_pool: Array
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var active_perks: Dictionary[PerkData, PerkData.Rarity]

const PERK_HAND_SIZE: int = 3

var test_perk_data: Array[PerkData] = [
	preload("res://data/perks/tower/basic/perk_data_tower_burn.tres"), 
	preload("res://data/perks/tower/basic/perk_data_tower_burn.tres"), 
	preload("res://data/perks/tower/basic/perk_data_tower_burn.tres"), 
]

# func _input(_event):
# 	if Input.is_action_just_pressed("x"):
# 		for perk_data: PerkData in test_perk_data:
# 			create_perk(perk_data)

func initialize(_perk_data_pool: PerkDataPool, player_spells: PlayerSpells, player_build: PlayerBuild) -> void:
	var perk_data_unfiltered: Array[PerkData] = _perk_data_pool.perks
	var perk_data_filtered: Array[PerkData] = []

	# Filter out perks with inactive elements
	var active_spell_elements: Array[Constants.Element] = player_spells.get_active_elements()
	var active_tower_elements: Array[Constants.Element] = player_build.tower_element_options
	var active_tower_debuff_types: Array[Debuff.Type] = player_build.get_active_debuff_types()

	# DEBUG PRINT
	# print("Spell Elements:")
	# for element in active_spell_elements:
	# 	print(Constants.get_element_text(element))
	# print("")
	# print("Tower Elements: ")
	# for element in active_tower_elements:
	# 	print(Constants.get_element_text(element))
	# print("")
	# print("Tower debuff types: ")
	# for debuff_type in active_tower_debuff_types:
	# 	print(debuff_type)

	var valid_perk_data_spell: Array[PerkDataSpell] = filter_spell_perks(perk_data_unfiltered, active_spell_elements)
	var valid_perk_data_tower: Array[PerkDataTower] = filter_tower_perks(perk_data_unfiltered, active_tower_elements, active_tower_debuff_types)
	var valid_perk_data_player: Array[PerkDataPlayer] = filter_player_perks(perk_data_unfiltered)
	var valid_perk_data_base: Array[PerkDataBase] = filter_base_perks(perk_data_unfiltered)

	perk_data_filtered.append_array(valid_perk_data_spell)
	perk_data_filtered.append_array(valid_perk_data_tower)
	perk_data_filtered.append_array(valid_perk_data_player)
	perk_data_filtered.append_array(valid_perk_data_base)

	# print("perk_data_filtered.size(): ", perk_data_filtered.size())
	# Sort into legendary or basic pools
	for perk_data: PerkData in perk_data_filtered:
		if perk_data.legendary:
			valid_legendary_perk_data.append(perk_data)
		else:
			valid_basic_perk_data.append(perk_data)

	
	fill_rarity_pool()

func filter_spell_perks(perk_data_unfiltered: Array[PerkData], active_spell_elements: Array[Constants.Element]) -> Array[PerkDataSpell]:
	var perk_data_spell_filtered: Array[PerkDataSpell]
	for perk_data: PerkData in perk_data_unfiltered:
		if perk_data is PerkDataSpell:
			if "element" in perk_data:
				if perk_data.element == Constants.Element.NONE or perk_data.element in active_spell_elements:
					perk_data_spell_filtered.append(perk_data)
					# print("Adding spell perk. Element = ", Constants.get_element_text(perk_data.element))
			else:
				perk_data_spell_filtered.append(perk_data)

	return perk_data_spell_filtered

func filter_tower_perks(perk_data_unfiltered: Array[PerkData], active_tower_elements: Array[Constants.Element], active_tower_debuff_types) -> Array[PerkDataTower]:
	var perk_data_tower_filtered: Array[PerkDataTower]
	for perk_data: PerkData in perk_data_unfiltered:
		if perk_data is PerkDataTower:
			# Add all towers perks with active elements
			if perk_data.element in active_tower_elements:
				perk_data_tower_filtered.append(perk_data)
				#print("Adding tower perk under element. Element = ", Constants.get_element_text(perk_data.element))
			# Add all tower perks with active debuffs
			if perk_data.debuff in active_tower_debuff_types:
				perk_data_tower_filtered.append(perk_data)
				#print("Adding tower perk under debuff. Debuff = ", Constants.get_debuff_type_text(perk_data.debuff))

			if perk_data.element == Constants.Element.NONE and perk_data.debuff == Debuff.Type.NONE:
				perk_data_tower_filtered.append(perk_data)

	return perk_data_tower_filtered

func filter_player_perks(perk_data_unfiltered: Array[PerkData]) -> Array[PerkDataPlayer]:
	var perk_data_player_filtered: Array[PerkDataPlayer]
	for perk_data: PerkData in perk_data_unfiltered:
		if perk_data is PerkDataPlayer:
			perk_data_player_filtered.append(perk_data)
	return perk_data_player_filtered

func filter_base_perks(perk_data_unfiltered: Array[PerkData]) -> Array[PerkDataBase]:
	var perk_data_base_filtered: Array[PerkDataBase]
	for perk_data: PerkData in perk_data_unfiltered:
		if perk_data is PerkDataBase:
			perk_data_base_filtered.append(perk_data)
	return perk_data_base_filtered

func create_perk(perk_data: PerkData) -> void:
	var perk_data_copy: PerkData = perk_data.duplicate()
	var new_perk: Perk

	# Connect perk signal to the appropriate perk manager observer
	if perk_data is PerkDataPlayer:
		new_perk = PerkPlayer.new()
		new_perk.modify_stat_requested.connect(player_perk_manager.on_modify_stat_requested)
		new_perk.timed_modify_stat_requested.connect(player_perk_manager.on_timed_modify_stat_requested)
		new_perk.player_aoe_requested.connect(player_perk_manager.on_player_aoe_requested)

	elif perk_data is PerkDataBase:
		new_perk = PerkBase.new()
		new_perk.modify_stat_requested.connect(base_perk_manager.on_modify_stat_requested)

	elif perk_data is PerkDataTower:
		new_perk = PerkTower.new()
		new_perk.modify_stat_requested.connect(TowerGlobalData.on_modify_stat_requested)

	elif perk_data is PerkDataSpell:
		new_perk = PerkSpell.new()
		new_perk.modify_stat_requested.connect(player_spell_perk_manager.on_modify_stat_requested)

	new_perk.data = perk_data_copy
	new_perk.data.rarity = current_perk_hand_rarity
	new_perk.set_rarity_value()

	configure_perk_trigger(new_perk)
	active_perks[perk_data] = new_perk.data.rarity

func configure_perk_trigger(new_perk: Perk) -> void:
	# Trigger ONE shots perks, connect remaining to proper signals
	# Triggers are independent of the PerkData type, all Perks can use the same triggers
	match new_perk.data.trigger:
		PerkData.Trigger.OneShot: new_perk.perk_action()
		PerkData.Trigger.OnWaveComplete: WaveManager.wave_completed.connect(new_perk.perk_action)
		PerkData.Trigger.OnSpellManaPickup: player_mana_drop_collector.mana_drop_collected_no_data.connect(new_perk.perk_action)
		PerkData.Trigger.OnPlayerDamage: player_hurtbox.hit_no_data.connect(new_perk.perk_action)
		PerkData.Trigger.OnPlayerSpellDamageDealt: player_spell_spawner.spell_damage_dealt.connect(new_perk.accumulate_spell_damage)
		PerkData.Trigger.PLAYER_SPECIAL: player_special.player_special_activated.connect(new_perk.perk_action)

## Choose a valid rarity from `rarity_pool`. Automatically calls update_rarity_data() to keep `rarity_pool` valid.
func get_rarity() -> PerkData.Rarity:
	var selected_rarity: PerkData.Rarity = rarity_pool.pick_random()
	update_rarity_data(selected_rarity)
	return selected_rarity

## Remove rarities from `rarity_pool`, and remove additional rarities if needed
func update_rarity_data(selected_rarity: PerkData.Rarity) -> void:
	rarity_pool.remove_at(rarity_pool.find(selected_rarity)) # Remove selected rarity from the pool
	rarity_counts[selected_rarity] += 1

	# Remove an additional rarity from the pool if a rarity max has been reached
	if rarity_counts[selected_rarity] == rarity_maxes[selected_rarity]:
		var remove_index: int
		match selected_rarity:
			PerkData.Rarity.ONE:
				remove_index = rarity_pool.find(PerkData.Rarity.THREE)
			PerkData.Rarity.TWO:
				remove_index = rarity_pool.find(PerkData.Rarity.FOUR)
			PerkData.Rarity.THREE:
				remove_index = rarity_pool.find(PerkData.Rarity.ONE)
			PerkData.Rarity.FOUR:
				remove_index = rarity_pool.find(PerkData.Rarity.TWO)
		if remove_index != -1:
			rarity_pool.remove_at(remove_index)

## Fill rarity pool with specified number of each rarity defined in `rarity_maxes`.
## This pool will be reduced each wave.
func fill_rarity_pool() -> void:
	for rarity: PerkData.Rarity in rarity_maxes.keys():
		for i in range(rarity_maxes[rarity]):
			rarity_pool.append(rarity)

func get_perk_hand() -> Array[PerkData]:
	var perk_hand: Array[PerkData] = []
	current_perk_hand_rarity = get_rarity()
	if current_perk_hand_rarity != PerkData.Rarity.FOUR:
		perk_hand = get_basic_perk_hand(current_perk_hand_rarity)

	else:
		perk_hand = get_legendary_perk_hand()
	#print("Perk hand: ", perk_hand)
	return perk_hand

## Create a perk hand made up of basic perks. Active perks (same perk data, same rarity) will be excluded from this hand
## The 3 perks are picked in the order they appear in `valid_basic_perk_data`, which is shuffled at the start
func get_basic_perk_hand(rarity: PerkData.Rarity) -> Array[PerkData]:
	valid_basic_perk_data.shuffle()
	var perk_hand: Array[PerkData] = []
	var count: int = 0

	for perk_data: PerkData in valid_basic_perk_data:
		## HMMMMMM
		var is_perk_active: bool = active_perks.has(perk_data)
		var is_rarity_active: bool = active_perks.get(perk_data, null) == rarity

		if not is_perk_active and not is_rarity_active: # This perk with this rarity has NOT been selected yet 
			perk_hand.append(perk_data)
			count += 1
			if count >= PERK_HAND_SIZE:
				break
		else:
			continue

	return perk_hand

func get_legendary_perk_hand() -> Array[PerkData]:
	valid_legendary_perk_data.shuffle()
	var perk_hand: Array[PerkData]
	for i in range(3):
		perk_hand.append(valid_legendary_perk_data.pop_front())
	return perk_hand
