class_name LoadoutUI
extends Control

@onready var spell_tab_button: Button = %SpellTabButton
@onready var tower_tab_button: Button = %TowerTabButton
@onready var deity_tab_button: Button = %DeityTabButton
@onready var tab_buttons_dll: DoublyLinkedList = DoublyLinkedList.new([spell_tab_button, tower_tab_button, deity_tab_button])
@onready var _curr_tab_button: Button = tab_buttons_dll.head.value
@onready var tab_button_reset_positions: Dictionary[Button, Vector2] = {spell_tab_button: spell_tab_button.global_position, tower_tab_button: tower_tab_button.global_position, deity_tab_button: deity_tab_button.global_position}
const TAB_BUTTON_RESET_SPEED: float = .1
const TAB_BUTTON_POPUP_SPEED: float = .1
const TAB_BUTTON_POPUP_OFFSET: Vector2 = Vector2(0,-4)

@onready var spell_page: LoadoutPageSpell = %LoadoutPageSpell
@onready var tower_page: LoadoutPageTower = %LoadoutPageTower
@onready var curr_loadout_page: LoadoutPage = spell_page

func _ready() -> void:
	spell_tab_button.pressed.connect(on_tab_button_pressed.bind(spell_tab_button))
	spell_tab_button.pressed.connect(tab_buttons_dll.set_value_as_head.bind(spell_tab_button))
	tower_tab_button.pressed.connect(on_tab_button_pressed.bind(tower_tab_button))
	tower_tab_button.pressed.connect(tab_buttons_dll.set_value_as_head.bind(tower_tab_button))
	deity_tab_button.pressed.connect(on_tab_button_pressed.bind(deity_tab_button))
	deity_tab_button.pressed.connect(tab_buttons_dll.set_value_as_head.bind(deity_tab_button))

	popup_curr_tab_button()

	curr_loadout_page.start_card.grab_focus()

func on_tab_button_pressed(tab_button: Button) -> void:
	if _curr_tab_button:
		_curr_tab_button.get_child(0).add_theme_color_override("font_color", Constants.ui_color_unselected)
		var reset_tween: Tween = get_tree().create_tween()
		reset_tween.tween_property(_curr_tab_button, "global_position", tab_button_reset_positions[_curr_tab_button], TAB_BUTTON_RESET_SPEED)
		await reset_tween.finished

	if tab_button != _curr_tab_button:
		_curr_tab_button = tab_button
		popup_curr_tab_button()

	show_page(_curr_tab_button)

func popup_curr_tab_button() -> void:
	var tween: Tween = get_tree().create_tween()
	var target: Vector2 = tab_button_reset_positions[_curr_tab_button] + TAB_BUTTON_POPUP_OFFSET
	tween.tween_property(_curr_tab_button, "global_position", target, TAB_BUTTON_POPUP_SPEED)
	_curr_tab_button.get_child(0).add_theme_color_override("font_color", Color.WHITE)

func show_page(tab_button: Button) -> void:
	curr_loadout_page.hide()
	match tab_button:
		spell_tab_button: curr_loadout_page = spell_page
		tower_tab_button: curr_loadout_page = tower_page
		# deity_tab_button: _curr_page = deity_page
	curr_loadout_page.show()

# func _input(event):
# 	if event.is_action("switch_selection_right") and event.is_pressed() and not event.is_echo():
# 		tab_buttons_dll.switch_right()
# 		on_tab_button_pressed(tab_buttons_dll.head.value)

# 	if event.is_action("switch_selection_left") and event.is_pressed() and not event.is_echo():
# 		tab_buttons_dll.switch_left()
# 		on_tab_button_pressed(tab_buttons_dll.head.value)