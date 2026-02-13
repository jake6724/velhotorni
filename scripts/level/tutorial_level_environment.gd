class_name TutorialLevelEnvironment
extends LevelEnvironment

@onready var dbox_parent: Control = %DialogueParent

@onready var dbox_1: NinePatchRect = %Dialogue1
@onready var dbox_2: NinePatchRect = %Dialogue2
@onready var dbox_3: NinePatchRect = %Dialogue3
@onready var dbox_4: NinePatchRect = %Dialogue4

# @onready var dboxes: Array[NinePatchRect] = [dbox_1, dbox_2, dbox_3, dbox_4]

var dboxes: Array[NinePatchRect] = []

var dbox_index: int = 0

@onready var trigger_area_parent: Node = %TriggerAreaParent
var trigger_areas: Array[TriggerArea] = []

var prev_dbox: NinePatchRect

var towers_placed_count: int = 0
var is_first_time_in_build: bool = true
var is_tower_placed_and_build_exited: bool = false

var player: PlayerCharacter

func child_custom_ready() -> void:
	# Get all dboxes
	for child in dbox_parent.get_children():
		if child is NinePatchRect:
			dboxes.append(child)

	# Hide all dboxes
	for dbox in dboxes:
		dbox.hide()

	# WaveManager.wave_completed.connect(show_current_dbox)
	# WaveManager.wave_started.connect(hide_current_dbox)
	WaveManager.wave_completed.connect(on_wave_completed)
	WaveManager.wave_started.connect(on_wave_started)
	
	for child in trigger_area_parent.get_children():
		if child is TriggerArea:
			trigger_areas.append(child)
			child.dialogue_triggered.connect(show_current_dbox)
			child.wave_started_allowed.connect(allow_wave_start)

	# This is not a great loophole, but should be fine for just the tutorial
	player = LevelManager.main.player_character 
	player.player_build.tower_mana_spent.connect(on_player_tower_mana_spent)
	player.player_input.switch_player_mode_pressed.connect(on_player_mode_switched)

	can_start_wave = false

func hide_current_dbox() -> void:
	dboxes[dbox_index].hide()

func show_current_dbox() -> void:
	dboxes[dbox_index].show()

func cycle_dboxes() -> void:
	if dbox_index < dboxes.size():
		dboxes[dbox_index].hide()
		dbox_index += 1
		if dbox_index < dboxes.size():
			dboxes[dbox_index].show()

func on_wave_started() -> void:
	match WaveManager.wave_index:
		0: cycle_dboxes()
		1: cycle_dboxes()
		2: cycle_dboxes()
		3: cycle_dboxes()
		4: cycle_dboxes()
		_: pass

func on_wave_completed() -> void:
	# Wave index is updated before this is called; always incremented intended wave by 1
	# For example, if you want to do something after wave 0 is complete, match to wave 1
	match WaveManager.wave_index:
		1:
			cycle_dboxes()
			can_start_wave = false

		2: cycle_dboxes()
		3: cycle_dboxes()
		4: cycle_dboxes()
		5: cycle_dboxes()
		_: pass

func on_player_tower_mana_spent(_value) -> void:
	towers_placed_count += 1
	match towers_placed_count:
		1: 
			cycle_dboxes()
		_: pass

func on_player_mode_switched() -> void:
	print("Tutorial calling on_player_mode_switched!")
	if is_first_time_in_build: 
		is_first_time_in_build = false
		cycle_dboxes()
	
	else:
		if not is_tower_placed_and_build_exited:
			if towers_placed_count == 1:
				cycle_dboxes()
				is_tower_placed_and_build_exited = true
				can_start_wave = true

func allow_wave_start(_value) -> void:
	can_start_wave = _value
