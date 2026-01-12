extends ScrollContainer
class_name PannableScrollContainer

# Internal info
# -- Dragging map
var click_start:Vector2 = Vector2.ZERO
var old_scroll:Vector2 = Vector2.ZERO

func _ready():
	# Hide scrollbar
	get_h_scroll_bar().modulate.a = 0
	get_v_scroll_bar().modulate.a = 0
	
	set_process(false)

func _gui_input(event):
	if Input.is_action_just_pressed("left_click"):
		click_start = get_global_mouse_position()
		old_scroll = Vector2(scroll_horizontal, scroll_vertical)
		set_process(true)
	elif Input.is_action_just_released("left_click"):
		click_start = Vector2.ZERO
		set_process(false)

func _process(delta):
	if click_start:
		var new_scroll:Vector2 = old_scroll + click_start - get_global_mouse_position()
		scroll_horizontal = new_scroll.x
		scroll_vertical = new_scroll.y