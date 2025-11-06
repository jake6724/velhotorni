class_name PerkManager
extends Node

# External references required for connecting perk triggers
# All references manually set by Main
var player_perk_manager: PlayerPerkManager
var player_mana_drop_collector: ManaDropCollector
var player_hurtbox: PlayerHurtbox
var player_spell_spawner: PlayerSpellSpawner
var base_perk_manager: BasePerkManager
var player_spell_perk_manager: PlayerSpellPerkManager

var all_basic_perk_data: Array[PerkData] = [

]

## Perks that can be used this level. Does not include unusable elemental perks
## Populated at runtime **
var valid_basic_perk_data: Array[PerkData] = [
]

var rarity_counts: Dictionary[PerkData.Rarity, int] = {
	PerkData.Rarity.One: 0,
	PerkData.Rarity.Two: 0,
	PerkData.Rarity.Three: 0,
	PerkData.Rarity.Four: 0
}

var rarity_maxes: Dictionary[PerkData.Rarity, int] = {
	PerkData.Rarity.One: 4,
	PerkData.Rarity.Two: 3,
	PerkData.Rarity.Three: 2,
	PerkData.Rarity.Four: 2
}

var rarity_pool: Array
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var active_perks: Dictionary[PerkData, PerkData.Rarity]

const PERK_HAND_SIZE: int = 3

var test_perk_data: Array[PerkData] = [
	preload("res://data/perks/tower/basic/perk_data_tower_fire_upgrade_cost.tres"), 
	preload("res://data/perks/tower/basic/perk_data_tower_wind_upgrade_cost.tres"),
	preload("res://data/perks/tower/basic/perk_data_tower_water_upgrade_cost.tres"),
	preload("res://data/perks/tower/basic/perk_data_tower_earth_upgrade_cost.tres"),
	preload("res://data/perks/tower/basic/perk_data_tower_light_upgrade_cost.tres"),
	preload("res://data/perks/tower/basic/perk_data_tower_dark_upgrade_cost.tres"),
]

func _input(_event):
	if Input.is_action_just_pressed("x"):
		print("X Pressed")
		for perk_data: PerkData in test_perk_data:
			create_perk(perk_data)

func _ready():
	fill_rarity_pool()
	print(rarity_pool)

func create_perk(perk_data: PerkData) -> void:
	print("Calling create_perk()")
	# TODO: Rarity needs to be used here somehow

	var perk_data_copy: PerkData = perk_data.duplicate()
	var new_perk: Perk

	# Connect perk signal to the appropriate perk manager observer
	if perk_data is PerkDataPlayer:
		new_perk = PerkPlayer.new()
		new_perk.modify_stat_requested.connect(player_perk_manager.on_modify_stat_requested)
		new_perk.timed_modify_stat_requested.connect(player_perk_manager.on_timed_modify_stat_requested)

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

	configure_perk_trigger(new_perk)
	active_perks[perk_data] = new_perk.data.rarity

func configure_perk_trigger(new_perk: Perk) -> void:
	print("Calling configure_perk_trigger()")
	# Trigger one shots perks, connect remaining to proper signals
	# Triggers are independent of the PerkData type, all Perks can use the same triggers
	match new_perk.data.trigger:
		PerkData.Trigger.OneShot: new_perk.perk_action()
		PerkData.Trigger.OnWaveComplete: WaveManager.wave_completed.connect(new_perk.perk_action)
		PerkData.Trigger.OnSpellManaPickup: player_mana_drop_collector.mana_drop_collected_no_data.connect(new_perk.perk_action)
		PerkData.Trigger.OnPlayerDamage: player_hurtbox.hit_no_data.connect(new_perk.perk_action)
		PerkData.Trigger.OnPlayerSpellDamageDealt: player_spell_spawner.spell_damage_dealt.connect(new_perk.accumulate_spell_damage)

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
			PerkData.Rarity.One:
				remove_index = rarity_pool.find(PerkData.Rarity.Three)
			PerkData.Rarity.Two:
				remove_index = rarity_pool.find(PerkData.Rarity.Four)
			PerkData.Rarity.Three:
				remove_index = rarity_pool.find(PerkData.Rarity.One)
			PerkData.Rarity.Four:
				remove_index = rarity_pool.find(PerkData.Rarity.Two)
		if remove_index != -1:
			rarity_pool.remove_at(remove_index)

## Fill rarity pool with specified number of each rarity defined in `rarity_maxes`. 
## This pool will be reduced each wave.
func fill_rarity_pool() -> void:
	for rarity: PerkData.Rarity in rarity_maxes.keys():
		for i in range(rarity_maxes[rarity]):
			rarity_pool.append(rarity)

## Create a perk hand made up of basic perks. Active perks (same perk data, same rarity) will be excluded from this hand
## The 3 perks are picked in the order they appear in `valid_basic_perk_data`, which is shuffled at the start
func get_basic_perk_hand(rarity: PerkData.Rarity) -> void:
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
