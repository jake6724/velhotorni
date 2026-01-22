## This custom resource should be added to a `Bullet` scene through its `BulletData` resource.
class_name DebuffData
extends Resource

## The total time that this debuff will effect the target. Once this time has been completed, the debuff will immeadiately stop,
## regardless if `repeat_duration` is actively counting down.
@export var total_duration: float

## The `Constants.Debuff` type of the debuff. Options include `SLOW`, `BURN`, `FREEZE`, `STUN`, `WEAKEN`, `KNOCKBACK`.
var type: Debuff.Type

## `Constant.Element` value.
var element: Constants.Element # TODO: this should just come from the bullet? 

var modified_total_duration: float = total_duration
## This is calculated in `Tower.update_debuff_data()`. Calculation includes global variables from `GlobalTowerData`
var modified_value: float

var preview_modified_total_duration: float
var preview_modified_value: float