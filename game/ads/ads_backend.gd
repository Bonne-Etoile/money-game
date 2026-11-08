class_name AdsBackend
extends RefCounted
## What the Ads autoload needs from an ad network: one rewarded ad at a time, loaded ahead.
## AdMobAdsBackend talks to the AdMob plugin on Android; FakeAdsBackend stands in everywhere
## else (desktop, tests).

## A rewarded ad became ready to show, or stopped being ready.
signal rewarded_ready_changed(ready: bool)
## The rewarded ad shown closed; `rewarded` is true when the player earned the reward.
signal rewarded_finished(rewarded: bool)


## Starts the network (consent, initialisation) and loads the first rewarded ad.
func start() -> void:
	pass


func is_rewarded_ready() -> bool:
	return false


## Shows the loaded rewarded ad; `rewarded_finished` follows (false at once if none is ready).
func show_rewarded() -> void:
	rewarded_finished.emit(false)
