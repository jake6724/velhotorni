class_name ManaDropManager
extends Node

var mana_drop_scene: PackedScene = preload("res://scenes/player/ManaDrop.tscn")
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var selected_spell_mana_chances: Array[Array] = []

const JITTER: float = 7
const MANA_DROP_MOVE_SPEED: float = 150
const DESTINATION_THRESHOLD: Vector2 = Vector2(5,5)

func initialize(player_spells: PlayerSpells) -> void:
	for spell: SpellData in player_spells.spells.array:
		selected_spell_mana_chances.append([spell, spell.mana_drop_chance]) # Chance value doesn't matter if they are all the same (in the weighted random algo)

func _physics_process(delta):
	for child: ManaDrop in get_children():
		if not child.destination_reached:
			child.global_position += child.global_position.direction_to(child.destination) * MANA_DROP_MOVE_SPEED * delta
			if abs(child.global_position - child.destination) < DESTINATION_THRESHOLD:
				child.destination_reached = true

func on_enemy_died(_enemy_death_global_pos: Vector2, _drop_chance: float, _drop_amount_modifier) -> void:
	var roll: float = rng.randf()
	if roll <= _drop_chance:
		spawn_mana_drop(_enemy_death_global_pos, _drop_amount_modifier)
		_drop_chance -= 1.0
		if _drop_chance > 0.0:
			on_enemy_died(_enemy_death_global_pos, _drop_chance, _drop_amount_modifier)

## Create new mana drop and configure with ammo type and amount modifier
func spawn_mana_drop(_spawn_pos: Vector2, _drop_amount_modifier: float) -> void:
	var new_mana_drop: ManaDrop = mana_drop_scene.instantiate()
	new_mana_drop.global_position = _spawn_pos
	call_deferred("add_child",new_mana_drop)
	new_mana_drop.destination = calc_destination(_spawn_pos)

	# Configure mana drop and select spell mana type
	new_mana_drop.spell_data = Constants.get_weighted_random(selected_spell_mana_chances)
	new_mana_drop.amount_modifier = _drop_amount_modifier

func calc_destination(_global_pos) -> Vector2:
	var jx: float = rng.randf_range(-JITTER, JITTER)
	var jy: float = rng.randf_range(-JITTER, JITTER)
	var jitter_offset: Vector2 = Vector2(jx, jy)
	return _global_pos + jitter_offset
