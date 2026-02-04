class_name ManaDropManager
extends Node

var player: PlayerCharacter

var mana_drop_scene: PackedScene = preload("res://scenes/player/ManaDrop.tscn")
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var selected_spell_mana_chances: Array[Array] = []
var spell_mana_drop_perk_bonus: float = 0.0

const JITTER: float = 7
const MANA_DROP_MOVE_SPEED: float = 150
const DESTINATION_THRESHOLD: Vector2 = Vector2(5,5)

func _ready():
	WaveManager.wave_completed.connect(on_wave_complete)

func initialize(player_spells: PlayerSpells) -> void:
	for spell: SpellData in player_spells.spells.array:
		selected_spell_mana_chances.append([spell, spell.mana_drop_chance]) # Chance value doesn't matter if they are all the same (in the weighted random algo)

func _physics_process(delta):
	for child: ManaDrop in get_children():
		if child.wave_complete_collect:
			var direction: Vector2 = child.global_position.direction_to(player.global_position)
			child.global_position += direction * MANA_DROP_MOVE_SPEED * delta

		if not child.destination_reached:
			child.global_position += child.global_position.direction_to(child.destination) * MANA_DROP_MOVE_SPEED * delta
			if abs(child.global_position - child.destination) < DESTINATION_THRESHOLD:
				child.destination_reached = true

func on_enemy_died(_enemy_death_global_pos: Vector2, _drop_chance: float, _drop_amount_modifier) -> void:
	spawn_mana_drop(_enemy_death_global_pos, _drop_chance, _drop_amount_modifier)

func spawn_mana_drop(_enemy_death_global_pos: Vector2, _drop_chance: float, _drop_amount_modifier) -> void:
	_drop_chance = _drop_chance + spell_mana_drop_perk_bonus
	spawn_mana_drop_helper(_enemy_death_global_pos, _drop_chance, _drop_amount_modifier)

## Create new mana drop and configure with ammo type and amount modifier
## Recursively call until drop chance has been used up
func spawn_mana_drop_helper(_spawn_pos: Vector2, _drop_chance: float, _drop_amount_modifier: float) -> void:
	var roll: float = rng.randf()
	if roll <= _drop_chance:
		var new_mana_drop: ManaDrop = mana_drop_scene.instantiate()
		new_mana_drop.global_position = _spawn_pos
		call_deferred("add_child",new_mana_drop)
		new_mana_drop.destination = calc_destination(_spawn_pos)

		# Configure mana drop and select spell mana type
		new_mana_drop.spell_data = Constants.get_weighted_random(selected_spell_mana_chances)
		new_mana_drop.amount_modifier = _drop_amount_modifier

		_drop_chance -= 1.0
		if _drop_chance > 0.0:
			spawn_mana_drop_helper(_spawn_pos, _drop_chance, _drop_amount_modifier)

func calc_destination(_global_pos) -> Vector2:
	var jx: float = rng.randf_range(-JITTER, JITTER)
	var jy: float = rng.randf_range(-JITTER, JITTER)
	var jitter_offset: Vector2 = Vector2(jx, jy)
	return _global_pos + jitter_offset

## Observes PlayerSpellPerkManager.spell_mana_drop_perk_bonus_incremented. Connected in Main
## The value recieved is added to the total stored in this class
func on_spell_mana_drop_perk_bonus_incremented(_increment: float) -> void:
	spell_mana_drop_perk_bonus += _increment

func on_spell_mana_drop_chance_multiplier_added(spell_data_list: Array[SpellData], _multiplier: float) -> void:
	for spell_data: SpellData in spell_data_list:
		for pair in selected_spell_mana_chances:
			if spell_data == pair[0]:
				pair[1] *= _multiplier

## Observes CoinManager.gd's tower_mana_spawned signal. Used for perks which convert tower mana into spell mana
func on_spell_mana_spawn_requested(_global_pos) -> void:
	spawn_mana_drop(_global_pos, 1.0, 1.0)

func on_wave_complete() -> void:
	gather_wave_complete_mana_drops()

func gather_wave_complete_mana_drops() -> void:
	await get_tree().create_timer(.5).timeout
	for child in get_children():
		child.destination_reached = true
		child.wave_complete_collect = true