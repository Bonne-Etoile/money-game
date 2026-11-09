class_name FakeAdsBackend
extends AdsBackend
## Ads without a network, for the desktop builds and the tests: a rewarded ad is always ready
## and ends at once. Tests set `ready` and `grants_reward` to play the other cases.

## Whether a rewarded ad is ready; setting it announces the change.
var ready: bool = true:
	set(value):
		if value != ready:
			ready = value
			rewarded_ready_changed.emit(ready)
## Whether the player "watches to the end" (false: closed before the reward).
var grants_reward: bool = true
## Rewarded ads shown so far.
var shown: int = 0


func start() -> void:
	rewarded_ready_changed.emit(ready)


func is_rewarded_ready() -> bool:
	return ready


func show_rewarded() -> void:
	if not ready:
		rewarded_finished.emit(false)
		return
	shown += 1
	rewarded_finished.emit(grants_reward)
