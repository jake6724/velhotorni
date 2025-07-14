class_name TutorialUI
extends Control

@onready var db_1: DialogueBox = %DialogueBox1
@onready var db_2: DialogueBox = %DialogueBox2
@onready var db_3: DialogueBox = %DialogueBox3
@onready var db_4: DialogueBox = %DialogueBox4
@onready var db_5: DialogueBox = %DialogueBox5
@onready var db_6: DialogueBox = %DialogueBox6
@onready var db_7: DialogueBox = %DialogueBox7
@onready var db_8: DialogueBox = %DialogueBox8
@onready var db_9: DialogueBox = %DialogueBox9
@onready var skip_button: Button = %SkipButton

var main_scene: PackedScene = load("res://scenes/Main.tscn")

var dbs: Array[DialogueBox]
var db_index = 0

func _ready():
	dbs = [db_1, db_2, db_3, db_4, db_5, db_6, db_7, db_8, db_9]
	for db in dbs:
		db.hide()	

	skip_button.pressed.connect(on_skip_button_pressed)

func on_skip_button_pressed():
	GameManager.level_index = 1
	GameManager.clear_level()
	GameManager.configure_active_level()
	SceneTransition.change_scene(main_scene)