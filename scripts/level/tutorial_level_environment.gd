class_name TutorialLevelEnvironment
extends LevelEnvironment

@onready var ui: TutorialUI = $UI/TutorialUI
@onready var main: Main = get_tree().root.get_node("Main")

var is_paused: bool = false
var active_db: DialogueBox
var enemy_count: int = 0

func _ready():
	# Connect to EnemySpawner
	EnemySpawner.wave_complete.connect(on_wave_complete)
	EnemySpawner.enemy_spawned.connect(on_enemy_spawned)

	# Disable pausing
	process_mode = Node.PROCESS_MODE_ALWAYS

	active_db = ui.db_1
	active_db.show()

func on_enemy_spawned():
	enemy_count += 1
	if enemy_count == 4:
		show_dialogue()
		main.pause_game()

	if enemy_count == 5:
		ui.skip_button.show()

	if enemy_count == 19:
		show_dialogue()
		main.pause_game()

	if enemy_count == 35:
		show_dialogue()
		main.pause_game()

	if enemy_count == 55:
		show_dialogue()
		main.pause_game()	

func on_wave_complete():
	show_dialogue()

func show_dialogue():
	ui.db_index += 1
	if ui.db_index < ui.dbs.size():
		active_db = ui.dbs[ui.db_index]
	else:
		active_db = null

	if active_db:
		active_db.show()
		ui.mouse_filter = Control.MOUSE_FILTER_STOP

func _input(_event):
	if Input.is_action_just_pressed("spacebar"):
		main.unpause_game()
		if active_db:
			active_db.hide()
		ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
