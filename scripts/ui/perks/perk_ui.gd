class_name PerkUI
extends Control

@onready var top_letterbox: TextureRect = %TopLetterbox
@onready var bottom_letterbox: TextureRect = %BottomLetterbox
@onready var title_label: Label = %TitleLabel
@onready var instruction_label: Label = %InstructionLabel
@onready var header: Control = %Header
@onready var candles: Control = %Candles

@onready var perk_card_1: PerkCard = %PerkCard1
@onready var perk_card_2: PerkCard = %PerkCard2
@onready var perk_card_3: PerkCard = %PerkCard3

var main: Main # Set manually by main. Used to unpause game
var player_input: PlayerInput # Used for move_input

var perk_cards: Array = []
var perk_cards_linked: DoublyLinkedList
var curr_perk_card: PerkCard:
	set(value):
		if curr_perk_card:
			# Reset old curr_perk_card
			curr_perk_card.unhighlight()
			curr_perk_card.unpop_up()
		# Configure new curr_perk_card
		curr_perk_card = value
		curr_perk_card.highlight()
		curr_perk_card.pop_up()

var candles_array: Array = []
var candle_reset_position: Dictionary[TextureRect, Vector2] = {}

# Animation Vars
var letterbox_speed: float = .20
var bounce_speed: float = .05
var delay_between_cards: float = 0
var candle_speed: float = .05
var candle_delay: float = .05

var move_input_x: float

signal perk_selected

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	perk_cards = [perk_card_1, perk_card_2, perk_card_3]
	candles_array = [%Candle1, %Candle2, %Candle3, %Candle4]
	for candle: TextureRect in candles_array:
		candle_reset_position[candle] = candle.global_position

	# Configure card linked list
	perk_cards_linked = DoublyLinkedList.new(perk_cards)
	perk_cards_linked.switch_right()
	curr_perk_card = perk_cards_linked.head.value
	perk_cards_linked.print_list()

func _process(_delta):
	move_input_x = Input.get_axis("move_left", "move_right")
	print(move_input_x)
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
		if move_input_x > .01:
			switch_selected_card(1)
		elif move_input_x < -.01:
			switch_selected_card(-1)

func switch_selected_card(switch_direction: int) -> void:
	if switch_direction == -1: # Switch left
		perk_cards_linked.switch_left()
		curr_perk_card = perk_cards_linked.head.value
	elif switch_direction == 1: # Switch right
		perk_cards_linked.switch_right()
		curr_perk_card = perk_cards_linked.head.value

func select_card() -> void:
	perk_selected.emit(curr_perk_card.perk_data)
	get_tree().paused = false

func set_card_data(perk_hand: Array[PerkData]) -> void:
	perk_card_1.perk_data = perk_hand[0]
	perk_card_2.perk_data = perk_hand[1]
	perk_card_3.perk_data = perk_hand[2]

func animate() -> void:
	top_letterbox.position = Vector2(-512, 0)
	bottom_letterbox.position = Vector2(512, 256)

	animate_letterboxes()
	animate_candles()
	bounce_element(header, 4)

	for card: PerkCard in perk_cards:
		card.animate()
		await get_tree().create_timer(delay_between_cards).timeout

	# # Highlight middle card
	# perk_cards_linked.head.value.highlight() 
	# perk_cards_linked.head.value.pop_up()

func animate_reset() -> void:
	animate_reset_letterboxes()
	animate_reset_candles()
	for card: PerkCard in perk_cards:
		card.animate_reset()

func animate_letterboxes() -> void:	
	var top_tween: Tween = get_tree().create_tween()
	top_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	top_tween.tween_property(top_letterbox, "position", Vector2(0,0), letterbox_speed)

	var bottom_tween: Tween = get_tree().create_tween()
	bottom_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	bottom_tween.tween_property(bottom_letterbox, "position", Vector2(0,256), letterbox_speed)

func animate_reset_letterboxes() -> void:
	var top_tween: Tween = get_tree().create_tween()
	top_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	top_tween.tween_property(top_letterbox, "position", Vector2(-512, 0), letterbox_speed)

	var bottom_tween: Tween = get_tree().create_tween()
	bottom_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	bottom_tween.tween_property(bottom_letterbox, "position", Vector2(512, 256), letterbox_speed)

	await top_tween.finished
	main.unpause_from_perk_ui()

func bounce_element(ui_element: Control, bounce_height) -> void:
	var target: Vector2

	var bounce_up_tween: Tween = get_tree().create_tween() 
	bounce_up_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	target = ui_element.position - Vector2(0,bounce_height)
	bounce_up_tween.tween_property(ui_element, "position", target, bounce_speed)

	await bounce_up_tween.finished

	var bounce_down_tween: Tween = get_tree().create_tween()
	bounce_down_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	target = ui_element.position + Vector2(0,bounce_height)
	bounce_down_tween.tween_property(ui_element, "position", target, bounce_speed)

func animate_candles() -> void:
	for candle: TextureRect in candles_array:
		var candle_tween: Tween = get_tree().create_tween()
		candle_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		var target: Vector2 = candle.position - Vector2(0,84)
		candle_tween.tween_property(candle, "position", target, candle_speed)

		await candle_tween.finished
		bounce_element(candle, 16)

		await get_tree().create_timer(candle_delay).timeout

func animate_reset_candles() -> void:
	for candle: TextureRect in candles_array:
		var candle_tween: Tween = get_tree().create_tween()
		candle_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		var target: Vector2 = candle_reset_position[candle]
		candle_tween.tween_property(candle, "global_position", target, candle_speed)

		await candle_tween.finished
		bounce_element(candle, 16)
