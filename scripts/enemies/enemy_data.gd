class_name EnemyData
extends Resource

@export var size: Enemy.Size
@export var element: Constants.Element
@export var strong_against_element: Constants.Element
@export var weak_against_element: Constants.Element
@export var health: float
@export var speed: float
@export var damage: int = 1
@export var tower_mana_drop_chance_base: float = 1.0
@export var element_mana_drop_chance: float = 1.0
@export var atlas: Texture
@export var show_light: bool = false
@export var explosion_sfx: AudioStreamOggVorbis
var pos_offset: Vector2

@export_category("Boon")
@export var boon_data: BoonData

@export_category("Hexes")
@export var hex_data_list: Array[HexData]

## Multiplier to modify the required distance travelled before `Enemy` can be knockbacked again. This value is multiplied by the distance
## of the first active knockback debuff.
@export var knockback_multiplier: float = 1.5

@export_category("Bestiary")
@export var enemy_name: String
@export_multiline var enemy_description: String
