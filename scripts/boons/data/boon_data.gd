class_name BoonData
extends Resource

@export_category("Caster Options")
## `Boon.Mode.TIMER` = Boon effects are applied every `cast_speed` seconds to any `Enemy` within `cast_radius` 
@export var mode: Boon.Mode
@export var self_cast: bool
@export var ally_cast: bool
@export var cast_speed: float
@export var cast_radius: float

@export_category("Effect Data")
@export var type: Boon.Type

@export var value: float

## Apply the effect immediately, then immedaitely remove the boon. This will override every setting below and they will not
## have an effect.
@export var one_shot: bool

## ** Only use if mode above is Boon.Mode.COLLISION **
## If true, enemies will lose their boon immediately upon leaving the caster's cast radius
@export var manual_disable: bool

## Total duration of an applied effect. This DOES NOT determine how frequently a caster applies a boon to allies, but
## how long the boon lasts once it has been applied. To set how frequently a caster applies a boon to allies, see Cast Speed above
## NOTE: this does nothing if One Shot is enabled
@export var total_duration: float

## Determines if the repeat duration below will be used
@export var repeats: bool

## Delay between triggering an active boon on an enemy. For example, if set to 1 on a heal boon, the target will be healed
## every 1 second.
@export var repeat_duration: float
