class_name StaffSprite
extends Sprite2D

## Update the region of the staff atlas, changing the staff graphic. Return the corresponding value for
## player_aim.staff_rotation_offset_degrees
func switch_staff_texture(_spell_type: SpellData.Type) -> int:
	match _spell_type:
		SpellData.StaffType.ARCANE: 
			texture.region = Rect2(0,0,217,15)
			position = Vector2(0, 5) 
			offset = Vector2(4, 0.5) # TODO: Broke.
			return 0

		SpellData.StaffType.FIRE_STAFF:
			texture.region = Rect2(0,45,217,15)
			position = Vector2(0, 5) 
			offset = Vector2(4, 0.5) # TODO: Broke.
			return 0

		SpellData.StaffType.WATER_SWORD: 
			texture.region = Rect2(0,15,217,15)
			offset = Vector2(8, .5)
			return -120

		SpellData.StaffType.TRIPLE_STAFF: 
			texture.region = Rect2(0,60,217,15)
			offset = Vector2(4, 0.5)
			return 0
			
		_: return 0