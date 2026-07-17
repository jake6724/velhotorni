class_name TowerTargeting
extends Node

func get_active_target(target_priority: Tower.TargetPriority, in_range_targets:Array[Enemy]) -> Enemy:
	match target_priority:
		Tower.TargetPriority.FIRST: return get_first_target(in_range_targets)
		Tower.TargetPriority.LAST: return get_last_target(in_range_targets)
		Tower.TargetPriority.HIGHEST: return get_highest_target(in_range_targets)
		Tower.TargetPriority.LOWEST: return get_lowest_target(in_range_targets)
		_: return null

func get_first_target(in_range_targets:Array[Enemy]) -> Enemy:
	var max_progress: float = -INF
	var selected_target: Enemy = null
	if in_range_targets.size() != 0:
		for enemy: Enemy in in_range_targets:
			if enemy is FlyingEnemy: # Prioritize flying enemies!
				return enemy
			if enemy.path_follow.progress_ratio > max_progress:
				max_progress = enemy.path_follow.progress_ratio
				selected_target = enemy
		return selected_target
	else: 
		return null

func get_last_target(in_range_targets:Array[Enemy]) -> Enemy:
	var min_progress: float = INF
	var selected_target: Enemy = null
	if in_range_targets.size() != 0:
		for enemy: Enemy in in_range_targets:
			if enemy.path_follow.progress_ratio < min_progress:
				min_progress = enemy.path_follow.progress_ratio
				selected_target = enemy
		return selected_target
	else: 
		return null

func get_highest_target(in_range_targets:Array[Enemy]) -> Enemy:
	var max_health: float = -INF
	var selected_target: Enemy = null
	if in_range_targets.size() != 0:
		for enemy: Enemy in in_range_targets:
			if enemy.health > max_health:
				max_health = enemy.health
				selected_target = enemy
		return selected_target
	else: 
		return null

func get_lowest_target(in_range_targets:Array[Enemy]) -> Enemy:
	var min_health: float = INF
	var selected_target: Enemy = null
	if in_range_targets.size() != 0:
		for enemy: Enemy in in_range_targets:
			if enemy.health < min_health:
				min_health = enemy.health
				selected_target = enemy
		return selected_target
	else: 
		return null

func get_no_target() -> void:
	return
