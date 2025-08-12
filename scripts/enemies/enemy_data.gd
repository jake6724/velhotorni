class_name EnemyData
extends Resource

@export var size: Enemy.Size
@export var element: Constants.Element
@export var strong_against_element: Constants.Element
@export var weak_against_element: Constants.Element
@export var health: float
@export var speed: float
@export var damage: int = 1
@export var atlas: Texture
@export var explosion_sfx: AudioStreamOggVorbis

@export_category("Boon")
@export var boon_data: BoonData

@export_category("Debuff Multipliers")
## Multiplier to modify how long until `Enemy` can be frozen or stunned again. This value is multiplied by the duration of
## the first active CC debuff.
@export var cc_multiplier: float = 1.5

## Multiplier to modify the required distance travelled before `Enemy` can be knockbacked again. This value is multiplied by the distance
## of the first active knockback debuff.
@export var knockback_multiplier: float = 1.5