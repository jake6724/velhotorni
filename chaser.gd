extends CharacterBody2D

@export var target: Sprite2D

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var speed = 30

func _ready():
	await get_tree().physics_frame
	if target:
		nav_agent.target_position = target.global_position

func _physics_process(_delta):

	if target:
		nav_agent.target_position = target.global_position

	if nav_agent.is_navigation_finished():
		return

	velocity = global_position.direction_to(nav_agent.get_next_path_position()) * speed

	move_and_slide()