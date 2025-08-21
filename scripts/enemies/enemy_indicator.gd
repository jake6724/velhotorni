class_name EnemyIndicator
extends Node2D
## Handles drawing enemy hex and boon indicators using _draw()

const HEX_TRANSPARENCY: float = 0.3
const BOON_TRANSPARENCY: float = 0.3

const COLOR_HEX_DEFAULT: String = "#ffffff"
const COLOR_BOON_DEFAULT: String = "#ffffff"

# Draw
var can_show_hex_range: bool = false:
	set(value):
		can_show_hex_range = value
		queue_redraw()

var can_show_boon_range: bool = false:
	set(value):
		can_show_boon_range = value
		queue_redraw()

func _draw():
	if can_show_hex_range:
		draw_circle(Vector2.ZERO + owner.data.pos_offset, owner.data.hex_data_list[0].cast_radius, Color(Color(COLOR_HEX_DEFAULT),HEX_TRANSPARENCY), false, -1.0, false)
	
	if can_show_boon_range:
		draw_circle(Vector2.ZERO + owner.data.pos_offset, owner.data.boon_data.cast_radius, Color(Color(COLOR_BOON_DEFAULT),BOON_TRANSPARENCY), false, -1.0, false)