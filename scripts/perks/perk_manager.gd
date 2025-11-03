class_name PerkManager
extends Node

var player_perk_manager: PlayerPerkManager # Set manually by Main

var test_perk_data_player: PerkDataPlayer = preload("res://data/perks/player/perk_data_player_move_speed.tres")

var all_basic_perk_data: Array[PerkData] = [
	test_perk_data_player
]

## Perks that can be used this level. Does not include unusable elemental perks
## Populated at runtime **
var valid_basic_perk_data: Array[PerkData] = [
	preload("res://data/perks/1.tres"),
	preload("res://data/perks/2.tres"),
	preload("res://data/perks/3.tres"),
	preload("res://data/perks/4.tres"),
	preload("res://data/perks/5.tres"),
	preload("res://data/perks/6.tres"),
	preload("res://data/perks/7.tres"),
	preload("res://data/perks/8.tres"),
	preload("res://data/perks/9.tres"),
	preload("res://data/perks/10.tres"),
	preload("res://data/perks/11.tres"),
	preload("res://data/perks/12.tres"),
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

func _input(_event):
	if Input.is_action_just_pressed("x"):
		# print(get_rarity())
		# print(rarity_pool)
		# create_perk(test_perk_data_player)

		get_basic_perk_hand(get_rarity())

func _ready():
	fill_rarity_pool()
	print(rarity_pool)

func create_perk(perk_data: PerkData) -> void:
	var perk_data_copy: PerkData = perk_data.duplicate()
	var new_perk: Perk

	if perk_data is PerkDataPlayer:
		new_perk = PerkPlayer.new()
		new_perk.modify_stat_requested.connect(player_perk_manager.on_modify_stat_requested)

	new_perk.data = perk_data_copy

	if new_perk.data.trigger == PerkData.Trigger.OneShot:
		new_perk.perk_action()

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
