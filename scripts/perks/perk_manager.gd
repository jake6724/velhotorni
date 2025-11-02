class_name PerkManager
extends Node

var player_perk_manager: PlayerPerkManager # Set manually by Main

var test_perk_data_player: PerkDataPlayer = preload("res://data/perks/player/perk_data_player_move_speed.tres")

func create_new_perk(perk_data: PerkData) -> void:
	var perk_data_copy: PerkData = perk_data.duplicate()
	var new_perk: Perk

	if perk_data is PerkDataPlayer:
		print("pass")
		new_perk = PerkPlayer.new()
		new_perk.modify_stat_requested.connect(player_perk_manager.on_modify_stat_requested)

	new_perk.data = perk_data_copy

	if new_perk.data.trigger == PerkData.Trigger.OneShot:
		new_perk.perk_action()
		
func _input(_event):
	if Input.is_action_just_pressed("x"):
		create_new_perk(test_perk_data_player)
