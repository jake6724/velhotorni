## This custom resource should be added to a `Bullet` scene through its `BulletData` resource.
class_name DebuffData
extends Resource

## The `Constants.Debuff` type of the debuff. Options include `SLOW`, `BURN`, `FREEZE`, `STUN`, `WEAKEN`, `KNOCKBACK`.
@export var type: Constants.Debuff

## `priority` determines whether this `Debuff` will overrule another `Debuff` of the same type. The `Debuff` with the highest
## priority will always be applied. In the case of 2 `Debuffs` with the same `priority`, the `Debuff` with the highest 
## remaining time active (`total_duration` - time elapsed since applying) will always be applied.
@export var priority: Constants.DebuffPriority

## `Constant.Element` value.
@export var element: Constants.Element # TODO: this should just come from the bullet? 
 
## `value` is specific to the effect of the debuff, and will effect different values on the target accordingly.
## Example: For burn, `value` represents the damage applied
## each time the enemy takes burn damage.
@export var value: float

## The total time that this debuff will effect the target. Once this time has been completed, the debuff will immeadiately stop,
## regardless if `repeat_duration` is actively counting down.
@export var total_duration: float

## The time between apply the debuff effect. If the debuff type is non-repeating (such as SLOW), this value will not be used and 
## it does not matter what it is set to. Example: For burn, `repeat_duration` is the time between applying burn damage. If
## this value is 5, the target will take `value` amount of burn damage every `repeat_duration` seconds.
@export var repeat_duration: float

@export var debuff_script: Script